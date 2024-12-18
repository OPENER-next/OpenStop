import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'upload_indicator.dart';


class OsmElementMarker extends StatefulWidget {
  final VoidCallback? onTap;
  final IconData icon;
  final Color? backgroundColor;
  final bool active;
  final String label;
  final Future? uploadState;

  const OsmElementMarker({
    super.key,
    this.onTap,
    this.icon = Icons.block,
    this.backgroundColor,
    this.active = false,
    this.label = '',
    this.uploadState,
  });

  @override
  State<OsmElementMarker> createState() => _OsmElementMarkerState();
}

class _OsmElementMarkerState extends State<OsmElementMarker> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final CurvedAnimation _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      value: widget.active ? 1 : 0,
      duration: const Duration(milliseconds: 600),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubicEmphasized,
      reverseCurve: Curves.easeInOutCubicEmphasized.flipped,
    );
  }

  @override
  void didUpdateWidget(covariant OsmElementMarker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.active != widget.active) {
      if (widget.active) {
        _controller.animateTo(1);
      }
      else {
        _controller.animateBack(0);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // add repaint boundary for performance improvement
    // this way a marker will only be redrawn if itself changes
    return RepaintBoundary(
      child: Center(
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedBuilder(
            animation: _animation,
            builder: (_, __) => MarkerBubble(
              shadowColor: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.4),
              elevation: _animation.value * 2,
              child: Padding(
                padding: const EdgeInsets.all(3),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AspectRatio(
                      aspectRatio: 1,
                      child: ClipOval(
                        child: ColoredBox(
                          color: Theme.of(context).colorScheme.primary,
                          child: UploadIndicator(
                            trigger: widget.uploadState,
                            padding: const EdgeInsets.all(7),
                            child: Icon(widget.icon,
                              color: Colors.white,
                              shadows: const [
                                Shadow(
                                  color: Colors.black12,
                                  offset: Offset(2, 2)
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (widget.label.isNotEmpty && !_animation.isDismissed) Flexible(
                      // this is basically a custom version of SizeTransition
                      // because it doesn't allow setting the cross axis alignment
                      child: ClipRect(
                        child: Align(
                          alignment: AlignmentDirectional.centerEnd,
                          widthFactor: _animation.value,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Text(widget.label,
                              textWidthBasis: TextWidthBasis.longestLine,
                              softWrap: true,
                              maxLines: 2,
                              style: TextStyle(
                                color: Colors.grey.shade900,
                                fontSize: 16,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animation.dispose();
    _controller.dispose();
    super.dispose();
  }
}


class MarkerBubble extends SingleChildRenderObjectWidget {
  final Color color;
  final Color shadowColor;
  final double elevation;
  final Size tipSize;

  const MarkerBubble({
    required super.child,
    this.color = Colors.white,
    this.shadowColor = Colors.black,
    this.elevation = 2,
    this.tipSize = const Size(12, 6),
    super.key,
  });

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderMarkerBubble(color, shadowColor, elevation, tipSize);
  }

  @override
  void updateRenderObject(BuildContext context, RenderObject renderObject) {
    (renderObject as _RenderMarkerBubble)
      ..color = color
      ..shadowColor = shadowColor
      ..elevation = elevation
      ..tipSize = tipSize;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<Color>('color', color));
    properties.add(DiagnosticsProperty<Color>('shadowColor', shadowColor));
    properties.add(DiagnosticsProperty<double>('elevation', elevation));
    properties.add(DiagnosticsProperty<Size>('tipSize', tipSize));
  }
}


class _RenderMarkerBubble extends RenderProxyBoxWithHitTestBehavior {
  Color _color;
  Color _shadowColor;
  double _elevation;
  Size _tipSize;
  late Path _path;

  _RenderMarkerBubble(
    this._color,
    this._shadowColor,
    this._elevation,
    this._tipSize,
  ) : super(behavior: HitTestBehavior.opaque);

  Color get color => _color;
  set color(Color value) {
    if (value != _color) {
      _color = value;
      markNeedsPaint();
    }
  }

  Color get shadowColor => _shadowColor;
  set shadowColor(Color value) {
    if (value != _shadowColor) {
      _shadowColor = value;
      markNeedsPaint();
    }
  }

  double get elevation => _elevation;
  set elevation(double value) {
    if (value != _elevation) {
      _elevation = value;
      markNeedsPaint();
    }
  }

  Size get tipSize => _tipSize;
  set tipSize(Size value) {
    if (value != _tipSize) {
      _tipSize = value;
      markNeedsPaint();
      markNeedsLayout();
    }
  }


  @override
  void paint(PaintingContext context, Offset offset) {
    final tipStart = size.bottomCenter(offset);
    final path = _path.shift(offset);

    final ovalShadow = Rect.fromCenter(
      center: tipStart,
      width: 25,
      height: 7,
    );

    context.canvas.drawOval(
      ovalShadow,
      Paint()
      ..color = _shadowColor
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5)
    );

    // paint bubble shadow
    if (_shadowColor.a > 0 && _elevation > 0) {
      context.canvas.drawShadow(
        path,
        _shadowColor.withValues(alpha: 1.0),
        _elevation,
        false, // depends one underlying widget
      );
    }

    // paint bubble
    context.canvas.drawPath(
      path,
      Paint()
        ..color = _color
        ..style = PaintingStyle.fill
    );

    if (child != null) {
      context.paintChild(child!, offset);
    }
  }


  @override
  void performLayout() {
    child!.layout(
      constraints.deflate(EdgeInsets.only(bottom: _tipSize.height)),
      parentUsesSize: true,
    );
    final desiredSize = Size(child!.size.width, constraints.maxHeight);
    size = constraints.constrain(desiredSize);

    _path = _buildBubblePath();
  }


  Path _buildBubblePath() {
    // needs to be used instead of size.height, since we constrain the children minus the tip height.
    final height = size.height - _tipSize.height;
    final width = size.width;

    final tipStart = size.bottomCenter(Offset.zero);
    final tipHalfWidth = _tipSize.width/2;

    final double angle;

    if (height + _tipSize.width > width) {
      final lengthDifference = width - height;
      final oppositeSide = tipHalfWidth - lengthDifference / 2;
      // radius of circle
      final a = height/2;
      // radius + part of tip height
      final b = a + oppositeSide * (_tipSize.height / tipHalfWidth);
      // get angle by: tan angle = opposite side divided by adjacent side
      final alpha = atan(tipHalfWidth / _tipSize.height);
      // law of sin with additional `pi - ` to get the acute angle (law of sin always gives two solutions)
      final beta = pi - asin( sin(alpha) / a * b );
      // by sum of interior angles
      final gamma = pi - alpha - beta;
      angle = gamma;
    }
    else {
      angle = 0;
    }

    return Path()
      // start at tip
      ..moveTo(tipStart.dx, tipStart.dy)
      ..lineTo(tipStart.dx - tipHalfWidth, height)
      // left rounding
      ..arcTo(
        Offset.zero & Size.square(height),
        pi/2 + angle,
        pi - angle,
        false,
      )
      // right rounding
      ..arcTo(
        Offset(width - height, 0) & Size.square(height),
        -pi/2,
        pi - angle,
        false,
      )
      ..lineTo(tipStart.dx + tipHalfWidth, height)
      ..close();
  }
}
