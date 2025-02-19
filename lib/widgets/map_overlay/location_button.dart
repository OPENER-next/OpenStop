import 'package:flutter/material.dart';

import '/l10n/app_localizations.g.dart';

class LocationButton extends ImplicitlyAnimatedWidget {
  final bool active;

  final void Function()? onPressed;

  final Color? color, activeColor, iconColor, activeIconColor;

  const LocationButton({
    super.key,
    this.active = false,
    this.onPressed,
    this.color = Colors.white,
    this.activeColor = Colors.black,
    this.iconColor = Colors.black,
    this.activeIconColor = Colors.white,
    super.duration = const Duration(milliseconds: 300),
    super.curve = Curves.ease,
  });


  @override
  AnimatedWidgetBaseState<LocationButton> createState() => _LocationButtonState();
}

class _LocationButtonState extends AnimatedWidgetBaseState<LocationButton> {
  ColorTween? _colorTween;

  ColorTween? _iconColorTween;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _colorTween = visitor(
      _colorTween,
      widget.active ? widget.activeColor : widget.color,
      (value) => ColorTween(begin: value)
    ) as ColorTween?;

    _iconColorTween = visitor(
      _iconColorTween,
      widget.active ? widget.activeIconColor : widget.iconColor,
      (value) => ColorTween(begin: value)
    ) as ColorTween?;
  }


  @override
  Widget build(BuildContext context) {
    final appLocale = AppLocalizations.of(context)!;
    return FloatingActionButton.small(
      heroTag: null,
      backgroundColor: _colorTween?.evaluate(animation),
      onPressed: widget.onPressed,
      child: Icon(
        Icons.my_location,
        color: _iconColorTween?.evaluate(animation),
        semanticLabel: appLocale.semanticsCurrentLocationButton,
      ),
    );
  }
}
