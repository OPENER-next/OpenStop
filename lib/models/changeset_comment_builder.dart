import 'element_variants/base_element.dart';
import 'map_feature_collection.dart';
import 'stop_area_processing/stop.dart';
import 'stop_area_processing/stop_area.dart';


/// Build the changeset comment based on the surrounding stop area and changed osm elements.
///
/// OSM element names are taken from the [MapFeatureCollection].

class ChangesetCommentBuilder {
  final MapFeatureCollection mapFeatureCollection;
  final StopArea stopArea;
  final Iterable<ProcessedElement> modifiedElements;

  const ChangesetCommentBuilder({
    required this.mapFeatureCollection,
    required this.stopArea,
    required this.modifiedElements,
  });


  /// Changeset comment string.

  @override
  String toString() {
    const moreStringAsIterable = ['mehr'];

    final mapFeatureNames = _getElementNames(modifiedElements);
    final stopName = _getMostCommonStopName(stopArea.stops);

    var countElementNames = mapFeatureNames.length;
    var finalString = _buildString(mapFeatureNames, stopName);

    // prevent changeset comment from getting larger than 255 characters
    // try to reduce the string length step by step
    while (finalString.length > 255) {
      // try to reduce the string length by removing terms step by step
      if (countElementNames > 1) {
        var elementStrings = mapFeatureNames;

        if (countElementNames > 1) {
          elementStrings = elementStrings.take(--countElementNames);
        }
        // append "more" string if any term was removed
        if (countElementNames < mapFeatureNames.length) {
          elementStrings = elementStrings.followedBy(moreStringAsIterable);
        }
        finalString = _buildString(elementStrings, stopName);
      }
      // hard truncate string
      else {
        finalString = finalString.substring(0, 255);
      }
    }
    return finalString;
  }


  /// Build changeset comment string based on given map feature names and stop names.

  String _buildString(Iterable<String> mapFeatureNames, String? stopName) {
    const mainString = 'Details zu %s im Haltestellenbereich %s hinzugefügt.';

    String mapFeaturesString;
    mapFeaturesString = _concat(mapFeatureNames, conjunctionString: ' und ');
    // fallback name string
    if (mapFeaturesString.isEmpty) mapFeaturesString = 'Element';

    final stopString = stopName ?? '';

    return mainString
      .replaceFirst('%s', mapFeaturesString)
      .replaceFirst('%s', stopString)
      // replace all double spaces that might occur when the value of any %s is empty
      .replaceAll(RegExp('\\s+'), ' ');
  }


  /// Concatenate a list of strings/words based on a separator and conjunction string.

  String _concat(Iterable<String> stringList, {
    String separatorString = ', ',
    String conjunctionString = ' and ',
  }) {
    if (stringList.length > 1) {
      // concatenate all elements except the last element
      return stringList.take(stringList.length - 1).join(separatorString)
      // add last element with conjunction string
      + conjunctionString + stringList.last;
    }
    return stringList.join(separatorString);
  }


  /// Matches the given elements to a corresponding map feature if any and
  /// extracts their names while filtering duplicates.

  Iterable<String> _getElementNames(Iterable<ProcessedElement> elements) {
    // use set to automatically remove duplicates
    return Set<String>.from(
      elements
      .map((element) => mapFeatureCollection.getMatchingFeature(element)?.name)
      // filter null for elements that do not have a matching MapFeature
      .whereType<String>()
    );
  }


  /// Extracts the names of multiple stops while filtering duplicates.

  String? _getMostCommonStopName(Set<Stop> stops) {
    final stopNameCount = <String, int>{};

    for (final stop in stops) {
      stopNameCount.update(
        stop.name,
        (value) => value + 1,
        ifAbsent: () => 0,
      );
    }

    if (stopNameCount.isEmpty) return null;

    return stopNameCount.entries.reduce(
      (acc, cur) => cur.value > acc.value ? cur : acc
    ).key;
  }
}
