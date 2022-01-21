import 'dart:collection';

import '/models/osm_element_type.dart';


class TemplateOSMObject {
  final String name;

  final String icon;

  final Map<String, dynamic> osmTags;

  final OSMElementType osmElement;

  const TemplateOSMObject({
    required this.name,
    required this.icon,
    required this.osmTags,
    required this.osmElement
  });

  factory TemplateOSMObject.fromJSON(Map<String, dynamic> json) =>
      TemplateOSMObject(
        name: json['name'],
        icon: json['icon'],
        osmTags: json['osm_tags'] ?? <String, dynamic>{},
        osmElement: (json['osm_element'] as String).toOSMElementType(),
      );

  @override
  String toString() =>
      'TemplateOSMObject(name: $name, icon: $icon, osm_tags: $osmTags, osm_element: $osmElement)';

  /// Check whether this condition matches the given data.

  bool matches(Map<String, String> tags, OSMElementType type) =>
      matchesTags(tags) && matchesElement(type);


  /// Check whether the tags of this condition matches the given tags.

  bool matchesTags(Map<String, String> tags) =>
      false;


  /// Check whether the element types of this condition matches the given element type.

  bool matchesElement(OSMElementType type) =>
      true;
}

class TemplateOSMObjects extends ListBase<TemplateOSMObject> {
  final List<TemplateOSMObject> elements;

  TemplateOSMObjects(this.elements);

  @override
  int get length => elements.length;


  @override
  set length(int newLength) {
    elements.length = newLength;
  }

  @override
  TemplateOSMObject operator [](int index) => elements[index];

  @override
  void operator []=(int index, TemplateOSMObject value) {
    elements[index] = value;
  }

  factory TemplateOSMObjects.fromJson(List<Map<String, dynamic>> json) {
    final elementList = json.map<TemplateOSMObject>(
      (jsonOSMObject) => TemplateOSMObject.fromJSON(jsonOSMObject)
    ).toList();
    return TemplateOSMObjects(elementList);
  }
}
