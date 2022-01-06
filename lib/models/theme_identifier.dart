import 'package:flutter/material.dart';

import '/commons/themes.dart';

/// This [enum] is a representation of the available themes defined in the `themes.dart`.

enum ThemeIdentifier {
  light, dark, contrast
}

extension TransformTo on ThemeIdentifier {
  ThemeData toThemeData() {
    switch (this) {
      case ThemeIdentifier.dark:
        return darkTheme;
      case ThemeIdentifier.contrast:
        return darkTheme;
      case ThemeIdentifier.light:
      default:
        return lightTheme;
    }
  }
}
