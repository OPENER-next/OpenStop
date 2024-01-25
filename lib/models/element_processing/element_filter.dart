// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:latlong2/latlong.dart';

import '/models/element_conditions/element_condition.dart';
import '/models/element_variants/base_element.dart';
import '/models/question_catalog/question_catalog.dart';

abstract class ElementFilter<F> extends Matcher<F, ProcessedElement> {
  ElementFilter(super.characteristics);

  Iterable<ProcessedElement> filter(Iterable<ProcessedElement> elements) =>
    elements.where(matches);

  Stream<ProcessedElement> asyncFilter(Stream<ProcessedElement> elements) =>
    elements.where(matches);
}


/// Filter for elements which geometric center is inside the given [Circle].

class AreaFilter extends ElementFilter<Circle> {
  AreaFilter({
    required Circle area,
  }) : super(area);

  @override
  bool matches(ProcessedElement sample) =>
    characteristics.isPointInside(sample.geometry.center);
}


/// Filter for elements which match at least one question from a given [QuestionCatalog].

class QuestionFilter extends ElementFilter<QuestionCatalog> {
  QuestionFilter({
    required QuestionCatalog questionCatalog,
  }) : super(questionCatalog);

  @override
  bool matches(ProcessedElement sample) {
    return characteristics.any((question) {
      return question.conditions.any((condition) {
        return condition.matches(sample);
      });
    });
  }
}


/// Meta filter to "OR" combine multiple other element filters.

class AnyFilter extends ElementFilter<Iterable<ElementFilter>> {
  AnyFilter({
    required Iterable<ElementFilter> filters,
  }) : super(filters);

  @override
  bool matches(ProcessedElement sample) =>
    characteristics.any((filter) => filter.matches(sample));
}
