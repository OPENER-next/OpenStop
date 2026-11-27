part of 'base_element.dart';

/// A wrapper class to modify the tags of [OSMElement]s without changing or exposing them.

class ProxyElement<T extends osmapi.OSMElement, G extends GeographicGeometry>
    extends ProcessedElement<T, G> {
  final ProcessedElement<T, G> original;

  ProxyElement(
    this.original, {
    Map<String, String>? additionalTags,
  }) : additionalTags = additionalTags ?? {},
       super(original._osmElement);

  /// Tags that should be added or overridden.

  final Map<String, String> additionalTags;

  /// Contains all original tags and those added by changes.

  @override
  late final CombinedMapView<String, String> tags = CombinedMapView([
    // on duplicates the first value will be returned
    // therefore move additionalTags to the start
    additionalTags, super.tags,
  ]);

  /// The tag changes this proxy makes to the original element.

  TagDiff get tagDiff => TagDiff.between(original.tags, tags);

  /// Applies the tag changes of this proxy to the [current] server version of the element.
  ///
  /// Throws an [ElementConflictException] if the element was changed in a contradicting way
  /// (see [TagDiff.applyTo] and [checkGeometryConflict]).

  T rebaseOnto(T current) {
    checkGeometryConflict(_osmElement, current);
    return current.copyWith(tags: tagDiff.applyTo(current.tags)) as T;
  }

  /// Uploads the given [rebased] element (see [rebaseOnto]) to the OSM server
  /// and on success updates the underlying OSM element with its tags and version.
  ///
  /// The method primarily exists to prevent the exposal of the underlying original OSM element.
  ///
  /// This method may throw any upload/OSMAPI errors.
  /// In this case the underlying element stays unchanged.
  ///
  /// Returns the uploaded element.

  Future<T> publish(OSMElementUploadAPI uploadAPI, int changesetId, T rebased) async {
    final uploaded = await uploadAPI.updateOsmElement(changesetId, rebased);
    adopt(rebased..version = uploaded.version);
    // all changes are now part of the original element
    additionalTags.clear();
    return rebased;
  }

  /// Replaces the tags and version of the underlying OSM element by the ones of the given [current] element.
  ///
  /// This is used to update the element to the server state after an upload or conflict.
  /// The geometry is not updated.

  void adopt(osmapi.OSMElement current) {
    _osmElement.tags
      ..clear()
      ..addAll(current.tags);
    _osmElement.version = current.version;
  }

  // forward methods from processed elements

  @override
  G get geometry => original.geometry;

  /// Any elements this element is a part of.
  /// The elements are unordered and do not contain duplicates.
  @override
  UnmodifiableSetView<ParentElement> get parents => original.parents;

  /// Any elements this element consists of.
  /// The elements are unordered and do not contain duplicates.
  @override
  UnmodifiableSetView<ChildElement> get children => original.children;

  @override
  void calcGeometry() => original.calcGeometry();
}
