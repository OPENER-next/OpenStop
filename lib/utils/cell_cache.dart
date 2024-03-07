import 'dart:math';


/// A cache for storing data in a 2 dimensional integer grid.
/// Each entry has a unique cell index defined by the x and y coordinate.

class CellCache<T> {
  final Map<int, Map<int, T>> _queriedCells = {};


  /// Method to remove an entry from the cache by a given [CellIndex].

  void remove(CellIndex index) {
    final column = _queriedCells[index.x];
    if (column != null) {
      column.remove(index.y);
      if (column.isEmpty) {
        _queriedCells.remove(index.x);
      }
    }
  }


  /// Method to add a new item to the cache or override an existing entry.

  void add(CellIndex index, T stops) {
    final column = _queriedCells[index.x];
    if (column == null) {
      _queriedCells[index.x] = {index.y: stops};
    }
    else {
      column[index.y] = stops;
    }
  }


  /// Method to get an item by a given [CellIndex].

  T? get(CellIndex index) {
    final column = _queriedCells[index.x];
    if (column == null) return null;
    return column[index.y];
  }


  /// Method to check if the given [CellIndex] is cached.

  bool contains(CellIndex index) {
    final column = _queriedCells[index.x];
    if (column == null) return false;
    return column.containsKey(index.y);
  }


  /// Method to get all items in the cache.

  Iterable<T> get items sync* {
    for (final column in _queriedCells.values) {
      yield* column.values;
    }
  }
}


/// An index the [CellCache] represented by two integer values x and y

class CellIndex extends Point<int> {
  CellIndex(super.x, super.y);
}
