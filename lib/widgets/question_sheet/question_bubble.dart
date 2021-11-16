
import 'package:flutter/material.dart';

class QuestionBubble extends StatelessWidget {
  final EdgeInsetsGeometry? padding;

  final EdgeInsetsGeometry? margin;

  final Color? color;

  final Widget? child;

  final BoxDecoration _decoration;

  QuestionBubble({
    Key? key,
    required this.child,
    Radius topLeft = const Radius.circular(20),
    Radius topRight = const Radius.circular(20),
    this.padding = const EdgeInsets.symmetric(
      vertical: 20,
      horizontal: 20
    ),
    this.margin,
    this.color
  }) : _decoration = BoxDecoration(
    boxShadow: const [
      const BoxShadow(
        color: Colors.black26,
        blurRadius: 3,
        offset: const Offset(0, 2)
      )
    ],
    borderRadius: BorderRadius.only(
      topLeft: topLeft,
      topRight: topRight,
      bottomLeft: const Radius.circular(20),
      bottomRight: const Radius.circular(20)
    ),
    color: color,
  ), super(key: key);


  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _decoration,
      padding: padding,
      margin: margin,
      child: child,
      clipBehavior: Clip.antiAlias,
    );
  }
}