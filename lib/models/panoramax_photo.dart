import 'dart:io';

import 'package:exif/exif.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:meta_photo_picker/meta_photo_picker.dart';
import 'package:uuid/uuid.dart';

/// A selected image and its preassigned Panoramax identifier.
class PanoramaxPhoto {
  final String id;
  final String path;
  final LatLng captureLocation;

  PanoramaxPhoto._({required this.path, required this.captureLocation}) : id = const Uuid().v4();

  /// Uses the native camera and supplements missing EXIF GPS with a fresh fix.
  static Future<PanoramaxPhoto?> takePhoto() async {
    final image = await ImagePicker().pickImage(
      source: ImageSource.camera,
      requestFullMetadata: true,
    );
    if (image == null) return null;
    try {
      var location = _readLocation(await readExifFromFile(File(image.path)));
      if (location == null) {
        final permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          await Geolocator.requestPermission();
        }
        final position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.best,
            timeLimit: Duration(seconds: 20),
          ),
        );
        location = LatLng(position.latitude, position.longitude);
      }
      return PanoramaxPhoto._(path: image.path, captureLocation: location);
    } catch (_) {
      await _discardRejectedFile(image.path);
      rethrow;
    }
  }

  /// Selects an original image with GPS through the platform file picker.
  static Future<PanoramaxPhoto?> selectPhoto() async {
    final selected = await MetaPhotoPicker().pickSinglePhoto();
    if (selected == null) return null;
    final path = selected.filePath;
    if (path == null) throw const FormatException('Missing selected photo file');
    try {
      final location = _readLocation(await readExifFromFile(File(path)));
      if (location == null) throw const FormatException('Missing photo location');
      return PanoramaxPhoto._(path: path, captureLocation: location);
    } catch (_) {
      await _discardRejectedFile(path);
      rethrow;
    }
  }

  static Future<void> _discardRejectedFile(String path) async {
    try {
      final file = File(path);
      if (file.existsSync()) await file.delete();
    } on FileSystemException {
      // Preserve the original capture or metadata error.
    }
  }

  static LatLng? _readLocation(Map<String, IfdTag> tags) {
    double? coordinate(String key, String positive, String negative, double limit) {
      final values = tags['GPS GPS$key']?.values;
      final reference = tags['GPS GPS${key}Ref']?.printable;
      if (values is! IfdRatios || values.ratios.length != 3) return null;
      if (reference != positive && reference != negative) return null;
      final parts = values.ratios.map((ratio) => ratio.toDouble()).toList();
      final value = parts[0] + parts[1] / 60 + parts[2] / 3600;
      if (!value.isFinite || value < 0 || value > limit) return null;
      return reference == negative ? -value : value;
    }

    final latitude = coordinate('Latitude', 'N', 'S', 90);
    final longitude = coordinate('Longitude', 'E', 'W', 180);
    if (latitude == null || longitude == null) return null;
    return LatLng(latitude, longitude);
  }

  /// Deletes the picker's temporary copy, leaving the original library photo intact.
  Future<void> deleteFromDisk() async {
    final file = File(path);
    if (file.existsSync()) await file.delete();
  }
}
