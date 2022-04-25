import 'package:flutter/material.dart';

enum InteractionTrigger {
  none,
  tap,
  doubleTap,
  longPress
}

typedef HeroViewerBuilder = Widget Function(BuildContext context, Widget child);

/// This widget can be wrapped around any widget (though it is preferably used around images)
/// to enlarge the wrapped widget to the entire screen and allow closer inspection of the widget.

class HeroViewer extends StatefulWidget {

  /// Hero view builder which wraps the child in an InteractiveViewer
  /// so the content can be zoomed and panned.

  static Widget imageViewerBuilder(BuildContext context, Widget child) {
    return ColoredBox(
      color: Theme.of(context).colorScheme.background,
      child: InteractiveViewer(
        maxScale: 3,
        child: FittedBox(
          fit: BoxFit.contain,
          child: child,
        )
      ),
    );
  }

  static Widget defaultPageRouteTransitionsBuilder(_, Animation<double> animation, __, Widget child) {
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }


  final Widget child;

  /// A custom builder to add additional widgets around or beneath the hero child.
  /// The child given in this function will already be wrapped inside the respective hero widget.
  /// Note: the returned widget tree needs to contain the given child widget at some point in the hierarchy.

  final HeroViewerBuilder pageBuilder;

  /// Specify on which interaction the viewer should be shown.

  final InteractionTrigger openOn;

  /// Specify on which interaction the viewer should be closed.

  final InteractionTrigger closeOn;

  /// An optional page route transition builder, to customize the page transition.

  final RouteTransitionsBuilder pageRouteTransitionsBuilder;

  final Duration pageRouteTransitionDuration;

  final Duration pageRouteReverseTransitionDuration;

  const HeroViewer({
    required this.child,
    this.pageBuilder = HeroViewer.imageViewerBuilder,
    this.openOn = InteractionTrigger.tap,
    this.closeOn = InteractionTrigger.tap,
    this.pageRouteTransitionsBuilder = HeroViewer.defaultPageRouteTransitionsBuilder,
    this.pageRouteTransitionDuration = const Duration(milliseconds: 300),
    this.pageRouteReverseTransitionDuration = const Duration(milliseconds: 300),
    Key? key,
  }) : super(key: key);

  @override
  State<HeroViewer> createState() => _HeroViewerState();
}


class _HeroViewerState extends State<HeroViewer> {

  /// A unique identifier is required to link both hero image widgets.
  /// For simplicity this is generated once in the code.
  /// This is the only reason why this widget needs to be state full.
  final _uniqueTag = UniqueKey();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.openOn == InteractionTrigger.tap ? showViewer : null,
      onDoubleTap: widget.openOn == InteractionTrigger.doubleTap ? showViewer : null,
      onLongPress: widget.openOn == InteractionTrigger.longPress ? showViewer : null,
      child: Hero(
        tag: _uniqueTag,
        child: widget.child
      ),
    );
  }

  void showViewer() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
          return _HeroViewerPage(
            child: widget.child,
            builder: widget.pageBuilder,
            tag: _uniqueTag,
            trigger: widget.closeOn
          );
        },
        transitionsBuilder: widget.pageRouteTransitionsBuilder,
        transitionDuration: widget.pageRouteTransitionDuration,
        reverseTransitionDuration: widget.pageRouteReverseTransitionDuration
      )
    );
  }
}


class _HeroViewerPage extends StatelessWidget {
  final Widget child;

  final HeroViewerBuilder builder;

  final Object tag;

  final InteractionTrigger trigger;

  const _HeroViewerPage({
    required this.child,
    required this.builder,
    required this.tag,
    required this.trigger,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    void closeViewer() => Navigator.pop(context);

    return GestureDetector(
      onTap: trigger == InteractionTrigger.tap ? closeViewer : null,
      onDoubleTap: trigger == InteractionTrigger.doubleTap ? closeViewer : null,
      onLongPress: trigger == InteractionTrigger.longPress ? closeViewer : null,
      child: builder.call(
        context,
        Hero(
          tag: tag,
          child: child
        )
      )
    );
  }
}
