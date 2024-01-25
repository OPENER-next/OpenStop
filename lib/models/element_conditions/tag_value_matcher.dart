// SPDX-License-Identifier: GPL-3.0-or-later

import 'element_condition.dart';

/// Matcher base class for OSM tag values.

abstract class TagValueMatcher<T> extends Matcher<T, String?> {
  const TagValueMatcher(super.characteristics);
}

/// Matches if an OSM tag value is null (which means the tag is unset).

class EmptyValueMatcher extends TagValueMatcher<void> {
  const EmptyValueMatcher() : super(null);

  @override
  bool matches(String? sample) => sample == null;
}

/// Matches any OSM tag value as long as it is not null (which means the tag exists).

class NotEmptyValueMatcher extends TagValueMatcher<void> {
  const NotEmptyValueMatcher() : super(null);

  @override
  bool matches(String? sample) => sample != null;
}

/// Matches if the OSM tag value equals a given string.

class StringValueMatcher extends TagValueMatcher<String> {
  const StringValueMatcher(super.characteristics);

  @override
  bool matches(String? sample) => sample == characteristics;
}

/// Matches if the OSM tag value matches a given regex pattern.

class RegexValueMatcher extends TagValueMatcher<RegExp> {
  const RegexValueMatcher(super.characteristics);

  @override
  bool matches(String? sample) {
    return sample != null && characteristics.hasMatch(sample);
  }
}

/// Matches if the OSM tag value matches any of the given [TagValueMatcher]s.

class MultiValueMatcher extends TagValueMatcher<List<TagValueMatcher>> {
  const MultiValueMatcher(super.characteristics);

  @override
  bool matches(String? sample) {
    return characteristics.any((matcher) => matcher.matches(sample));
  }
}
