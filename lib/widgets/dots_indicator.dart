import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// An indicator showing the currently selected page of a PageController
class DotsIndicator extends AnimatedWidget {
  const DotsIndicator({
    required this.controller,
    required this.itemCount,
    required this.onPageSelected,
    this.color = Colors.black54,
    super.key
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

  Widget _buildDot(int index, BuildContext context) {
    final appLocale = AppLocalizations.of(context)!;
    final selectedness = Curves.easeOut.transform(
      max(
        0.0,
        1.0 - ((controller.page ?? controller.initialPage) - index).abs(),
      ),
    );
    final zoom = 1.0 + (_dotMaxZoom - 1.0) * selectedness;
    return SizedBox(
      width: _dotSpacing,
      child: Semantics(
        container: true,
        selected: selectedness > 0.0,
        label: appLocale.semanticsDotsIndicator(index + 1),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => onPageSelected(index),
          child: Center(
            child: Material(
              color: color,
              type: MaterialType.circle,
              child: SizedBox(
                width: _dotSize * zoom,
                height: _dotSize * zoom,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appLocale = AppLocalizations.of(context)!;
    return Semantics(
      label: appLocale.semanticsPageIndicators(itemCount),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List<Widget>.generate(itemCount, (int index) => _buildDot(index, context)),
      ),
    );
  }
}
