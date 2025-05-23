import 'answer_constructor.dart';

/// A base class that describes the answer input and the ultimately written OSM tags.

abstract class AnswerDefinition<T> {
  final T input;

  final AnswerConstructor constructor;

  const AnswerDefinition({
    required this.input,
    required this.constructor,
  });

  static AnswerDefinition fromJSON(Map<String, dynamic> json) {
    final type = json['type'] as String;
    final input = json['input'];
    final constructor = (json['constructor'] as Map<String, dynamic>?)?.cast<String, List>();

    switch (type) {
      case 'String':
        input as Map<String, dynamic>;
        return StringAnswerDefinition(
          input: StringInputDefinition(
            min: input['min'],
            max: input['max'],
            placeholder: input['placeholder'],
          ),
          constructor: AnswerConstructor(constructor!),
        );
      case 'Number':
        input as Map<String, dynamic>;
        return NumberAnswerDefinition(
          input: NumberInputDefinition(
            decimals: input['decimals'],
            min: input['min'],
            max: input['max'],
            placeholder: input['placeholder'],
            unit: input['unit'],
          ),
          constructor: AnswerConstructor(constructor!),
        );
      case 'Duration':
        input as Map<String, dynamic>;
        final Map<String, dynamic>? days = input['days'];
        final Map<String, dynamic>? hours = input['hours'];
        final Map<String, dynamic>? minutes = input['minutes'];
        final Map<String, dynamic>? seconds = input['seconds'];

        return DurationAnswerDefinition(
          input: DurationInputDefinition(
            days: (
              step: days?['step'] ?? 1,
              display: days?['display'] ?? days != null,
              output: days?['return'] ?? days != null,
            ),
            hours: (
              step: hours?['step'] ?? 1,
              display: hours?['display'] ?? hours != null,
              output: hours?['return'] ?? hours != null,
            ),
            minutes: (
              step: minutes?['step'] ?? 1,
              display: minutes?['display'] ?? minutes != null,
              output: minutes?['return'] ?? minutes != null,
            ),
            seconds: (
              step: seconds?['step'] ?? 1,
              display: seconds?['display'] ?? seconds != null,
              output: seconds?['return'] ?? seconds != null,
            ),
            max: input['max'],
          ),
          constructor: AnswerConstructor(constructor!),
        );
      case 'Bool':
        input as List;
        return BoolAnswerDefinition(
          input: input.map<BoolInputDefinition>((item) {
            item as Map<String, dynamic>;
            return BoolInputDefinition(
              osmTags: (item['osm_tags'] as Map<String, dynamic>).cast<String, String>(),
              name: item['name'],
            );
          }),
          constructor: constructor != null ? AnswerConstructor(constructor) : null,
        );
      case 'List':
        input as List;
        return ListAnswerDefinition(
          input: input.map<ListInputDefinition>((item) {
            item as Map<String, dynamic>;
            return ListInputDefinition(
              osmTags: (item['osm_tags'] as Map<String, dynamic>).cast<String, String>(),
              name: item['name'],
              description: item['description'],
              image: item['image'],
            );
          }),
          constructor: constructor != null ? AnswerConstructor(constructor) : null,
        );
      case 'MultiList':
        input as List;
        return MultiListAnswerDefinition(
          input: input.map<ListInputDefinition>((item) {
            item as Map<String, dynamic>;
            return ListInputDefinition(
              osmTags: (item['osm_tags'] as Map<String, dynamic>).cast<String, String>(),
              name: item['name'],
              description: item['description'],
              image: item['image'],
            );
          }),
          constructor: constructor != null ? AnswerConstructor(constructor) : null,
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
  }) : min = min ?? 0,
       max = max ?? 255,
       assert(
         (min == null || min >= 0) &&
             (max == null || max >= 255) &&
             (min == null || max == null || min <= max),
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

  // This has to be separated from the individual units, because otherwise
  // incompatible states can occur. Example: minutes max : 1 & seconds max: 450

  final int? max;

  /// [step] describes the precision the user can select.
  /// [display] describes whether a dedicated time unit input should be shown to the user.
  /// [output] defines whether the time unit should be returned as a separate value in the answer constructor.

  final ({int step, bool display, bool output}) days, hours, minutes, seconds;

  const DurationInputDefinition({
    required this.days,
    required this.hours,
    required this.minutes,
    required this.seconds,
    this.max,
  });
}

class BoolAnswerDefinition extends AnswerDefinition<List<BoolInputDefinition>> {
  BoolAnswerDefinition({
    required Iterable<BoolInputDefinition> input,
    AnswerConstructor? constructor,
  }) : assert(
         input.length == 2,
         'The input of BoolAnswerDefinition must consist of exactly two entries.',
       ),
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
