import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class RippleIndicator extends StatefulWidget {
  final Size size;

  final Duration duration;

  final VoidCallback? onEnd;

  /// Used to initiate the end the ripple animation.
  ///
  /// If the ripple animation finally ends the [onEnd] callback will be called.

  final bool end;

  const RippleIndicator({
    this.size = Size.infinite,
    this.duration = const Duration(seconds: 2),
    this.end = false,
    this.onEnd,
    super.key
  });

  @override
  State<RippleIndicator> createState() => _RippleIndicatorState();
}

class _RippleIndicatorState extends State<RippleIndicator> with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return _RippleIndicator(
      vsync: this,
      size: widget.size,
      color: Theme.of(context).colorScheme.primary,
      pulseCount: 3,
      duration: widget.duration,
      end: widget.end,
      onEnd: widget.onEnd,
    );
  }
}


class _RippleIndicator extends LeafRenderObjectWidget {
  final TickerProvider vsync;
  final Size size;
  final Color color;
  final int pulseCount;
  final Duration duration;
  final bool end;
  final VoidCallback? onEnd;

  const _RippleIndicator({
    required this.vsync,
    required this.size,
    required this.pulseCount,
    required this.color,
    required this.duration,
    this.end = false,
    this.onEnd,
  });

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderRippleIndicator(vsync, size, pulseCount, end, onEnd, color, duration);
  }

  @override
  void updateRenderObject(BuildContext context, RenderObject renderObject) {
    (renderObject as _RenderRippleIndicator)
      ..vsync = vsync
      ..preferredSize = size
      ..pulseCount = pulseCount
      ..end = end
      ..onEnd = onEnd
      ..color = color
      ..duration = duration;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<TickerProvider>('vsync', vsync));
    properties.add(DiagnosticsProperty<Size>('size', size));
    properties.add(DiagnosticsProperty<int>('pulseCount', pulseCount));
    properties.add(DiagnosticsProperty<bool>('end', end));
    properties.add(DiagnosticsProperty<VoidCallback?>('onEnd', onEnd));
    properties.add(DiagnosticsProperty<Color>('color', color));
    properties.add(DiagnosticsProperty<Duration>('duration', duration));
  }
}


class _RenderRippleIndicator extends RenderProxyBoxWithHitTestBehavior {
  final AnimationController _controller;

  Color _color;

  Size _preferredSize;

  int _pulseCount;

  bool _end;

  VoidCallback? _onEnd;

  int _newPulses = 0;

  int _limitPulses = 0;

  bool _restart = false;

  // used to detect animation repetition
  double _lastValue = 0;

  _RenderRippleIndicator(
    TickerProvider vsync,
    this._preferredSize,
    this._pulseCount,
    // ignore: avoid_positional_boolean_parameters
    this._end,
    this._onEnd,
    this._color,
    Duration duration,
  ) :
    _vsync = vsync,
    _controller = AnimationController(vsync: vsync, duration: duration),
    super(behavior: HitTestBehavior.opaque)
  {
    _controller..addListener(_listen)..repeat();
  }

  void _listen() {
    if (_controller.value != _lastValue) {
      // detect if animation started again
      if (_lastValue > _controller.value) {
        if (_newPulses < _pulseCount) {
          // if starting increase pulse count by one
          _newPulses++;
        }

        if (end) {
          // on end increase limit by one
          _limitPulses++;

          if (_limitPulses > _pulseCount) {
            if (_restart) {
              // reset properties to restart animation
              _newPulses = 0;
              _limitPulses = 0;
              _restart = false;
              _end = false;
            }
            // stop animation
            else {
              // remove listener, because reset will trigger this listener function
              // which would lead to an infinite regress
              _controller..removeListener(_listen)..reset();
              _onEnd?.call();
            }
          }
        }
      }

      _lastValue = _controller.value;
      markNeedsPaint();
    }
  }


  TickerProvider get vsync => _vsync;
  TickerProvider _vsync;
  set vsync(TickerProvider value) {
    if (value == _vsync) {
      return;
    }
    _vsync = value;
    _controller.resync(vsync);
  }

  Size get preferredSize => _preferredSize;
  set preferredSize(Size value) {
    if (value != _preferredSize) {
      _preferredSize = value;
      markNeedsPaint();
      markNeedsLayout();
    }
  }

  int get pulseCount => _pulseCount;
  set pulseCount(int value) {
    if (value != pulseCount) {
      _pulseCount = value;
    }
  }

  bool get end => _end;
  set end(bool value) {
    // if animation gets re-activated while currently expiring
    // wait till it ended and then start it again
    if (_end == true) {
      _restart = !value;
      // if controller is stopped, restart it
      if (_controller.isDismissed) {
        _controller..addListener(_listen)..repeat();
      }
    }
    else if (value != _end) {
      _end = value;
    }
  }

  VoidCallback? get onEnd => _onEnd;
  set onEnd(VoidCallback? value) {
    if (value != _onEnd) {
      _onEnd = value;
    }
  }

  Color get color => _color;
  set color(Color value) {
    if (value != _color) {
      _color = value;
      markNeedsPaint();
    }
  }

  Duration get duration => _controller.duration!;
  set duration(Duration value) {
    if (value != _controller.duration) {
      _controller.duration = value;
    }
  }

  void _circle(Canvas canvas, Offset offset, double radius, Color color) {
    canvas.drawCircle(
      offset,
      radius,
      Paint()
        ..color = color
        ..style = PaintingStyle.fill,
    );
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final halfSize = size/2;
    final center = size.center(offset);
    final maxRadius = halfSize.shortestSide;

    // start drawing largest circle first
    for (int pulse = _newPulses; pulse >= _limitPulses; pulse--) {
      final value = (pulse + _controller.value) / (_pulseCount + 1);

      final radius = maxRadius * value;
      final opacity = _color.opacity - _color.opacity * value;
      final color = _color.withOpacity(opacity);

      _circle(context.canvas, center, radius, color);
    }
  }

  @override
  void performLayout() {
    size = constraints.constrain(_preferredSize);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
