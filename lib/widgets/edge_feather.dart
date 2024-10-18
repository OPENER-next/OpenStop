import 'package:flutter/material.dart';

/// Widget to fade out edges of a rectangle

class EdgeFeather extends StatelessWidget {
  final Widget child;

  /// The distance a side should be faded out.
  ///
  /// Note: It is only possible to define one or opposing sides.

  final EdgeInsets edges;

  EdgeFeather({
    required this.edges,
    required this.child,
    super.key,
  }) : assert(edges.isNonNegative, 'The EdgeInsets of the edges argument are not allowed to be negative.'),
       assert(
        !(edges.vertical > 0 && edges.horizontal > 0),
        'Only one axis (horizontal or vertical) can be faded.',
       );

  @override
  Widget build(Object context) {
    if (edges == EdgeInsets.zero) {
      return child;
    }
    return ShaderMask(
      blendMode: BlendMode.dstOut,
      shaderCallback: (bounds) => _createGradient(bounds).createShader(bounds),
      child: child,
    );
  }

  LinearGradient _createGradient(Rect bounds) {
    assert(
      edges.vertical < bounds.height && edges.horizontal < bounds.width,
      'The fade exceeds the actual widget size.',
    );

    final double beginProportion;
    final double endProportion;
    final Alignment begin;
    final Alignment end;
    if (edges.horizontal > 0) {
      beginProportion = edges.left / bounds.width;
      endProportion = edges.right / bounds.width;
      begin = Alignment.centerLeft;
      end = Alignment.centerRight;
    }
    else {
      beginProportion = edges.top / bounds.height;
      endProportion = edges.bottom / bounds.height;
      begin = Alignment.topCenter;
      end = Alignment.bottomCenter;
    }

    final stops = <double>[];
    final colors = <Color>[];
    if (beginProportion > 0) {
      stops..add(0)..add(beginProportion);
      colors..add(Colors.white)..add(Colors.transparent);
    }
    if (endProportion > 0) {
      stops..add(1 - endProportion)..add(1);
      colors..add(Colors.transparent)..add(Colors.white);
    }

    return LinearGradient(
      begin: begin,
      end: end,
      stops: stops,
      colors: colors,
    );
  }
}
