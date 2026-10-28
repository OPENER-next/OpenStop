import 'dart:convert';
import 'dart:io';

import 'package:exif/exif.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '/models/photo_metadata.dart';
import '/models/stop_photo.dart';

class StopPhotoStore {
  final Directory directory;
  final List<StopPhoto> _photos;
  final Future<bool> Function(List<StopPhoto>)? onChanged;
  StopPhoto? _pending;
  final File? pendingCaptureFile;
  bool recoveryFailed = false;
  static final _recovered = <StopPhoto>[];
  static final _recoveryErrors = <String>{};

  StopPhotoStore(
    this.directory, {
    List<StopPhoto> photos = const [],
    this.onChanged,
    this.pendingCaptureFile,
  }) : _photos = List.of(photos);

  static Future<Directory>? _sessionDirectory;

  static Future<Directory> _startSession(Directory cache) async {
    final cachePath = await cache.resolveSymbolicLinks();
    final ownedPath = '$cachePath${Platform.pathSeparator}stop_photos';
    final owned = Directory(ownedPath);
    if (owned.existsSync()) {
      if (await owned.resolveSymbolicLinks() != ownedPath) {
        throw StateError('Unexpected photo cache location');
      }
      await owned.delete(recursive: true);
    }
    await owned.create(recursive: true);
    return owned;
  }

  static Future<StopPhotoStore> open({
    List<StopPhoto> photos = const [],
    String? osmReference,
    Future<bool> Function(List<StopPhoto>)? onChanged,
  }) async {
    final directory = await (_sessionDirectory ??= getTemporaryDirectory().then(_startSession));
    final recovered = _recovered.where((photo) => photo.osmReference == osmReference).toList();
    final answers = [
      ...photos,
      ...recovered.where((photo) => !photos.any((item) => item.id == photo.id)),
    ];
    if (recovered.isNotEmpty && onChanged != null && !await onChanged(answers)) {
      throw StateError('The questionnaire has been discarded');
    }
    _recovered.removeWhere(recovered.contains);
    return StopPhotoStore(
      directory,
      photos: answers,
      onChanged: onChanged,
      pendingCaptureFile: Platform.isAndroid ? await _captureJournal() : null,
    )..recoveryFailed = _recoveryErrors.remove(osmReference);
  }

  Future<void> _replacePhotos(List<StopPhoto> photos) async {
    if (onChanged != null && !await onChanged!(photos)) {
      throw StateError('The questionnaire has been discarded');
    }
    _photos
      ..clear()
      ..addAll(photos);
  }

  Future<void> save(StopPhoto photo) =>
      _replacePhotos([..._photos.where((item) => item.id != photo.id), photo]);

  Future<List<StopPhoto>> load() async => List.of(_photos);

  static Future<File> _captureJournal() async {
    final root = await getApplicationSupportDirectory();
    await root.create(recursive: true);
    return File('${root.path}/pending_stop_photo.json');
  }

  static Future<void> recoverLostCapture() async {
    if (!Platform.isAndroid) return;
    final store = await open();
    await store.recoverCapture(ImagePicker());
  }

  Future<void> _writePending(Map<String, dynamic> data) async {
    final journal = pendingCaptureFile;
    if (journal == null) return;
    final temporary = File('${journal.path}.tmp');
    await temporary.writeAsString(jsonEncode(data), flush: true);
    await temporary.rename(journal.path);
  }

  Future<void> prepareCapture(StopPhoto photo) async {
    await _writePending({
      'id': photo.id,
      'osmType': photo.osmType,
      'osmId': photo.osmId,
      'label': photo.label,
    });
    _pending = photo;
  }

  Future<void> cancelCapture() async {
    _pending = null;
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
      reference = '${data['osmType']}/${data['osmId']}';
      if (lost.exception != null) throw lost.exception!;
      final sourcePath = lost.files?.firstOrNull?.path ?? data['sourcePath'] as String?;
      if (sourcePath == null) return;
      await _writePending({...data, 'sourcePath': sourcePath});
      final id = data['id'] as String;
      if (!RegExp(r'^[a-fA-F0-9-]{36}$').hasMatch(id) ||
          !['node', 'way', 'relation'].contains(data['osmType'])) {
        throw const FormatException('Invalid pending capture');
      }
      _pending = StopPhoto(
        id: id,
        osmType: data['osmType'] as String,
        osmId: data['osmId'] as int,
        label: data['label'] as String,
        path: '${directory.path}/$id.jpg',
      );
      await finishCapture(XFile(sourcePath));
      _recovered.addAll(await load());
    } catch (_) {
      if (reference != null) _recoveryErrors.add(reference);
      rethrow;
    } finally {
      await cancelCapture();
    }
  }

  Future<void> finishCapture(XFile file) async {
    final pending = _pending;
    if (pending == null) return;
    final tags = await readExifFromFile(File(file.path));
    // Validate the original EXIF; upload the unchanged file with that metadata.
    PhotoMetadata.fromExif(tags.map((key, tag) => MapEntry(key, tag.printable)));
    await file.saveTo(pending.path);
    try {
      await save(pending);
    } catch (_) {
      await File(pending.path).delete();
      rethrow;
    }
    await _removePickerTemporaryCopy(file);
    await cancelCapture();
  }

  Future<void> _removePickerTemporaryCopy(XFile file) async {
    try {
      final cache = await getTemporaryDirectory();
      final cachePath = await cache.resolveSymbolicLinks();
      final sourcePath = await File(file.path).resolveSymbolicLinks();
      if (sourcePath.startsWith('$cachePath${Platform.pathSeparator}')) {
        await File(file.path).delete();
      }
    } catch (_) {}
  }

  Future<void> delete(StopPhoto photo) async {
    final image = File(photo.path);
    try {
      if (image.existsSync()) await image.delete();
    } on FileSystemException {
      if (image.existsSync()) rethrow;
    }
    await _replacePhotos(_photos.where((item) => item.id != photo.id).toList());
  }
}
