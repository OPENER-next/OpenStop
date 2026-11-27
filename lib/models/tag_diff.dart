import 'package:latlong2/latlong.dart';
import 'package:osm_api/osm_api.dart';

/// The changes made to the tags of an element, including the values before the change.
///
/// Storing the previous values allows applying the changes to a newer version
/// of the element and detecting conflicting changes made by others in the meantime.
/// The conflict rules follow StreetComplete.

class TagDiff {
  final List<TagChange> changes;

  const TagDiff(this.changes);

  /// Creates the changes required to turn the [original] tags into the [modified] tags.

  factory TagDiff.between(Map<String, String> original, Map<String, String> modified) {
    return TagDiff([
      for (final MapEntry(:key, :value) in modified.entries)
        if (!original.containsKey(key))
          TagAdd(key, value)
        else if (original[key] != value)
          TagModify(key, original[key]!, value),
      for (final key in original.keys)
        if (!modified.containsKey(key)) TagDelete(key, original[key]!),
    ]);
  }

  bool get isEmpty => changes.isEmpty;

  /// Returns a copy of the given [tags] with all changes applied.
  ///
  /// Throws an [ElementConflictException] if a tag was changed by someone else
  /// to a value that contradicts one of the changes.
  /// A tag that was changed by someone else to the same value is not a conflict.

  Map<String, String> applyTo(Map<String, String> tags) {
    final result = Map.of(tags);
    for (final change in changes) {
      final current = result[change.key];
      switch (change) {
        case TagAdd(:final key, :final value):
          if (current != null && current != value) {
            throw ElementConflictException('Tag "$key" was added as "$current" in the meantime.');
          }
          result[key] = value;
        case TagModify(:final key, :final before, :final value):
          if (current != before && current != value) {
            throw ElementConflictException('Tag "$key" was changed to "$current" in the meantime.');
          }
          result[key] = value;
        case TagDelete(:final key, :final before):
          if (current != null && current != before) {
            throw ElementConflictException('Tag "$key" was changed to "$current" in the meantime.');
          }
          result.remove(key);
      }
    }
    return result;
  }
}

sealed class TagChange {
  final String key;

  const TagChange(this.key);
}

class TagAdd extends TagChange {
  final String value;

  const TagAdd(super.key, this.value);
}

class TagModify extends TagChange {
  final String before;
  final String value;

  const TagModify(super.key, this.before, this.value);
}

class TagDelete extends TagChange {
  final String before;

  const TagDelete(super.key, this.before);
}

/// Thrown when changes cannot be uploaded,
/// because the element was changed by someone else in a contradicting way or deleted.

class ElementConflictException implements Exception {
  final String message;

  const ElementConflictException(this.message);

  @override
  String toString() => 'ElementConflictException: $message';
}

/// Moving a node further than this distance in the meantime is treated as conflict,
/// because the answers might refer to a different place or object.

const kMaxNodeMovementInMeters = 20.0;

/// Throws an [ElementConflictException] if the geometry of the [current] element
/// differs substantially from the [original] element.

void checkGeometryConflict(OSMElement original, OSMElement current) {
  if (original is OSMNode && current is OSMNode) {
    final distance = const Distance().distance(
      LatLng(original.lat, original.lon),
      LatLng(current.lat, current.lon),
    );
    if (distance > kMaxNodeMovementInMeters) {
      throw ElementConflictException('Node was moved by ${distance.round()} m in the meantime.');
    }
  }
}
