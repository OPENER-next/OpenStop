/// Validate original metadata, using a measured capture location only if GPS is missing.
/// Returns that supplemental location, or null when the original GPS is usable.
({double latitude, double longitude})? validatePhotoMetadata(
  Map<String, String> tags, {
  ({double latitude, double longitude}) Function(DateTime)? captureLocationAt,
}) {
  void validateCoordinate(String key, double limit) {
    final text = tags['GPS $key'] ?? '';
    final parts = text.replaceAll(RegExp(r'[\[\]]'), '').split(',');
    if (parts.length != 3) throw const FormatException('Missing GPS coordinates');
    double value(String text) {
      final ratio = text.trim().split('/');
      return double.parse(ratio[0]) / (ratio.length == 2 ? double.parse(ratio[1]) : 1);
    }

    final result = value(parts[0]) + value(parts[1]) / 60 + value(parts[2]) / 3600;
    if (!result.isFinite || result < 0 || result > limit) {
      throw const FormatException('Invalid GPS coordinates');
    }
    final ref = tags['GPS ${key}Ref'];
    if (!(key == 'GPSLatitude' ? ['N', 'S'] : ['E', 'W']).contains(ref)) {
      throw const FormatException('Missing GPS reference');
    }
  }

  final capturedAt = _photoCaptureTime(tags);
  try {
    validateCoordinate('GPSLatitude', 90);
    validateCoordinate('GPSLongitude', 180);
    return null;
  } on FormatException {
    if (captureLocationAt == null) rethrow;
  }
  final captureLocation = captureLocationAt(capturedAt);
  if (!captureLocation.latitude.isFinite ||
      !captureLocation.longitude.isFinite ||
      captureLocation.latitude.abs() > 90 ||
      captureLocation.longitude.abs() > 180) {
    throw const FormatException('Invalid capture location');
  }
  return captureLocation;
}

/// The camera's local capture time, also used to match a measured GPS fix.
DateTime _photoCaptureTime(Map<String, String> tags) {
  final time = (tags['EXIF DateTimeOriginal'] ?? '').trim().replaceAll('-', ':');
  final match = RegExp(r'^(\d{4}):(\d{2}):(\d{2}) (\d{2}):(\d{2}):(\d{2})$').firstMatch(time);
  if (match == null) throw const FormatException('Missing capture time');
  final date = DateTime.utc(
    int.parse(match[1]!),
    int.parse(match[2]!),
    int.parse(match[3]!),
    int.parse(match[4]!),
    int.parse(match[5]!),
    int.parse(match[6]!),
  );
  final components = [date.year, date.month, date.day, date.hour, date.minute, date.second];
  for (var i = 0; i < components.length; i++) {
    if (components[i] != int.parse(match[i + 1]!)) {
      throw const FormatException('Invalid capture time');
    }
  }
  return DateTime(date.year, date.month, date.day, date.hour, date.minute, date.second);
}
