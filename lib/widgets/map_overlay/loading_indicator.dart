import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  final bool active;

  final Duration duration;

  const LoadingIndicator({
    this.active = false,
    this.duration = const Duration(milliseconds: 500),
    Key? key
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      switchInCurve: Curves.elasticOut,
      switchOutCurve: Curves.elasticOut,
      transitionBuilder: _transition,
      duration: duration,
      child: !active ? null : Material(
        type: MaterialType.circle,
        elevation: Theme.of(context).floatingActionButtonTheme.elevation ?? 8.0,
        color: Theme.of(context).colorScheme.secondary,
        // enforce no box constraints
        // see: https://flutter.dev/docs/development/ui/layout/constraints
        child: UnconstrainedBox(
          child: Container(
            height: 40.0,
            width: 40.0,
            padding: const EdgeInsets.all(10),
            child: CircularProgressIndicator(
              color: Theme.of(context).colorScheme.primary,
            )
          )
        )
      )
    );
  }


  Widget _transition(Widget child, Animation<double> animation) {
    return ScaleTransition(scale: animation, child: child);
  }
}
