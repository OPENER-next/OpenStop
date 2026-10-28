class PhotoMetadata {
  final double latitude;
  final double longitude;
  final DateTime capturedAt;

  const PhotoMetadata(this.latitude, this.longitude, this.capturedAt);

  factory PhotoMetadata.fromExif(Map<String, String> tags) {
    double coordinate(String key, double limit) {
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
      return ref == 'S' || ref == 'W' ? -result : result;
    }

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
    return PhotoMetadata(coordinate('GPSLatitude', 90), coordinate('GPSLongitude', 180), date);
  }
}
