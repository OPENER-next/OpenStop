part of 'base_element.dart';

/// For easy and quick access [ProcessedElement]s contain direct references to their children and parents (if any).
/// This cross-referencing allows traversing elements from any given [ProcessedElement].
///
/// Nodes that are children of a way which itself is part of a relation won't count as children of the relation unless they are direct members of the relation.
/// However they can still be accessed by traversing the child/parent references (recursive matching).
///
/// You shouldn't create a [ProcessedElement] by yourself. This should be done solely by the [OSMElementProcessor].
///
/// [ProcessedElement]s can have multiple parents because it is not a tree structure,
/// instead its a network with a usually low hierarchy (many interconnected trees where nodes represent the leafs).
///
/// Two [ProcessedElement]s are considered equal if they have the same [id] and [type].

abstract class ProcessedElement<T extends osmapi.OSMElement, G extends GeographicGeometry> extends BaseElement<T> {
  G? _geometry;

  final _parents = HashSet<ParentElement>();
  final _children = HashSet<ChildElement>();

  ProcessedElement(super.osmElement);

  G get geometry {
    if (_geometry == null) {
      calcGeometry();
      if (_geometry == null) throw 'Geometry of ${type.name} $id cannot be calculated.';
    }
    return _geometry!;
  }

  /// Any elements this element is a part of.
  /// The elements are unordered and do not contain duplicates.
  late final UnmodifiableSetView<ParentElement> parents = UnmodifiableSetView(_parents);

  /// Any elements this element consists of.
  /// The elements are unordered and do not contain duplicates.
  late final UnmodifiableSetView<ChildElement> children = UnmodifiableSetView(_children);

  /// Calculates the geometry of this element based on its children.
  /// If any required child is not available this method may throw an error.
  ///
  /// Implementers should write the result to the `_geometry` field.
  void calcGeometry();
}


mixin ChildElement<T extends osmapi.OSMElement, G extends GeographicGeometry> on ProcessedElement<T, G> {
  void addParent(covariant ParentElement element) {
    _parents.add(element);
    element._children.add(this);
  }

  void removeParent(covariant ParentElement element) {
    _parents.remove(element);
    element._children.remove(this);
  }
}


mixin ParentElement<T extends osmapi.OSMElement, G extends GeographicGeometry> on ProcessedElement<T, G> {
  void addChild(covariant ChildElement element) {
    _children.add(element);
    element._parents.add(this);
  }

  void removeChild(covariant ChildElement element) {
    _children.remove(element);
    element._parents.remove(this);
  }
}
