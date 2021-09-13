import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({
    Key? key
  }) : super(key: key);

  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.circle,
      elevation: Theme.of(context).floatingActionButtonTheme.elevation ?? 8.0,
      color: Theme.of(context).floatingActionButtonTheme.backgroundColor,
      // enforce no box constraints
      // see: https://flutter.dev/docs/development/ui/layout/constraints
      child: UnconstrainedBox(
        child: Container(
          height: 40.0,
          width: 40.0,
          padding: const EdgeInsets.all(10),
          child: CircularProgressIndicator(
            color: Theme.of(context).colorScheme.secondary,
          )
        )
      )
    );
  }
}
