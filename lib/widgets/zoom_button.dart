import 'package:flutter/material.dart';

class ZoomButton extends StatelessWidget {
  final void Function()? onZoomInPressed;
  final void Function()? onZoomOutPressed;
  late final double buttonWidth;
  late final double buttonHeight;

  ZoomButton({
    Key? key,
    this.onZoomInPressed,
    this.onZoomOutPressed,
    mini = false
  }) : super(key: key) {
    buttonWidth = mini ? 40.0 : 56.0;
    buttonHeight = mini ? 50.0 : 60.0;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: Theme.of(context).floatingActionButtonTheme.elevation ?? 8.0,
      borderRadius: BorderRadius.all(Radius.circular(this.buttonWidth/2)),
      color: Theme.of(context).floatingActionButtonTheme.backgroundColor,
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          SizedBox(
            height: this.buttonHeight,
            width: this.buttonWidth,
            child: InkWell(
              onTap: onZoomInPressed,
              child: const Icon(Icons.add),
            ),
          ),
          Container(
            height: 1,
            width: this.buttonWidth,
            color: Colors.black12,
          ),
          SizedBox(
            height: this.buttonHeight,
            width: this.buttonWidth,
            child: InkWell(
              onTap: onZoomOutPressed,
              child: const Icon(Icons.remove),
            ),
          ),
        ],
      ),
    );
  }
}