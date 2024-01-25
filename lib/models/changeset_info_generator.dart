// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:ui';

import 'package:latlong2/latlong.dart';

import '/api/offline_geocoder.g.dart';
import '/commons/country_language_map.dart';
import 'element_variants/base_element.dart';
import 'map_features/map_features.dart';
import 'stop_area_processing/stop.dart';
import 'stop_area_processing/stop_area.dart';
import '/commons/app_config.dart' as app_config;

import 'package:flutter_gen/gen_l10n/app_localizations.dart';


/// Holds any desired changeset information.

class ChangesetInfo {
  /// Name or identifier of the software that created the changes.
  final String createdBy;

  /// Describes how the data was collected.
  final String source;

  /// Language of the editor UI.
  final String locale;

  /// Textual description of the changes.
  final String comment;

  ChangesetInfo({
    required this.comment,
    this.createdBy = '${app_config.appName} ${app_config.appVersion}',
    this.source = 'survey',
    this.locale = 'en',
  });

  Map<String, String> asMap() => {
    'created_by': createdBy,
    'source': source,
    'locale': locale,
    'comment': comment,
  };
}


/// Build the changeset comment based on the surrounding stop area and changed osm elements.
///
/// OSM element names are taken from the [MapFeatureCollection].

class ChangesetCommentGenerator {

  final Iterable<String> mapFeatureNames;

  final String? stopName;

  final AppLocalizations localizations;

  ChangesetCommentGenerator({
    required this.mapFeatureNames,
    required this.stopName,
    required this.localizations,
  });


  factory ChangesetCommentGenerator.fromContext({
    required StopArea stopArea,
    required Iterable<ProcessedElement> modifiedElements,
    required List<Locale> userLocales,
  }) {
    final localizations = _getCommentLocalizations(
      modifiedElements.firstOrNull?.geometry.center,
      userLocales,
    );
    final mapFeatureNames = _getElementNames(modifiedElements, localizations);
    final stopName = _getMostCommonStopName(stopArea.stops);

    return ChangesetCommentGenerator(
      mapFeatureNames: mapFeatureNames,
      stopName: stopName,
      localizations: localizations,
    );
  }

  /// Builds the final comment string.

  @override
  String toString() {
    var countElementNames = mapFeatureNames.length;
    var finalString = _generateComment(mapFeatureNames, stopName);

    // prevent changeset comment from getting larger than 255 characters
    // try to reduce the string length step by step
    while (finalString.length > 255) {
      // try to reduce the string length by removing terms step by step
      if (countElementNames > 1) {
        final elementStrings = mapFeatureNames
          .take(--countElementNames)
          .followedBy([localizations.more]); // append "more" string
        finalString = _generateComment(elementStrings, stopName);
      }
      // hard truncate string
      else {
        finalString = finalString.substring(0, 255);
      }
    }
    return finalString;
  }

  /// Build changeset comment string based on given map feature names and stop names.

  String _generateComment(Iterable<String> mapFeatureNames, String? stopName) {
    var mapFeaturesString = _concat(mapFeatureNames, conjunctionString: ' ${localizations.and} ');
    if (mapFeaturesString.isEmpty) mapFeaturesString = localizations.element;

    return stopName != null
      ? localizations.changesetWithStopNameText(mapFeaturesString, stopName)
      : localizations.changesetWithoutStopNameText(mapFeaturesString);
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

  static Set<String> _getElementNames(Iterable<ProcessedElement> elements, AppLocalizations localizations) {
    // use set to automatically remove duplicates
    return Set<String>.unmodifiable(
      elements.map(
        (element) => MapFeatures().representElement(element).genericLabel(localizations),
      ),
    );
  }

  /// Extracts the names of multiple stops while filtering duplicates.

  static String? _getMostCommonStopName(Set<Stop> stops) {
    final stopNameCount = <String, int>{};

    for (final stop in stops) {
      if (stop.name.isNotEmpty) {
        stopNameCount.update(
          stop.name,
          (value) => value + 1,
          ifAbsent: () => 0,
        );
      }
    }

    if (stopNameCount.isEmpty) return null;

    return stopNameCount.entries.reduce(
      (acc, cur) => cur.value > acc.value ? cur : acc
    ).key;
  }

  /// The changeset language is derived from the country/region the edit/changeset is made.
  /// It also must be one of the user's system languages.
  /// Otherwise english will be used.

  static AppLocalizations _getCommentLocalizations(LatLng? location, List<Locale> userLocales) {
    // fallback language delegate
    final en = lookupAppLocalizations(const Locale('en'));

    if (location == null) return en;
    final country = GeoCoder.getFromLocation(location);
    // fallback to en if no country was found for element location
    if (country == null) return en;

    final locales = countryToLanguageMapping[country.isoA2];
    // fallback to en if the country is not in the country-language-map
    if (locales == null) return en;

    for (final language in locales) {
      final locale = Locale(language, country.isoA2);
      // use country locale if the language is supported by the app
      // and equals one of the user's UI languages (assuming the user speaks the language)
      final isUserLocale = userLocales.any(
        (userLocale) => userLocale.languageCode == locale.languageCode,
      );
      if (AppLocalizations.delegate.isSupported(locale) && isUserLocale) {
        return lookupAppLocalizations(locale);
      }
    }
    return en;
  }
}
