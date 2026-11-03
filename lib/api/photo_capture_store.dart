import 'dart:convert';
import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '/models/panoramax_photo.dart';

/// Owns working image files and the journal for interrupted Android captures.
/// Accepted photos live in answers; recovery retains only unaccepted captures.
class PhotoCaptureStore {
  final Directory directory;
  final File? pendingCaptureFile;
  static final _recovered = <String, List<PanoramaxPhoto>>{};
  static final _recoveryErrors = <String>{};

  PhotoCaptureStore(
    this.directory, {
    this.pendingCaptureFile,
  });

  static Future<Directory>? _sessionDirectory;

  static Future<Directory> _startSession(Directory support) async {
    await support.create(recursive: true);
    final supportPath = await support.resolveSymbolicLinks();
    final ownedPath = '$supportPath${Platform.pathSeparator}stop_photos';
    final owned = Directory(ownedPath);
    if (owned.existsSync() && await owned.resolveSymbolicLinks() != ownedPath) {
      throw StateError('Unexpected photo storage location');
    }
    await owned.create(recursive: true);
    await PhotoCaptureStore(
      owned,
      pendingCaptureFile: File('$supportPath/pending_stop_photo.json'),
    ).cleanupPreviousSession();
    return owned;
  }

  Future<void> cleanupPreviousSession() async {
    final retained = <String>{};
    final photoName = RegExp(r'^[a-fA-F0-9-]{36}\.jpg$');
    final journal = pendingCaptureFile;
    if (journal != null && journal.existsSync()) {
      try {
        final data = jsonDecode(await journal.readAsString());
        if (data is! Map<String, dynamic>) return;
        final id = data['id'];
        if (id is! String || !photoName.hasMatch('$id.jpg')) return;
        final destination = File('${directory.path}/$id.jpg');
        if (destination.existsSync()) {
          retained.add(await destination.resolveSymbolicLinks());
        }
        final source = data['sourcePath'];
        if (source is String && File(source).existsSync()) {
          retained.add(await File(source).resolveSymbolicLinks());
        }
      } on FormatException {
        return;
      } on FileSystemException {
        return;
      }
    }
    await for (final entry in directory.list(followLinks: false)) {
      if (entry is File &&
          photoName.hasMatch(entry.uri.pathSegments.last) &&
          !retained.contains(await entry.resolveSymbolicLinks())) {
        await entry.delete();
      }
    }
  }

  static Future<PhotoCaptureStore> open() async {
    final directory = await (_sessionDirectory ??= getApplicationSupportDirectory().then(
      _startSession,
    ));
    return PhotoCaptureStore(
      directory,
      pendingCaptureFile: Platform.isAndroid ? await _captureJournal() : null,
    );
  }

  // Recovery holds only captures that have not yet been accepted by an answer.
  static List<PanoramaxPhoto> recoveredFor(String reference) =>
      List.of(_recovered[reference] ?? const []);

  static void acknowledgeRecovered(String reference, Iterable<PanoramaxPhoto> photos) {
    final recovered = _recovered[reference];
    recovered?.removeWhere(photos.contains);
    if (recovered?.isEmpty ?? false) _recovered.remove(reference);
  }

  static bool takeRecoveryError(String reference) => _recoveryErrors.remove(reference);

  static Future<File> _captureJournal() async {
    final root = await getApplicationSupportDirectory();
    await root.create(recursive: true);
    return File('${root.path}/pending_stop_photo.json');
  }

  static Future<void> recoverLostCapture() async {
    final store = await open();
    if (!Platform.isAndroid) return;
    await store.recoverCapture(ImagePicker());
  }

  Future<void> _writePending(Map<String, dynamic> data) async {
    final journal = pendingCaptureFile;
    if (journal == null) return;
    final temporary = File('${journal.path}.tmp');
    await temporary.writeAsString(jsonEncode(data), flush: true);
    await temporary.rename(journal.path);
  }

  Future<void> prepareCapture(PanoramaxPhoto photo, {required String osmReference}) async {
    await _writePending({
      'id': photo.id,
      'osmReference': osmReference,
    });
  }

  Future<void> cancelCapture() async {
    final journal = pendingCaptureFile;
    if (journal != null && journal.existsSync()) await journal.delete();
  }

  Future<void> recoverCapture(ImagePicker picker) async {
    String? reference;
    try {
      final journal = pendingCaptureFile;
      final data = journal != null && journal.existsSync()
          ? jsonDecode(await journal.readAsString()) as Map<String, dynamic>
          : null;
      final lost = await picker.retrieveLostData();
      if (data == null) return;
      // Accept journals written before target context was separated from photos.
      reference = data['osmReference'] as String? ?? '${data['osmType']}/${data['osmId']}';
      if (lost.exception != null) throw lost.exception!;
      final sourcePath = lost.files?.firstOrNull?.path ?? data['sourcePath'] as String?;
      if (sourcePath == null) return;
      await _writePending({...data, 'sourcePath': sourcePath});
      final id = data['id'] as String;
      if (!RegExp(r'^[a-fA-F0-9-]{36}$').hasMatch(id) ||
          !RegExp(r'^(node|way|relation)/[1-9]\d*$').hasMatch(reference)) {
        throw const FormatException('Invalid pending capture');
      }
      final photo = await PanoramaxPhoto.recover(
        XFile(sourcePath),
        id: id,
        path: '${directory.path}/$id.jpg',
      );
      _recovered.putIfAbsent(reference, () => []).add(photo);
    } catch (_) {
      if (reference != null) _recoveryErrors.add(reference);
      rethrow;
    } finally {
      await cancelCapture();
    }
  }

  Future<void> delete(PanoramaxPhoto photo) async {
    final image = File(photo.path);
    try {
      if (image.existsSync()) await image.delete();
    } on FileSystemException {
      if (image.existsSync()) rethrow;
    }
  }
}
