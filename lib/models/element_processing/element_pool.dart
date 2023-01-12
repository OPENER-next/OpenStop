import '/api/osm_element_upload_api.dart';
import '/api/osm_element_query_api.dart';
import '/utils/service_worker.dart';
import '/models/authenticated_user.dart';
import '/models/map_feature_collection.dart';
import '/models/stop_area.dart';
import '/models/element_variants/base_element.dart';
import 'element_filter.dart';
import 'element_processor.dart';


/// The [ElementPool] is a service worker used to query, process and update elements from the OSM server.
///
/// It runs in a separate [Isolate] so it won't block the main thread.
///
/// Holds a mapping of [StopArea]s to [ProcessedElement]s and allows filtering them.
///
/// The isolate persists so the [ProcessedElement]s can be cached.
/// This is required because sending data between isolates copies the data over.
/// Therefore elements in the main isolate reference different objects in memory than the objects in the worker isolate.
/// [ProcessedElement]s however rely on the contract that they only exist once in order to keep the child/parent references intact.
/// Simply using Flutter's compute function on heavy functions would create copies of the original elements thus destroy any references.
///
/// TODO: If threads are ever possible in dart, this can be implemented much more efficiently.

class ElementPool {
  final ServiceWorkerController<_ElementPoolMessage> _worker;

  ElementPool._(this._worker);

  static Future<ElementPool> spawn() async {
    final con = await ServiceWorkerController.spawn<_ElementPoolMessage>(_ElementPool.new);
    return ElementPool._(con);
  }

  /// Method to upload an element to the OSM server.
  ///
  /// Update will return all affected stop areas and refilter them
  /// because an elements condition can start matching when another element's tags change
  /// or can stop matching because all questions are answered an no condition matches anymore.
  ///
  /// Returns a list, since the updated element can be present in multiple stop areas.
  ///
  /// Elements are filtered by their stop area and any additionally applied filters.

  Future<List<MapEntry<StopArea, Set<ProcessedElement>>>> update(ElementUpdateData data) async {
    return await _worker.send(_ElementPoolMessage(_Subject.update, data));
  }

  /// Query OSM elements from the server by a given stop area.
  ///
  /// Elements are filtered by their stop area and any additionally applied filters.
  ///
  /// If the stop area was queried before the currently cached elements will be returned.

  Future<MapEntry<StopArea, Set<ProcessedElement>>> query(StopArea stopArea) async {
    return await _worker.send(_ElementPoolMessage(_Subject.query, stopArea));
  }

  /// This will override any existing filters and return all currently
  /// cached stop area elements that passed the new filters.

  Future<List<MapEntry<StopArea, Set<ProcessedElement>>>> applyFilters(Iterable<ElementFilter> filters) async {
    return await _worker.send(_ElementPoolMessage(_Subject.applyFilters, filters));
  }

  /// Close the service worker.

  void dispose() {
    _worker.send(_ElementPoolMessage(_Subject.dispose));
  }
}


class _ElementPool extends ServiceWorker<_ElementPoolMessage> {
  final _osmElementQueryHandler = OSMElementQueryAPI();

  final _stopAreaToElementsMapping = <StopArea, Set<ProcessedElement>>{};

  final List<ElementFilter> _filters = [];

  _ElementPool(super.sendPort);

  Future<MapEntry<StopArea, Set<ProcessedElement>>> _query(StopArea stopArea) async {
    var elements = _stopAreaToElementsMapping[stopArea];

    if (elements == null) {
      // query elements by stop areas bbox
      final elementBundle = await _osmElementQueryHandler.queryByBBox(stopArea.bounds);
      // process stop area elements
      elements = Set.of(OSMElementProcessor(elementBundle).process());
      // store processed elements
      _stopAreaToElementsMapping[stopArea] = elements;
    }
    // send entry to main isolate
    return _filter(stopArea, elements);
  }


  Stream<MapEntry<StopArea, Set<ProcessedElement>>> _update(ElementUpdateData data) async* {
    var isUploaded = false;

    for (final entry in _stopAreaToElementsMapping.entries) {
      final original = entry.value.lookup(data.element);

      if (original != null) {
        if (!isUploaded) {
          // upload on first occurrence
          final uploadAPI = OSMElementUploadAPI(
            mapFeatureCollection: data.mapFeatureCollection,
            stopArea: entry.key,
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
          isUploaded = true;
        }
        yield _filter(entry.key, entry.value);
      }
    }
  }


  Iterable<MapEntry<StopArea, Set<ProcessedElement>>> _applyFilters(Iterable<ElementFilter> filters) sync* {
    // replace all filters
    _filters..clear()..addAll(filters);

    for (final entry in _stopAreaToElementsMapping.entries) {
      yield _filter(entry.key, entry.value);
    }
  }


  MapEntry<StopArea, Set<ProcessedElement>> _filter(StopArea stopArea, Set<ProcessedElement> elements) {
    // filter stop area elements
    final filteredElements = [
      AreaFilter(area: stopArea),
      ..._filters,
    ].fold<Iterable<ProcessedElement>>(
      elements,
      (elements, filter) => filter.filter(elements),
    );
    // return (copy) of filtered elements
    return MapEntry(stopArea,  Set.of(filteredElements));
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
        return await _update(message.data).toList();
      case _Subject.applyFilters:
        return _applyFilters(message.data).toList();
      case _Subject.dispose:
        return _dispose();
    }
  }
}


enum _Subject {
  query, update, applyFilters, dispose
}


class _ElementPoolMessage {
  final _Subject subject;
  final dynamic data;

  _ElementPoolMessage(this.subject, [ this.data ]);
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
