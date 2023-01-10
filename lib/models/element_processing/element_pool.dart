import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:osm_api/osm_api.dart';

import '/models/element_variants/base_element.dart';
import 'element_filter.dart';
import 'element_processor.dart';


/// Holds a set of [ProcessedElement]s, allows filtering them asynchronously and
/// offers direct access to them.
///
/// [ElementPool]s can be created asynchronously from an [OSMElementBundle] using `extractFrom`.

class ElementPool {
  final Set<ProcessedElement> _allElements;

  Set<ProcessedElement> _filteredElements;

  late final UnmodifiableSetView<ProcessedElement> allElements = UnmodifiableSetView(_allElements);

  /// All elements that passed the `filter` function.

  UnmodifiableSetView<ProcessedElement> get filteredElements => UnmodifiableSetView(_filteredElements);

  ElementPool(this._allElements) : _filteredElements = _allElements;


  /// This is the main workhorse for element extraction.
  /// Creates [ProcessedElement]s and applies any filters to them accordingly.
  /// Everything is run in an isolate so it doesn't block the main thread.

  static Future<ElementPool> extractFrom({
    required OSMElementBundle osmElements,
    List<ElementFilter> filters = const [],
  }) async {
    // run the operation in a separate thread to avoid blocking the UI
    final elements = ElementPool(await compute(_extractElements, osmElements));

    if (filters.isNotEmpty) {
      await elements.filter(filters);
    }
    return elements;
  }

  static Set<ProcessedElement> _extractElements(OSMElementBundle osmElements) {
    return OSMElementProcessor(osmElements)
      .process()
      .toSet();
  }


  /// Filters the elements of this [ElementPool].
  ///
  /// The result will be stored in [filteredElements].
  ///
  /// Everything is run in an isolate so it doesn't block the main thread.

  Future<void> filter(List<ElementFilter> filters) async {
    // run the operation in a separate thread to avoid blocking the UI
    _filteredElements = await compute(
      _filterElements,
      _IsolateContainer(
        elements: _allElements,
        filter: filters,
      )
    );
  }

  static Set<ProcessedElement> _filterElements(_IsolateContainer container) {
    return container.filter.fold<Iterable<ProcessedElement>>(
      container.elements,
      (elements, filter) => filter.filter(elements),
    ).toSet();
  }
}


/// A container to pass multiple arguments to the isolate.

class _IsolateContainer {
  final Iterable<ProcessedElement> elements;
  final List<ElementFilter> filter;

  _IsolateContainer({
    required this.elements,
    required this.filter,
  });
}
