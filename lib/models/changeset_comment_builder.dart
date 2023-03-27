import 'element_variants/base_element.dart';
import 'map_feature_collection.dart';
import 'stop.dart';
import 'stop_area.dart';


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
    final stopNames = _getStopNames(stopArea.stops);

    var countElementNames = mapFeatureNames.length;
    var countStopNames = stopNames.length;
    var finalString = _buildString(mapFeatureNames, stopNames);

    // prevent changeset comment from getting larger than 255 characters
    // try to reduce the string length step by step
    while (finalString.length > 255) {
      // try to reduce the string length by removing terms step by step
      if (countElementNames > 1 || countStopNames > 1) {
        var elementStrings = mapFeatureNames;
        var stopStrings = stopNames;

        if (countElementNames > 1) {
          elementStrings = elementStrings.take(--countElementNames);
        }
        else {
          stopStrings = stopStrings.take(--countStopNames);
        }
        // append "more" string if any term was removed
        if (countElementNames < mapFeatureNames.length) {
          elementStrings = elementStrings.followedBy(moreStringAsIterable);
        }
        if (countStopNames < stopNames.length) {
          stopStrings = stopStrings.followedBy(moreStringAsIterable);
        }
        finalString = _buildString(elementStrings, stopStrings);
      }
      // hard truncate string
      else {
        finalString = finalString.substring(0, 255);
      }
    }
    return finalString;
  }


  /// Build changeset comment string based on given map feature names and stop names.

  String _buildString(Iterable<String> mapFeatureNames, Iterable<String> stopNames) {
    const mainString = 'Details zu %s im Haltestellenbereich %s hinzugefügt.';

    String mapFeaturesString;
    mapFeaturesString = _concat(mapFeatureNames, conjunctionString: ' und ');
    // fallback name string
    if (mapFeaturesString.isEmpty) mapFeaturesString = 'Element';

    final stopsString = _concat(stopNames, conjunctionString: ' und ');

    return mainString
      .replaceFirst('%s', mapFeaturesString)
      .replaceFirst('%s', stopsString)
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

  Iterable<String> _getStopNames(Iterable<Stop> stops) {
    // use set to automatically remove duplicates
    return Set<String>.from(
      stops
      .where((stop) => stop.name.isNotEmpty)
      .map((stop) => stop.name)
    );
  }
}
