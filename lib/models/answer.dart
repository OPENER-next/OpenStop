import '/models/question_input.dart';


/// A container class that holds answers for a specific question type in a readable form.
/// This is needed since parsing the answer solely from the OSM tags can lead to inconsistencies.
/// Each question input should create and return an appropriate Answer object.

abstract class Answer<T> {
  Answer({
    required this.questionValues,
    required this.value
  });

  final Map<String, QuestionInputValue> questionValues;

  final T value;

  Map<String, String> toTagMap();

  @override
  String toString() => throw UnimplementedError('Sub-classes should implement toString');
}


class StringAnswer extends Answer<String> {
  StringAnswer({
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
  String toString() => value;
}


class NumberAnswer extends Answer<double> {
  NumberAnswer({
    required Map<String, QuestionInputValue> questionValues,
    required double value
  }) : super(questionValues: questionValues, value: value);


  @override
  Map<String, String> toTagMap() {
    final tags = questionValues.values.first.osmTags;

    return tags.map((key, value) => MapEntry(
      key,
      value.replaceAll('%s', this.value.toString())
    ));
  }


  @override
  String toString() {
    final unit = questionValues.values.first.unit;
    // remove fractional part if value has no fractional part
    var numberString = (value % 1 == 0) ? value.toStringAsFixed(0) : value.toString();

    if (unit != null) {
      numberString += ' $unit';
    }
    return numberString;
  }
}


class BoolAnswer extends Answer<bool> {
  BoolAnswer({
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
  String toString() {
    final boolString = value.toString();
    return questionValues[boolString]?.name ?? (value ? 'Ja' : 'Nein');
  }
}


class ListAnswer extends Answer<String> {
  ListAnswer({
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
  String toString() => questionValues[value]?.name ?? value;
}


class DurationAnswer extends Answer<Duration> {
  DurationAnswer({
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
