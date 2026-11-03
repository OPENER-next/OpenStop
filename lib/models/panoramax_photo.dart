import 'dart:async';
import 'dart:io';

import 'package:exif/exif.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

/// A selected image and the state needed to upload it to Panoramax.
class PanoramaxPhoto {
  final String id;
  final String path;

  /// Measured during an in-app capture; library photos use their original EXIF.
  final ({double latitude, double longitude})? captureLocation;
  final PhotoUploadState upload;

  PanoramaxPhoto({
    required this.id,
    required this.path,
    this.captureLocation,
    PhotoUploadState? upload,
  }) : upload = upload ?? PhotoUploadState();

  /// Capture or select an image, retaining original GPS when present. Missing
  /// GPS may be supplemented only for a new camera capture, never a library image.
  static Future<PanoramaxPhoto?> captureWithLocation({
    required Directory directory,
    ImageSource source = ImageSource.camera,
    ImagePicker? picker,
    Future<void> Function(PanoramaxPhoto)? onCaptureStarted,
  }) async {
    final id = const Uuid().v4();
    final pending = PanoramaxPhoto(id: id, path: '${directory.path}/$id.jpg');
    await onCaptureStarted?.call(pending);
    final positions = <Position>[];
    StreamSubscription<Position>? subscription;
    if (source == ImageSource.camera) {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
        const settings = LocationSettings(accuracy: LocationAccuracy.best);
        subscription = Geolocator.getPositionStream(locationSettings: settings).listen(
          positions.add,
          onError: (Object _) {},
        );
      }
    }
    final galleryPicker = Platform.isAndroid && source == ImageSource.gallery;
    const channel = MethodChannel('openstop/photo_question');
    try {
      if (galleryPicker) await channel.invokeMethod<void>('prepareGalleryPicker');
      final image = await (picker ?? ImagePicker()).pickImage(
        source: source,
        requestFullMetadata: true,
      );
      if (image == null) return null;
      final selectedAt = DateTime.now();
      final tags = await readExifFromFile(File(image.path));
      final hasLocation = _hasLocation(tags);
      ({double latitude, double longitude})? location;
      if (!hasLocation) {
        if (source != ImageSource.camera) throw const FormatException('Missing photo location');
        // A fresh fix is required; never substitute the selected OSM element's position.
        if (positions.isEmpty) {
          positions.add(
            await Geolocator.getCurrentPosition(
              locationSettings: const LocationSettings(
                accuracy: LocationAccuracy.best,
                timeLimit: Duration(seconds: 20),
              ),
            ),
          );
        }
        final time = tags['EXIF DateTimeOriginal']?.printable;
        final capturedAt = time == null
            ? selectedAt
            : DateTime.tryParse(
                    time.replaceFirstMapped(
                      RegExp(r'^(\d{4}):(\d{2}):(\d{2})'),
                      (match) => '${match[1]}-${match[2]}-${match[3]}',
                    ),
                  ) ??
                  selectedAt;
        final nearest = positions.reduce(
          (a, b) =>
              a.timestamp.difference(capturedAt).abs() <= b.timestamp.difference(capturedAt).abs()
              ? a
              : b,
        );
        // Allow GPS update delays without reusing an old fix from a long camera session.
        if (nearest.timestamp.difference(capturedAt).abs() > const Duration(seconds: 30)) {
          throw TimeoutException('No location near capture time');
        }
        location = (latitude: nearest.latitude, longitude: nearest.longitude);
      }
      await _saveImage(image, pending.path);
      return PanoramaxPhoto(id: id, path: pending.path, captureLocation: location);
    } finally {
      await subscription?.cancel();
      if (galleryPicker) await channel.invokeMethod<void>('finishGalleryPicker');
    }
  }

  /// Accept an interrupted Android capture using its original GPS metadata.
  static Future<PanoramaxPhoto> recover(
    XFile image, {
    required String id,
    required String path,
  }) async {
    if (!_hasLocation(await readExifFromFile(File(image.path)))) {
      throw const FormatException('Missing photo location');
    }
    await _saveImage(image, path);
    return PanoramaxPhoto(id: id, path: path);
  }

  static bool _hasLocation(Map<String, IfdTag> tags) =>
      (tags['GPS GPSLatitude']?.printable.isNotEmpty ?? false) &&
      (tags['GPS GPSLongitude']?.printable.isNotEmpty ?? false);

  static Future<void> _saveImage(XFile image, String path) async {
    await image.saveTo(path);
    try {
      final cache = await (await getTemporaryDirectory()).resolveSymbolicLinks();
      final source = await File(image.path).resolveSymbolicLinks();
      if (source.startsWith('$cache${Platform.pathSeparator}') && source != path) {
        await File(source).delete();
      }
    } catch (_) {
      // The accepted copy is already stored; picker cache cleanup is best effort.
    }
  }
}

/// Mutable checkpoints retained in the answer for retries after partial uploads.
class PhotoUploadState {
  final String? accountId;
  String? setId;
  bool fileUploaded;
  bool completed;

  PhotoUploadState({this.accountId, this.setId, this.fileUploaded = false, this.completed = false});
}
