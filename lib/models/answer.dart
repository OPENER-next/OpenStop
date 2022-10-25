import 'question_catalog/answer_definition.dart';


/// A container class that holds answers for a specific question type in a readable form.
/// This is needed since parsing the answer solely from the OSM tags can lead to inconsistencies.
/// Each question input should create and return an appropriate Answer object.
///
/// An answer is based on an [AnswerDefinition] and a `value` of any type.

abstract class Answer<D extends AnswerDefinition, T> {
  const Answer({
    required this.definition,
    required this.value
  });

  final D definition;

  final T value;

  /// The OSM tag to variable mapping.
  /// This defines the values per tag used in the constructor for creating the final OSM tags.
  ///
  /// The following example defines two values for the `operator` tag:
  /// `{ 'operator': [ 'value1', 'value2' ] }`
  ///
  /// Every answer needs to implement this.

  Map<String, Iterable<String>> get _variables;

  /// Build OSM tags based on the given value.

  Map<String, String> toTagMap() {
    return definition.constructor.construct(_variables);
  }

  /// Whether the value of this answer is valid or not.

  bool get isValid;

  @override
  String toString() => throw UnimplementedError('Sub-classes must implement toString');
}


class StringAnswer extends Answer<StringAnswerDefinition, String> {
  const StringAnswer({
    required super.definition,
    required super.value,
  });

  @override
  Map<String, Iterable<String>> get _variables {
    // assign every tag used in the constructor the input value of this answer
    final keys = definition.constructor.tagConstructorDef.keys;
    return <String, Iterable<String>>{
      for (final key in keys) key : [ value ]
    };
  }

  @override
  bool get isValid {
    final min = definition.input.min;
    final max = definition.input.max;
    return value.length >= min && value.length <= max;
  }

  @override
  String toString() => value;
}


/// Use string instead of double to avoid precision errors

class NumberAnswer extends Answer<NumberAnswerDefinition, String> {
  const NumberAnswer({
    required super.definition,
    required super.value,
  });

  @override
  Map<String, Iterable<String>> get _variables {
    // assign every tag used in the constructor the input value of this answer
    final keys = definition.constructor.tagConstructorDef.keys;
    return <String, Iterable<String>>{
      // replace decimal comma with period
      for (final key in keys) key : [ value.replaceAll(',', '.') ]
    };
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
      ..write(r'|-?\d+\.\d{1,')..write(definition.input.decimals)..write(r'}');
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
  String toString() {
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
  Map<String, Iterable<String>> get _variables {
    // transform all tags of the selected answer to the variable mapping structure
    final tags = definition.input[_valueIndex].osmTags.entries;
    return <String, Iterable<String>>{
      for (final tag in tags) tag.key : [ tag.value ]
    };
  }

  @override
  bool get isValid => true;

  int get _valueIndex => value ? 0 : 1;

  @override
  String toString() {
    return definition.input[_valueIndex].name ?? (value ? 'Ja' : 'Nein');
  }
}


class ListAnswer extends Answer<ListAnswerDefinition, int> {
  const ListAnswer({
    required super.definition,
    required super.value,
  });

  @override
  Map<String, Iterable<String>> get _variables {
    // transform all tags of the selected answer to the variable mapping structure
    final tags = definition.input[value].osmTags.entries;
    return <String, Iterable<String>>{
      for (final tag in tags) tag.key : [ tag.value ]
    };
  }

  @override
  bool get isValid => value >= 0 && value < definition.input.length;

  @override
  String toString() => definition.input[value].name;
}


class MultiListAnswer extends Answer<ListAnswerDefinition, List<int>> {
  MultiListAnswer({
    required super.definition,
    required super.value,
  });

  @override
  Map<String, Iterable<String>> get _variables {
    // combine all tags of the selected answers
    final map = <String, List<String>>{};
    for (final index in value) {
      for (final tag in definition.input[index].osmTags.entries) {
        map.update(tag.key,
          (value) => value..add(tag.value),
          ifAbsent: () => [ tag.value ],
        );
      }
    }
    return map;
  }

  @override
  bool get isValid {
    return value.isNotEmpty && value.length <= definition.input.length &&
    value.every((index) => index >= 0 && index < definition.input.length);
  }

  @override
  String toString() => value.map((index) => definition.input[index].name).join(', ');
}


class DurationAnswer extends Answer<DurationAnswerDefinition, Duration> {
  const DurationAnswer({
    required super.definition,
    required super.value
  });

  @override
  Map<String, Iterable<String>> get _variables {
    // assign every tag used in the constructor the input value of this answer
    final keys = definition.constructor.tagConstructorDef.keys;
    return <String, Iterable<String>>{
      for (final key in keys) key : [ _valueAsHMS() ]
    };
  }

  String _valueAsHMS() {
    final hours = value.inHours.toString().padLeft(2, '0');
    final minutes = (value.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (value.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  @override
  bool get isValid => true;

  @override
  String toString() {
    var durationString = '';
    final days = value.inDays;
    final hours = value.inHours % 24;
    final minutes = value.inMinutes % 60;
    final seconds = value.inSeconds % 60;

    durationString += _buildDurationPartStringByUnit(days, 'Tag', 'Tage');
    durationString += _buildDurationPartStringByUnit(hours, 'Stunde', 'Stunden');
    durationString += _buildDurationPartStringByUnit(minutes, 'Minute', 'Minuten');
    durationString += _buildDurationPartStringByUnit(seconds, 'Sekunde', 'Sekunden');
    // always remove first white space
    return durationString.substring(1);
  }


  String _buildDurationPartStringByUnit(int count, String singular, String plural) {
    if (count > 1) {
      return ' $count $plural';
    }
    if (count > 0) {
      return ' $count $singular';
    }
    return '';
  }
}
