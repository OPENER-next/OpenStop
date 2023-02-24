import 'sub_condition_matcher.dart';
import '/models/element_variants/base_element.dart';

/// Interface for classes that implement a matching functionality.
///
/// Takes and uses a custom characteristic to match against given sample values.

abstract class Matcher<C, T> {
  final C characteristics;

  const Matcher(this.characteristics);

  bool matches(T sample);
}


/// This class holds the conditions that specify if a [Question] should be asked.

class ElementCondition extends Matcher<List<SubCondition>, ProcessedElement> {

  const ElementCondition(super.characteristics);

  ElementCondition.fromJSON(Map<String, dynamic> json)
    : super(_buildSubConditionsFromJSON(json).toList(growable: false));


  static Iterable<SubCondition> _buildSubConditionsFromJSON(Map<String, dynamic> json) sync* {
    // positive conditions

    final pTags = json['osm_tags'];
    if (pTags != null) {
      yield TagsSubCondition.fromJson(pTags);
    }

    final pOsmElement = json['osm_element'];
    if (pOsmElement != null) {
      yield ElementTypeSubCondition.fromJson(pOsmElement);
    }

    final pChild = json['child']?.cast<Map<String, dynamic>>();
    if (pChild != null) {
      yield ChildSubCondition.fromJson(pChild);
    }

    final pParent = json['parent']?.cast<Map<String, dynamic>>();
    if (pParent != null) {
      yield ParentSubCondition.fromJson(pParent);
    }

    // negated conditions

    final nTags = json['!osm_tags'];
    if (nTags != null) {
      yield NegatedSubCondition(TagsSubCondition.fromJson(nTags));
    }

    final nOsmElement = json['!osm_element'];
    if (nOsmElement != null) {
      yield NegatedSubCondition(ElementTypeSubCondition.fromJson(nOsmElement));
    }

    final nChild = json['!child']?.cast<Map<String, dynamic>>();
    if (nChild != null) {
      yield NegatedSubCondition(ChildSubCondition.fromJson(nChild));
    }

    final nParent = json['!parent']?.cast<Map<String, dynamic>>();
    if (nParent != null) {
      yield NegatedSubCondition(ParentSubCondition.fromJson(nParent));
    }
  }


  /// Check whether this condition matches the given element.
  ///
  /// This checks whether all sub conditions of this condition match the given element.

  @override
  bool matches(sample) {
    return characteristics.every((element) => element.matches(sample));
  }
}
