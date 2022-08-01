import 'package:flutter/material.dart';

class CustomSnackBar extends SnackBar{

  CustomSnackBar(String text, {
    Key? key,
  }) : super(
      content: Text(text),
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
      dismissDirection: DismissDirection.none,
      key: key
  );
}
