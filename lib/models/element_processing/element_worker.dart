import '/api/osm_element_upload_api.dart';
import '/api/osm_element_query_api.dart';
import '/utils/service_worker.dart';
import '/models/authenticated_user.dart';
import '/models/map_feature_collection.dart';
import '/models/stop_area.dart';
import '/models/element_variants/base_element.dart';
import 'element_filter.dart';
import 'element_processor.dart';


/// The [ElementWorker] is a service worker used to query, process and update elements from the OSM server.
///
/// It runs in a separate [Isolate] so it won't block the main thread.
///
/// Holds a single [Set] of all queried [ProcessedElement]s over time and allows filtering them.
///
/// The isolate persists so the [ProcessedElement]s can be cached.
/// This is required because sending data between isolates copies the data over.
/// Therefore elements in the main isolate reference different objects in memory than the objects in the worker isolate.
/// [ProcessedElement]s however rely on the contract that they only exist once in order to keep the child/parent references intact.
/// Simply using Flutter's compute function on heavy functions would create copies of the original elements thus destroy any references.
///
/// TODO: If threads are ever possible in dart, this can be implemented much more efficiently.

class ElementWorker {
  final ServiceWorkerController<_ElementWorkerMessage> _worker;

  ElementWorker._(this._worker);

  static Future<ElementWorker> spawn() async {
    final con = await ServiceWorkerController.spawn<_ElementWorkerMessage>(_ElementWorker.new);
    return ElementWorker._(con);
  }

  /// Method to upload an element to the OSM server.
  ///
  /// Update will return all elements refiltered
  /// because an elements condition can start matching when another element's tags change
  /// or can stop matching because all questions are answered an no condition matches anymore.
  ///
  /// Elements are filtered by the stop areas used to query them and any additionally applied filters.

  Future<Set<ProcessedElement>> update(ElementUpdateData data) async {
    return await _worker.send(_ElementWorkerMessage(_Subject.update, data));
  }

  /// Query OSM elements from the server by a given stop area.
  ///
  /// Returns the newly queried and already existing elements filtered by the stop areas and any additionally filters.
  ///
  /// If the stop area was queried before the currently cached elements will be returned.

  Future<Set<ProcessedElement>> query(StopArea stopArea) async {
    return await _worker.send(_ElementWorkerMessage(_Subject.query, stopArea));
  }

  /// This will override any existing filters and return all currently
  /// cached elements that passed the new filters.

  Future<Set<ProcessedElement>> applyFilters(Iterable<ElementFilter> filters) async {
    return await _worker.send(_ElementWorkerMessage(_Subject.applyFilters, filters));
  }

  /// Check whether a given [StopArea] has any elements.

  Future<bool> hasElements(StopArea stopArea) async {
    return await _worker.send(_ElementWorkerMessage(_Subject.hasElements, stopArea));
  }

  /// Close the service worker.

  void dispose() {
    _worker.send(_ElementWorkerMessage(_Subject.dispose));
  }
}


class _ElementWorker extends ServiceWorker<_ElementWorkerMessage> {
  final _elementPool = OSMElementProcessor();

  final _osmElementQueryHandler = OSMElementQueryAPI();

  final _stopAreas = <StopArea>{};

  final _filters = <ElementFilter>[];

  _ElementWorker(super.sendPort);

  Future<Set<ProcessedElement>> _query(StopArea stopArea) async {
    if (!_stopAreas.contains(stopArea)) {
      _stopAreas.add(stopArea);
      try {
        // query elements by stop areas bbox
        final elementBundle = await _osmElementQueryHandler.queryByBBox(stopArea.bounds);
        // process stop area elements
        _elementPool.add(elementBundle);
      }
      catch(e) {
        _stopAreas.remove(stopArea);
        rethrow;
      }
    }

    // return all elements
    return _getAllFiltered();
  }


  Future<Set<ProcessedElement>> _update(ElementUpdateData data) async {
    final original = _elementPool.find(data.element.type, data.element.id);

    final stopArea = _stopAreas.firstWhere(
      (stopArea) => stopArea.isPointInside(data.element.geometry.center),
      orElse: () => throw StateError('No surrounding stop area found for ${data.element.type} ${data.element.id}.'),
    );

    if (original != null) {
      // upload on first occurrence
      final uploadAPI = OSMElementUploadAPI(
        mapFeatureCollection: data.mapFeatureCollection,
        stopArea: stopArea,
        authenticatedUser: data.authenticatedUser,
        changesetLocale: data.languageCode
      );
      // Since the underlying element from the isolate is not accessible from the outside we need to update it inside.
      // Replacing element wouldn't work, since the new/provided element doesn't have
      // the correct parent/child references to the isolate internal elements,
      // because the element is always a copy from the main/outside isolate.
      // Therefore create a proxy element of the original using the given proxy element.
      final proxy = ProxyElement(original, additionalTags: data.element.additionalTags);
      await proxy.publish(uploadAPI);
      uploadAPI.dispose();
      // return all elements since new elements might match after an element got updated
      return _getAllFiltered();
    }
    throw StateError('No corresponding element found for ${data.element.type} ${data.element.id} in element pool.');
  }


  Set<ProcessedElement> _applyFilters(Iterable<ElementFilter> filters) {
    // replace all filters
    _filters..clear()..addAll(filters);
    // return all elements
    return _getAllFiltered();
  }


  Set<ProcessedElement> _getAllFiltered() {
    final filters = [
      AnyFilter(
        // build area filters from stop areas
        filters: _stopAreas.map((stopArea) => AreaFilter(area: stopArea)),
      ),
      ..._filters,
    ];
    // filter stop area elements
    final filteredElements = filters.fold<Iterable<ProcessedElement>>(
      _elementPool.elements,
      (elements, filter) => filter.filter(elements),
    );
    // return (copy) of filtered elements
    return Set.of(filteredElements);
  }


  bool _hasElements(StopArea stopArea) {
    final filters = [
      AreaFilter(area: stopArea),
      ..._filters,
    ];
    final filteredElements = filters.fold<Iterable<ProcessedElement>>(
      _elementPool.elements,
      (elements, filter) => filter.filter(elements),
    );
    return filteredElements.isNotEmpty;
  }


  void _dispose() {
    _osmElementQueryHandler.dispose();
    exit();
  }


  @override
  Future<dynamic> messageHandler(message) async {
    switch(message.subject) {
      case _Subject.query:
        return await _query(message.data);
      case _Subject.update:
        return await _update(message.data);
      case _Subject.applyFilters:
        return _applyFilters(message.data);
      case _Subject.hasElements:
        return _hasElements(message.data);
      case _Subject.dispose:
        return _dispose();
    }
  }
}


enum _Subject {
  query, update, applyFilters, hasElements, dispose
}


class _ElementWorkerMessage {
  final _Subject subject;
  final dynamic data;

  _ElementWorkerMessage(this.subject, [ this.data ]);
}


class ElementUpdateData {
  final MapFeatureCollection mapFeatureCollection;

  final ProxyElement element;

  final AuthenticatedUser authenticatedUser;

  final String languageCode;

  const ElementUpdateData({
    required this.element,
    required this.mapFeatureCollection,
    required this.authenticatedUser,
    required this.languageCode,
  });
}
