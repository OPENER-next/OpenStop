import 'package:intl/intl.dart';

import '/l10n/app_localizations.g.dart';
import 'question_catalog/answer_definition.dart';

/// A container class that holds answers for a specific question type in a readable form.
/// This is needed since parsing the answer solely from the OSM tags can lead to inconsistencies.
/// Each question input should create and return an appropriate Answer object.
///
/// An answer is based on an [AnswerDefinition] and a `value` of any type.

abstract class Answer<D extends AnswerDefinition, T> {
  const Answer({required this.definition, required this.value});

  final D definition;

  final T value;

  /// The OSM tag to variable mapping.
  /// This resolves the values for a given tag used in the constructor for creating the final OSM tags.
  ///
  /// The following example defines two values for the `operator` tag:
  /// `{ 'operator': [ 'value1', 'value2' ] }`
  ///
  /// Every answer needs to implement this.

  Iterable<String> _resolve(String key);

  /// Build OSM tags based on the given value.

  Map<String, String> toTagMap() {
    return definition.constructor.construct(_resolve);
  }

  /// Whether the value of this answer is valid or not.

  bool get isValid;

  String toLocaleString(AppLocalizations appLocale);
}

class StringAnswer extends Answer<StringAnswerDefinition, String> {
  const StringAnswer({
    required super.definition,
    required super.value,
  });

  @override
  Iterable<String> _resolve(String key) sync* {
    yield value;
  }

  @override
  bool get isValid {
    final min = definition.input.min;
    final max = definition.input.max;
    return value.length >= min && value.length <= max;
  }

  @override
  String toLocaleString(AppLocalizations appLocale) => value;
}

/// Use string instead of double to avoid precision errors

class NumberAnswer extends Answer<NumberAnswerDefinition, String> {
  const NumberAnswer({
    required super.definition,
    required super.value,
  });

  @override
  Iterable<String> _resolve(String key) sync* {
    // replace decimal comma with period
    yield value.replaceAll(',', '.');
  }

  @override
  bool get isValid {
    // replace decimal comma with period
    final value = this.value.replaceAll(',', '.');
    // match either a single 0 or negative/positive numbers not starting with 0
    final allowRegexStringBuilder = StringBuffer(r'^(0|-?[1-9]\d*');
    // match an unlimited amount of decimal places
    if (definition.input.decimals == null) {
      allowRegexStringBuilder.write(r'|-?\d+\.\d+');
    }
    // match a specific amount of decimal places
    else if (definition.input.decimals! > 0) {
      allowRegexStringBuilder
        ..write(r'|-?\d+\.\d{1,')
        ..write(definition.input.decimals)
        ..write('}');
    }
    allowRegexStringBuilder.write(r')$');
    if (!RegExp(allowRegexStringBuilder.toString()).hasMatch(value)) {
      return false;
    }

    final numValue = double.tryParse(value);
    if (numValue != null) {
      if (definition.input.min != null && numValue < definition.input.min!) {
        return false;
      }
      if (definition.input.max != null && definition.input.max! < numValue) {
        return false;
      }
      return true;
    }
    return false;
  }

  @override
  String toLocaleString(AppLocalizations appLocale) {
    final unit = definition.input.unit;
    return (unit == null) ? value : '$value $unit';
  }
}

class BoolAnswer extends Answer<BoolAnswerDefinition, bool> {
  const BoolAnswer({
    required super.definition,
    required super.value,
  });

  @override
  Iterable<String> _resolve(String key) sync* {
    // return matching tag value of the selected answer if any
    final tags = definition.input[_valueIndex].osmTags;
    final tagValue = tags[key];
    if (tagValue != null) yield tagValue;
  }

  @override
  bool get isValid => true;

  int get _valueIndex => value ? 0 : 1;

  @override
  String toLocaleString(AppLocalizations appLocale) {
    return definition.input[_valueIndex].name ?? (value ? appLocale.yes : appLocale.no);
  }
}

class ListAnswer extends Answer<ListAnswerDefinition, int> {
  const ListAnswer({
    required super.definition,
    required super.value,
  });

  @override
  Iterable<String> _resolve(String key) sync* {
    // return matching tag value of the selected answer if any
    final tags = definition.input[value].osmTags;
    final tagValue = tags[key];
    if (tagValue != null) yield tagValue;
  }

  @override
  bool get isValid => value >= 0 && value < definition.input.length;

  @override
  String toLocaleString(AppLocalizations appLocale) => definition.input[value].name;
}

/// Storing the selected indexes in a [List]
/// (instead of having a fixed List of booleans or storing it bitwise using a single integer)
/// has the benefit of remembering the user input order.

class MultiListAnswer extends Answer<ListAnswerDefinition, List<int>> {
  MultiListAnswer({
    required super.definition,
    required super.value,
  });

  @override
  Iterable<String> _resolve(String key) sync* {
    for (final index in value) {
      final tags = definition.input[index].osmTags;
      final tagValue = tags[key];
      if (tagValue != null) yield tagValue;
    }
  }

  @override
  bool get isValid {
    return value.isNotEmpty &&
        value.length <= definition.input.length &&
        value.every((index) => index >= 0 && index < definition.input.length);
  }

  @override
  String toLocaleString(AppLocalizations appLocale) =>
      value.map((index) => definition.input[index].name).join(', ');
}

class DurationAnswer extends Answer<DurationAnswerDefinition, Duration> {
  const DurationAnswer({
    required super.definition,
    required super.value,
  });

  @override
  Iterable<String> _resolve(String key) => _values.map((v) {
    final formatter = NumberFormat()
      ..minimumFractionDigits = 0
      ..maximumFractionDigits = 3;
    return formatter.format(v);
  });

  /// Returns days, hours, minutes and seconds in the specified order.
  ///
  /// Whether the duration part is returned depends on the DurationInputDefinition.

  Iterable<num> get _values sync* {
    var (fractionalDays, fractionalHours, fractionalMinutes) = (0.0, 0.0, 0.0);

    // calculate remainder as decimal if any (result will be 0 if none is required)
    // required to handle cases where input and output differs
    // e.g. user is able to input hours, minutes, seconds, but the output is only in hours

    if (definition.input.seconds.output) {
      // noop
    } else if (definition.input.minutes.output) {
      fractionalMinutes = (value.inSeconds % Duration.secondsPerMinute) / Duration.secondsPerMinute;
    } else if (definition.input.hours.output) {
      fractionalHours = (value.inSeconds % Duration.secondsPerHour) / Duration.secondsPerHour;
    } else if (definition.input.days.output) {
      fractionalDays = (value.inSeconds % Duration.secondsPerDay) / Duration.secondsPerDay;
    }

    // wrap duration parts according to the units present in the output

    final maxInteger = double.maxFinite.toInt();
    var (wrapHours, wrapMinutes, wrapSeconds) = (maxInteger, maxInteger, maxInteger);

    if (definition.input.days.output) {
      wrapHours = Duration.hoursPerDay;
      wrapMinutes = Duration.minutesPerDay;
      wrapSeconds = Duration.secondsPerDay;
      yield value.inDays + fractionalDays;
    }
    if (definition.input.hours.output) {
      wrapMinutes = Duration.minutesPerHour;
      wrapSeconds = Duration.secondsPerHour;
      yield (value.inHours % wrapHours) + fractionalHours;
    }
    if (definition.input.minutes.output) {
      wrapSeconds = Duration.secondsPerMinute;
      yield (value.inMinutes % wrapMinutes) + fractionalMinutes;
    }
    if (definition.input.seconds.output) {
      yield value.inSeconds % wrapSeconds;
    }
  }

  @override
  bool get isValid => true;

  @override
  String toLocaleString(AppLocalizations appLocale) {
    final days = value.inDays;
    final hours = value.inHours % Duration.hoursPerDay;
    final minutes = value.inMinutes % Duration.minutesPerHour;
    final seconds = value.inSeconds % Duration.secondsPerMinute;

    return () sync* {
      if (days > 0) yield appLocale.days(days);
      if (hours > 0) yield appLocale.hours(hours);
      if (minutes > 0) yield appLocale.minutes(minutes);
      if (seconds > 0) yield appLocale.seconds(seconds);
    }().join(' ');
  }
}
