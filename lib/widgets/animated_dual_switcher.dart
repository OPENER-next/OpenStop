import 'package:flutter/material.dart';


typedef TransitionBuilder = Widget Function(
  BuildContext context,
  Animation<double> animation,
  Widget? child
);


class AnimatedDualSwitcher extends StatefulWidget {
  final TransitionBuilder animateInBuilder;

  final TransitionBuilder animateOutBuilder;

  final Widget? child;

  final Duration animateInDuration;

  final Duration animateOutDuration;

  final Curve animateInCurve;

  final Curve animateOutCurve;

  final Widget Function(
    Iterable<Widget> animatingInChildren,
    Iterable<Widget> animatingOutChildren
  ) layoutBuilder;

  const AnimatedDualSwitcher({
    Key? key,
    required this.animateInBuilder,
    required this.animateOutBuilder,
    this.child,
    this.animateInDuration = const Duration(milliseconds: 600),
    this.animateOutDuration = const Duration(milliseconds: 600),
    this.animateInCurve = Curves.linear,
    this.animateOutCurve = Curves.linear,
    this.layoutBuilder = AnimatedDualSwitcher.defaultLayoutBuilder,
  }) : super(key: key);


  static Widget defaultLayoutBuilder(Iterable<Widget> animatingInChildren, Iterable<Widget> animatingOutChildren) {
    return Stack(
      alignment: Alignment.center,
      children: [
        ...animatingOutChildren,
        ...animatingInChildren
      ],
    );
  }


  @override
  State<AnimatedDualSwitcher> createState() => _AnimatedDualSwitcherState();
}

class _AnimatedDualSwitcherState extends State<AnimatedDualSwitcher> with TickerProviderStateMixin {
  final _newWidgets = Map<_CustomDualTransitionBuilder, AnimationController>();

  final _oldWidgets = Map<_CustomDualTransitionBuilder, AnimationController>();

  @override
  void initState() {
    super.initState();

    _update();
  }


  @override
  void didUpdateWidget(covariant AnimatedDualSwitcher oldWidget) {
    super.didUpdateWidget(oldWidget);

    // detect if the child changed
    // if so the animation switcher will be run
    if (oldWidget.child != null && widget.child != null && !Widget.canUpdate(oldWidget.child!, widget.child!)) {
      _update(oldWidget);
    }
  }


  void _update([covariant AnimatedDualSwitcher? oldWidget]) {
    _newWidgets.removeWhere((widgetAnimationBuilder, controller) {
      if (controller.isCompleted) {
        _oldWidgets[widgetAnimationBuilder] = controller;
        controller.reverse();
        // remove widget from _newWidgets
        return true;
      }
      return false;
    });

    final AnimationController controller = AnimationController(
      duration: widget.animateInDuration,
      reverseDuration: widget.animateOutDuration,
      vsync: this,
    );

    final Animation<double> animation = CurvedAnimation(
      parent: controller,
      curve: widget.animateInCurve,
      reverseCurve: widget.animateOutCurve,
    );

    final widgetAnimationBuilder = _CustomDualTransitionBuilder(
      key: UniqueKey(),
      animation: animation,
      forwardBuilder: widget.animateInBuilder,
      reverseBuilder: widget.animateOutBuilder,
      child: widget.child,
    );

    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && _newWidgets.containsKey(widgetAnimationBuilder)) {
        if (_newWidgets.length > 1) {
          setState(() {
            _newWidgets.remove(widgetAnimationBuilder);
            _oldWidgets[widgetAnimationBuilder] = controller;
            controller.reverse();
          });
        }
      }
      else if (status == AnimationStatus.dismissed && _oldWidgets.containsKey(widgetAnimationBuilder)) {
        setState(() {
          _oldWidgets.remove(widgetAnimationBuilder);
          controller.dispose();
        });
      }
    });

    _newWidgets[widgetAnimationBuilder] = controller;

    controller.forward();
  }


  @override
  Widget build(BuildContext context) {
    return widget.layoutBuilder(_newWidgets.keys, _oldWidgets.keys);
  }


  @override
  void dispose() {
    _oldWidgets.forEach((key, controller) => controller.dispose());
    _newWidgets.forEach((key, controller) => controller.dispose());
    super.dispose();
  }
}


class _CustomDualTransitionBuilder extends StatefulWidget {
  final Animation<double> animation;

  final TransitionBuilder forwardBuilder;

  final TransitionBuilder reverseBuilder;

  final Widget? child;

  _CustomDualTransitionBuilder({
    Key? key,
    required this.animation,
    required this.forwardBuilder,
    required this.reverseBuilder,
    this.child
  }) : super(key: key);

  @override
  State<_CustomDualTransitionBuilder> createState() => __CustomDualTransitionBuilderState();
}

class __CustomDualTransitionBuilderState extends State<_CustomDualTransitionBuilder> {
  late TransitionBuilder _builder = widget.forwardBuilder;
  late Animation<double> _animation = widget.animation;

  @override
  void initState() {
    super.initState();
    _update();
  }


  @override
  void didUpdateWidget(covariant _CustomDualTransitionBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    _update(oldWidget);
  }


  void _update([covariant _CustomDualTransitionBuilder? oldWidget]) {
    oldWidget?.animation.removeStatusListener(_handleStatusChange);
    widget.animation.addStatusListener(_handleStatusChange);
    _handleStatusChange(widget.animation.status);
  }


  void _handleStatusChange(AnimationStatus status) {
    switch (status) {
      case AnimationStatus.forward:
        setState(() {
          _builder = widget.forwardBuilder;
          _animation = widget.animation;
        });
      break;
      case AnimationStatus.reverse:
        setState(() {
          _builder = widget.reverseBuilder;
          _animation = widget.animation;
        });
      break;
      default:
    }
  }


  @override
  Widget build(BuildContext context) => _builder(context, _animation, widget.child);
}