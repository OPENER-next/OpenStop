import 'dart:math';
import 'package:flutter/material.dart';

/// An indicator showing the currently selected page of a PageController
class DotsIndicator extends AnimatedWidget {
  DotsIndicator({
    required this.controller,
    required this.itemCount,
    required this.onPageSelected,
    this.color: Colors.black54,
  }) : super(listenable: controller);

  /// The PageController that this DotsIndicator is representing.
  final PageController controller;

  /// The number of items managed by the PageController
  final int itemCount;

  /// Called when a dot is tapped
  final ValueChanged<int> onPageSelected;

  /// The color of the dots.
  final Color color;

  /// The base size of the dots
  static const double _dotSize = 6.0;

  /// The increase in the size of the selected dot
  static const double _dotMaxZoom = 1.6;

  /// The distance between the center of each dot
  static const double _dotSpacing = 25.0;

  Widget _buildDot(int index) {
    double selectedness = Curves.easeOut.transform(
      max(
        0.0,
        1.0 - ((controller.page ?? controller.initialPage) - index).abs(),
      ),
    );
    double zoom = 1.0 + (_dotMaxZoom - 1.0) * selectedness;
    return new Container(
      width: _dotSpacing,
      child: new GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onPageSelected(index),
        child: new Center(
          child: new Material(
            color: color,
            type: MaterialType.circle,
            child: new Container(
              width: _dotSize * zoom,
              height: _dotSize * zoom,
            ),
          ),
        ),
      ),
    );
  }

  Widget build(BuildContext context) {
    return new Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: new List<Widget>.generate(itemCount, _buildDot),
    );
  }
}
