/// This class holds the input restrictions and possible values of a [Question].

class QuestionInput {
  final String type;

  final Map<String, QuestionInputValue> values;

  final String unit;
  /// If decimals = null, there is no limit of decimal places.
  final int? decimals;
  /// If min = null, there is no lower bound for input number values.
  final int? min;
  /// If max = null, there is no upper bound for input number values.
  final int? max;

  const QuestionInput({
    required this.type,
    required this.values,
    this.unit = '',
    this.decimals,
    this.min,
    this.max
  });


  factory QuestionInput.fromJSON(Map<String, dynamic> json) =>
    QuestionInput(
      type: json['type'],
      values: json['values'].map<String, QuestionInputValue>((k, v) =>
        MapEntry<String, QuestionInputValue>(k, QuestionInputValue.fromJSON(v))),
      unit: json['unit'] ?? '',
      decimals: json['decimals'],
      min: json['min'],
      max: json['max']
    );


  @override
  String toString() =>
    'QuestionInput(type: $type, values: $values, unit: $unit, decimals: $decimals, min: $min, max: $max)';
}


/// This class contains all OSM tags that should be applied
/// including some additional information.

class QuestionInputValue {

  final Map<String, String> osmTags;

  final String? name;

  final String? description;

  final String? image;

  const QuestionInputValue({
    required this.osmTags,
    this.name,
    this.description,
    this.image
  });


  factory QuestionInputValue.fromJSON(Map<String, dynamic> json) =>
    QuestionInputValue(
      osmTags: json['osm_tags']?.cast<String, String>() ?? {},
      name: json['name'],
      description: json['description'],
      image: json['image']
    );


  @override
  String toString() =>
    'QuestionInputValue(osmTags: $osmTags, name: $name, description: $description, image: $image)';
}
