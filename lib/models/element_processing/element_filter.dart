import 'package:latlong2/latlong.dart';

import '/models/element_variants/base_element.dart';
import '/models/question_catalog/question_catalog.dart';

abstract class ElementFilter {
  bool matches(ProcessedElement element);

  Iterable<ProcessedElement> filter(Iterable<ProcessedElement> elements) =>
    elements.where(matches);
}


/// Filter for elements which geometric center is inside the given [Circle].

class AreaFilter extends ElementFilter {
  final Circle _area;

  AreaFilter({
    required Circle area,
  }) : _area = area;

  @override
  bool matches(ProcessedElement element) =>
    _area.isPointInside(element.geometry.center);
}


/// Filter for elements which match at least one question from a given [QuestionCatalog].

class QuestionFilter extends ElementFilter {
  final QuestionCatalog _questionCatalog;

  QuestionFilter({
    required QuestionCatalog questionCatalog,
  }) : _questionCatalog = questionCatalog;

  @override
  bool matches(ProcessedElement element) {
    return _questionCatalog.any((question) {
      return question.conditions.any((condition) {
        return condition.matches(element);
      });
    });
  }
}


/// Meta filter to "OR" combine multiple other element filters.

class AnyFilter extends ElementFilter {
  final Iterable<ElementFilter> _filters;

  AnyFilter({
    required Iterable<ElementFilter> filters,
  }) : _filters = filters;

  @override
  bool matches(ProcessedElement element) =>
    _filters.any((filter) => filter.matches(element));
}
