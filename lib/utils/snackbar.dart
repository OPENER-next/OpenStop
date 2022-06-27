import 'package:flutter/material.dart';

class CustomSnackBar extends SnackBar{

  CustomSnackBar({
    required String text,
    Key? key,
  }) : super(
      content: Text(text),
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsetsDirectional.all(32),
      key: key
  );
}
