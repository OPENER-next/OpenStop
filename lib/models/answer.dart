import '/models/question_input.dart';


/// A container class that holds answers for a specific question type in a readable form.
/// This is needed since parsing the answer solely from the OSM tags can lead to inconsistencies.
/// Each question input should create and return an appropriate Answer object.

abstract class Answer<T> {
  const Answer({
    required this.questionValues,
    required this.value
  });

  final Map<String, QuestionInputValue> questionValues;

  final T value;

  /// Build OSM tags based on the given value.

  Map<String, String> toTagMap();

  /// Whether the value of this answer is valid or not.

  bool get isValid;

  @override
  String toString() => throw UnimplementedError('Sub-classes should implement toString');
}


class StringAnswer extends Answer<String> {
  const StringAnswer({
    required Map<String, QuestionInputValue> questionValues,
    required String value
  }) : super(questionValues: questionValues, value: value);


  @override
  Map<String, String> toTagMap() {
    final tags = questionValues.values.first.osmTags;

    return tags.map((key, value) => MapEntry(
      key,
      value.replaceAll('%s', this.value)
    ));
  }


  @override
  bool get isValid {
    final questionInputValue = questionValues.values.first;

    final min = (questionInputValue.min ?? 1).clamp(1, 255);
    final max = (questionInputValue.max ?? 255).clamp(1, 255);

    return value.length >= min && value.length <= max;
  }


  @override
  String toString() => value;
}


/// Use string instead of double to avoid precision errors

class NumberAnswer extends Answer<String> {
  const NumberAnswer({
    required Map<String, QuestionInputValue> questionValues,
    required String value
  }) : super(questionValues: questionValues, value: value);


  @override
  Map<String, String> toTagMap() {
    final tags = questionValues.values.first.osmTags;

    return tags.map((key, value) => MapEntry(
      key,
      value.replaceAll('%s', this.value)
    ));
  }


  @override
  bool get isValid {
    final questionInputValue = questionValues.values.first;

    var allowRegexString = '([1-9]\\d*|0?)';
    if (questionInputValue.decimals == null) {
      allowRegexString += '([,.]\\d*)?';
    }
    else if (questionInputValue.decimals! > 0) {
      allowRegexString += '([,.]\\d{0,$questionInputValue.decimals})?';
    }
    if (!RegExp(allowRegexString).hasMatch(value)) {
      return false;
    }

    final numValue = double.tryParse(value);
    if (numValue != null) {
      if (questionInputValue.min != null && numValue < questionInputValue.min!) {
        return false;
      }
      if (questionInputValue.max != null && questionInputValue.max! < numValue) {
        return false;
      }
      return true;
    }
    return false;
  }


  @override
  String toString() {
    final unit = questionValues.values.first.unit;
    return (unit == null) ? value : '$value $unit';
  }
}


class BoolAnswer extends Answer<bool> {
  const BoolAnswer({
    required Map<String, QuestionInputValue> questionValues,
    required bool value
  }) : super(questionValues: questionValues, value: value);


  @override
  Map<String, String> toTagMap() {
    final tags = questionValues[value.toString()]?.osmTags;

    if (tags == null) {
      return const <String, String>{};
    }

    return Map.of(tags);
  }


  @override
  bool get isValid => true;


  @override
  String toString() {
    final boolString = value.toString();
    return questionValues[boolString]?.name ?? (value ? 'Ja' : 'Nein');
  }
}


class ListAnswer extends Answer<String> {
  const ListAnswer({
    required Map<String, QuestionInputValue> questionValues,
    required String value
  }) : super(questionValues: questionValues, value: value);


  @override
  Map<String, String> toTagMap() {
    final tags = questionValues[value]?.osmTags;

    if (tags == null) {
      return const <String, String>{};
    }

    return Map.of(tags);
  }


  @override
  bool get isValid => true;


  @override
  String toString() => questionValues[value]?.name ?? value;
}


class DurationAnswer extends Answer<Duration> {
  const DurationAnswer({
    required Map<String, QuestionInputValue> questionValues,
    required Duration value
  }) : super(questionValues: questionValues, value: value);


  @override
  Map<String, String> toTagMap() {
    final tags = questionValues.values.first.osmTags;
    return tags.map((key, value) {
      final hours = this.value.inHours.toString().padLeft(2, '0');
      final minutes = (this.value.inMinutes % 60).toString().padLeft(2, '0');
      final seconds = (this.value.inSeconds % 60).toString().padLeft(2, '0');

      return MapEntry(
        key,
        value.replaceAll(
          RegExp(r'%s'),
         '$hours:$minutes:$seconds'
        )
      );
    });
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
