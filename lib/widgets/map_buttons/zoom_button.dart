import 'package:flutter/material.dart';

class ZoomButton extends StatelessWidget {
  final void Function()? onZoomInPressed;
  final void Function()? onZoomOutPressed;

  const ZoomButton({
    Key? key,
    this.onZoomInPressed,
    this.onZoomOutPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: Theme.of(context).floatingActionButtonTheme.elevation ?? 8.0,
      shape: Theme.of(context).floatingActionButtonTheme.shape,
      color: Theme.of(context).floatingActionButtonTheme.backgroundColor,
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          SizedBox(
            height: (Theme.of(context).floatingActionButtonTheme.smallSizeConstraints?.minHeight ?? 40.0) * 1.25,
            width: Theme.of(context).floatingActionButtonTheme.smallSizeConstraints?.minWidth ?? 40.0,
            child: InkWell(
              onTap: onZoomInPressed,
              child: Icon(
                Icons.add,
                color: Theme.of(context).floatingActionButtonTheme.foregroundColor,
              ),
            ),
          ),
          Container(
            height: 1,
            width: Theme.of(context).floatingActionButtonTheme.smallSizeConstraints?.minWidth,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          SizedBox(
            height: (Theme.of(context).floatingActionButtonTheme.smallSizeConstraints?.minHeight ?? 40.0) * 1.25,
            width: Theme.of(context).floatingActionButtonTheme.smallSizeConstraints?.minWidth ?? 40.0,
            child: InkWell(
              onTap: onZoomOutPressed,
              child: Icon(
                Icons.remove,
                color: Theme.of(context).floatingActionButtonTheme.foregroundColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
