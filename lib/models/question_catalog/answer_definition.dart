import 'answer_constructor.dart';

/// A base class that describes the answer input and the ultimately written OSM tags.

class AnswerDefinition<T> {

  final T input;

  final AnswerConstructor constructor;

  const AnswerDefinition({
    required this.input,
    required this.constructor,
  });

  static AnswerDefinition fromJSON(Map<String, dynamic> json) {
    final type = json['type'];
    final input = json['input'];

    switch (type) {
      case 'String': return StringAnswerDefinition(
        input: StringInputDefinition(
          min: input['min'],
          max: input['max'],
          placeholder: input['placeholder'],
        ),
        constructor: AnswerConstructor(json['constructor'].map<String, List<String>>(
          (key, value) => MapEntry<String, List<String>>(key, value.cast<String>()),
        )),
      );
      case 'Number': return NumberAnswerDefinition(
        input: NumberInputDefinition(
          decimals: input['decimals'],
          min: input['min'],
          max: input['max'],
          placeholder: input['name'],
          unit: input['unit'],
        ),
        constructor: AnswerConstructor(json['constructor'].map<String, List<String>>(
          (key, value) => MapEntry<String, List<String>>(key, value.cast<String>()),
        )),
      );
      case 'Duration': return DurationAnswerDefinition(
        input: DurationInputDefinition(
          max: input['max'],
          daysStepSize: input['unit_step']?['days'],
          hoursStepSize: input['unit_step']?['hours'],
          minutesStepSize: input['unit_step']?['minutes'],
          secondsStepSize: input['unit_step']?['seconds'],
        ),
        constructor: AnswerConstructor(json['constructor'].map<String, List<String>>(
          (key, value) => MapEntry<String, List<String>>(key, value.cast<String>()),
        )),
      );
      case 'Bool': return BoolAnswerDefinition(
        input: input.map<BoolInputDefinition>((item) {
          return BoolInputDefinition(
            osmTags: item['osm_tags'].cast<String, String>(),
            name: item['name']
          );
        }),
        constructor: json['constructor'] != null
          ? AnswerConstructor(json['constructor'].map<String, List<String>>(
            (key, value) => MapEntry<String, List<String>>(key, value.cast<String>()),
          ))
          : null,
      );
      case 'List': return ListAnswerDefinition(
        input: input.map<ListInputDefinition>((item) {
          return ListInputDefinition(
            osmTags: item['osm_tags'].cast<String, String>(),
            name: item['name'],
            description: item['description'],
            image: item['image'],
          );
        }),
        constructor: json['constructor'] != null
          ? AnswerConstructor(json['constructor'].map<String, List<String>>(
            (key, value) => MapEntry<String, List<String>>(key, value.cast<String>()),
          ))
          : null,
      );
      case 'MultiList': return MultiListAnswerDefinition(
        input: input.map<ListInputDefinition>((item) {
          return ListInputDefinition(
            osmTags: item['osm_tags'].cast<String, String>(),
            name: item['name'],
            description: item['description'],
            image: item['image'],
          );
        }),
        constructor: json['constructor'] != null
          ? AnswerConstructor(json['constructor'].map<String, List<String>>(
            (key, value) => MapEntry<String, List<String>>(key, value.cast<String>()),
          ))
          : null,
      );
      default:
        throw UnsupportedError('The question input type "$type" is not supported.');
    }
  }
}

/// Classes that implement this hold any input restrictions or possible answer values.

abstract class InputDefinition {
  const InputDefinition();
}


class StringAnswerDefinition extends AnswerDefinition<StringInputDefinition> {
  const StringAnswerDefinition({
    required super.input,
    required super.constructor,
  });
}

class StringInputDefinition implements InputDefinition {
  final int min;
  final int max;
  final String? placeholder;

  const StringInputDefinition({
    int? min = 0,
    int? max = 255,
    this.placeholder,
  }) :
    min = min ?? 0,
    max = max ?? 255,
    assert(
      (min == null || min >= 0) && (max == null || max >= 255) && (min == null || max == null || min <= max),
      'The min and max properties must define a range between 0 and 255.',
    );
}


class NumberAnswerDefinition extends AnswerDefinition<NumberInputDefinition> {
  const NumberAnswerDefinition({
    required super.input,
    required super.constructor,
  });
}

class NumberInputDefinition implements InputDefinition {
  /// If decimals = null, there is no limit of decimal places.
  final int? decimals;
  /// If min = null, there is no lower bound for input number values.
  final int? min;
  /// If max = null, there is no upper bound for input number values.
  final int? max;
  final String? placeholder;
  final String? unit;

  const NumberInputDefinition({
    this.decimals,
    this.min,
    this.max,
    this.placeholder,
    this.unit,
  }) : assert(min == null || max == null || min < max, 'The min value must be smaller than max.');
}


class DurationAnswerDefinition extends AnswerDefinition<DurationInputDefinition> {
  const DurationAnswerDefinition({
    required super.input,
    required super.constructor,
  });
}

class DurationInputDefinition implements InputDefinition {
  /// The maximum allowed value for the biggest unit.

  final int? max;

  /// The step size of each time unit. A step size of `0` means the time unit is omitted.

  final int daysStepSize, hoursStepSize, minutesStepSize, secondsStepSize;

  const DurationInputDefinition({
    this.max,
    int? daysStepSize,
    int? hoursStepSize,
    int? minutesStepSize,
    int? secondsStepSize,
  }) :
    daysStepSize = daysStepSize ?? 0,
    hoursStepSize = hoursStepSize ?? 0,
    minutesStepSize = minutesStepSize ?? 0,
    secondsStepSize = secondsStepSize ?? 0;
}


class BoolAnswerDefinition extends AnswerDefinition<List<BoolInputDefinition>> {
  BoolAnswerDefinition({
    required Iterable<BoolInputDefinition> input,
    AnswerConstructor? constructor,
  }) :
    assert(input.length == 2, 'The input of BoolAnswerDefinition must consist of exactly two entries.'),
    super(
      input: List.unmodifiable(input),
      constructor: constructor ?? AnswerConstructor.fromTags(input.map((item) => item.osmTags)),
    );
}

class BoolInputDefinition implements InputDefinition {
  final Map<String, String> osmTags;
  final String? name;

  const BoolInputDefinition({
    required this.osmTags,
    this.name,
  });
}


class ListAnswerDefinition extends AnswerDefinition<List<ListInputDefinition>> {
  ListAnswerDefinition({
    required Iterable<ListInputDefinition> input,
    AnswerConstructor? constructor,
  }) : super(
    input: List.unmodifiable(input),
    constructor: constructor ?? AnswerConstructor.fromTags(input.map((item) => item.osmTags)),
  );
}

class ListInputDefinition implements InputDefinition {
  final Map<String, String> osmTags;
  final String name;
  final String? description;
  final String? image;

  const ListInputDefinition({
    required this.osmTags,
    required this.name,
    this.description,
    this.image,
  });
}


class MultiListAnswerDefinition extends ListAnswerDefinition {
  MultiListAnswerDefinition({
    required super.input,
    super.constructor,
  });
}
