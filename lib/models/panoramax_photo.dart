import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:exif/exif.dart';
import 'package:file_selector/file_selector.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:uuid/uuid.dart';

/// A selected image and its preassigned Panoramax identifier.
class PanoramaxPhoto {
  final String id;
  final File file;
  final LatLng captureLocation;
  /// MD5 hash of the entire file used to detect duplicates.
  final Digest? _hash;

  PanoramaxPhoto._({
    required this.file,
    required this.captureLocation,
    this._hash,
  }) : id = const Uuid().v4();

  // At the moment Panoramax only supports photos with type JPEG
  static const _jpegTypes = XTypeGroup(
    label: 'JPEG',
    extensions: ['jpg', 'jpeg'],
    mimeTypes: ['image/jpeg'],
    uniformTypeIdentifiers: ['public.jpeg'],
  );

  /// Uses the native camera and supplements missing EXIF GPS with a fresh fix.
  static Future<PanoramaxPhoto?> takePhoto() async {
    // on iOS images should be converted automatically from HEIC to JPEG
    final image = await ImagePicker().pickImage(
      source: ImageSource.camera,
      requestFullMetadata: true,
    );
    if (image == null) return null;
    final file = File(image.path);
    try {
      // Safety check that shouldn't be necessary.
      // Mainly added to catch errors on potential API changes in the future
      if (!(await _isJpeg(image))) {
        throw const UnsupportedFileTypeException('File type must be JPEG');
      }
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
      return PanoramaxPhoto._(file: file, captureLocation: location);
    } catch (_) {
      await _discardRejectedFile(file);
      rethrow;
    }
  }

  /// Selects an original image with GPS through the platform file picker.
  static Future<PanoramaxPhoto?> selectPhoto() async {
    final XFile? image;
    if (Platform.isAndroid) {
      // use file picker on Android to get EXIF metadata
      image = await openFile(acceptedTypeGroups: const [_jpegTypes]);
    } else {
      // images should be converted automatically from HEIC to JPEG
      image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        requestFullMetadata: true,
      );
    }
    if (image == null) return null;
    final file = File(image.path);
    try {
      // Check mainly required for iOS because on Android we pre-filter by JPEG
      if (!(await _isJpeg(image))) {
        throw const UnsupportedFileTypeException('File type must be JPEG');
      }
      final location = _readLocation(await readExifFromFile(file));
      if (location == null) {
        throw const MissingLocationException('Missing photo location');
      }
      return PanoramaxPhoto._(
        file: file,
        captureLocation: location,
        hash: await _fileHash(image),
      );
    } catch (_) {
      await _discardRejectedFile(file);
      rethrow;
    }
  }

  static Future<void> _discardRejectedFile(File file) async {
    // Android and iOS copy the selected file to the temp directory
    // This is why we remove the file on error
    try {
      if (file.existsSync()) await file.delete();
    } on FileSystemException {
      // Preserve the original capture or metadata error.
    }
  }

  /// Reads the first 3 bytes (header) and compares with JPEG magic bytes
  /// This is required because XFile.mimeType is not reliably set.
  /// For example it is null when using image_picker on iOS
  static Future<bool> _isJpeg(XFile file) async {
    final bytes = await file.openRead(0, 3).expand((chunk) => chunk).toList();
    if (bytes.length < 3) return false;
    return bytes[0] == 0xFF && bytes[1] == 0xD8 && bytes[2] == 0xFF;
  }

  static Future<Digest> _fileHash(XFile file) async {
    return await md5.bind(file.openRead()).single;
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

  /// Whether both photos were selected from the same file.
  bool isDuplicateOf(PanoramaxPhoto other) => _hash != null && _hash == other._hash;

  /// Deletes the picker's temporary copy, leaving the original library photo intact.
  Future<void> deleteFromDisk() async {
    if (file.existsSync()) await file.delete();
  }
}

class PanoramaxPhotoException implements Exception {
  final String message;
  const PanoramaxPhotoException(this.message);
}

class MissingLocationException extends PanoramaxPhotoException {
  const MissingLocationException(super.message);
}

class UnsupportedFileTypeException extends PanoramaxPhotoException {
  const UnsupportedFileTypeException(super.message);
}
