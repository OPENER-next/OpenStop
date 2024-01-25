// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';

/// Optionally an action button can be displayed.
/// For this both the [actionText] and [actionCallback] parameter must be supplied.
/// If at least one of them is missing, no action will be displayed.

class CustomSnackBar extends SnackBar{

  CustomSnackBar(String text, {
    String? actionText,
    VoidCallback? actionCallback,
    Key? key,
  }) : super(
      content: Text(text),
      action: actionText != null && actionCallback != null
        ? SnackBarAction(
          label: actionText,
          onPressed: actionCallback,
        )
        : null,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
      dismissDirection: DismissDirection.none,
      key: key,

  );
}
