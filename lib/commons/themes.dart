import 'package:flutter/material.dart';

class Default {
  static const Color primary = Color(0xFFEC7C72);

  // Foreground Header Scaffold (lightTheme only)
  static Color onPrimaryLight = Colors.grey.shade100;
  static const Color onPrimaryDark = Color(0xFF002020);

  // Background FloatingActionButton / Overscroll Color
  static Color secondaryLight = Colors.grey.shade100;
  static const Color secondaryDark = Color(0xFF002020);

  // Foreground FloatingActionButton
  static Color onSecondaryLight = Colors.grey.shade900;
  static Color onSecondaryDark = Colors.grey.shade50;

  // Background Header Scaffold (darkTheme only, primary for lightTheme)
  static const Color surfaceDark = Color(0xFF005050);

  // Foreground Header Scaffold (darkTheme only, onPrimary for lightTheme) / Background Snackbar
  static Color onSurfaceDark = Colors.grey.shade300;

  // Background QuestionDialog, Scaffold Body, Drawer
  static const Color backgroundDark = Color(0xFF002020);
  static Color backgroundLight = Colors.grey.shade100;

  // Foreground QuestionDialog (Border, Lines)
  static const Color onBackgroundDark = Color(0xFF003144);
  static Color onBackgroundLight = Colors.grey.shade300;

  static const shadow = Colors.black26;

  static const double borderRadius = 12.0;
  static const double padding = 12.0;
}

// Default theme for all common theme settings
final ThemeData defaultTheme = ThemeData(
  floatingActionButtonTheme: FloatingActionButtonThemeData(
      smallSizeConstraints: BoxConstraints.tight(const Size.square(48)),
      largeSizeConstraints: BoxConstraints.tight(const Size.square(70)),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
              Radius.circular(Default.borderRadius)
          )
      )
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
          minimumSize: const Size.square(48),
          padding: const EdgeInsets.all(Default.padding),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Default.borderRadius),
          ),
          textStyle:const TextStyle(fontSize: 24)
      )
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
          backgroundColor: Colors.transparent,
          minimumSize: const Size.square(48),
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Default.borderRadius),
          ),
          side: const BorderSide(
              style: BorderStyle.solid,
              color: Default.primary
          )
      )
  ),
  inputDecorationTheme: const InputDecorationTheme(
      contentPadding: EdgeInsets.symmetric(horizontal: Default.padding),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(Default.borderRadius)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(Default.borderRadius)),
        borderSide: BorderSide(
            color: Default.primary
        )
      )
  ),
  toggleableActiveColor: Default.primary,
  snackBarTheme: const SnackBarThemeData(
      elevation: 8.0,
      actionTextColor: Default.primary,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(Default.borderRadius))
      )
  )
);

final ThemeData lightTheme = ThemeData.light().copyWith(
  colorScheme: ThemeData.light().colorScheme.copyWith(
      primary: Default.primary,
      onPrimary: Default.onPrimaryLight,
      secondary: Default.secondaryLight,
      onSecondary: Default.onSecondaryLight,
      background: Default.backgroundLight,
      onBackground: Default.onBackgroundLight,
      tertiary: Colors.white,
      onTertiary: Colors.black,
      shadow: Default.shadow,
  ),
  floatingActionButtonTheme: defaultTheme.floatingActionButtonTheme,
  elevatedButtonTheme: defaultTheme.elevatedButtonTheme,
  outlinedButtonTheme: defaultTheme.outlinedButtonTheme,
  inputDecorationTheme: defaultTheme.inputDecorationTheme.copyWith(
      border: defaultTheme.inputDecorationTheme.border!,
      enabledBorder: defaultTheme.inputDecorationTheme.border!.copyWith(
        borderSide: defaultTheme.inputDecorationTheme.border!.borderSide.copyWith(
            color: Default.onBackgroundLight
        )
      )
  ),
  toggleableActiveColor: defaultTheme.toggleableActiveColor,
  snackBarTheme: defaultTheme.snackBarTheme,
  cardColor: Default.backgroundLight,
  scaffoldBackgroundColor: Default.backgroundLight,
  canvasColor: Default.backgroundLight
);

final ThemeData darkTheme = ThemeData.dark().copyWith(
  colorScheme: ThemeData.dark().colorScheme.copyWith(
      primary: Default.primary,
      onPrimary: Default.onPrimaryDark,
      secondary: Default.secondaryDark,
      onSecondary: Default.onSecondaryDark,
      surface: Default.surfaceDark,
      onSurface: Default.onSurfaceDark,
      background: Default.backgroundDark,
      onBackground: Default.onBackgroundDark,
      tertiary: Colors.black,
      onTertiary: Colors.white,
      shadow: Default.shadow,
  ),
  floatingActionButtonTheme: defaultTheme.floatingActionButtonTheme,
  elevatedButtonTheme: defaultTheme.elevatedButtonTheme,
  outlinedButtonTheme: defaultTheme.outlinedButtonTheme,
  inputDecorationTheme: defaultTheme.inputDecorationTheme.copyWith(
      border: defaultTheme.inputDecorationTheme.border!,
      enabledBorder: defaultTheme.inputDecorationTheme.border!.copyWith(
          borderSide: defaultTheme.inputDecorationTheme.border!.borderSide.copyWith(
              color: Default.onBackgroundDark
          )
      )
  ),
  toggleableActiveColor: defaultTheme.toggleableActiveColor,
  snackBarTheme: defaultTheme.snackBarTheme,
  cardColor: Default.backgroundDark,
  scaffoldBackgroundColor: Default.backgroundDark,
  canvasColor: Default.backgroundDark
);

final ThemeData highContrastDarkTheme = ThemeData.dark().copyWith(
  colorScheme: const ColorScheme.highContrastDark(),
  floatingActionButtonTheme: defaultTheme.floatingActionButtonTheme,
  elevatedButtonTheme: defaultTheme.elevatedButtonTheme,
  outlinedButtonTheme: defaultTheme.outlinedButtonTheme,
  inputDecorationTheme: defaultTheme.inputDecorationTheme
);

final ThemeData highContrastLightTheme = ThemeData.light().copyWith(
  colorScheme: const ColorScheme.highContrastLight(),
  floatingActionButtonTheme: defaultTheme.floatingActionButtonTheme,
  elevatedButtonTheme: defaultTheme.elevatedButtonTheme,
  outlinedButtonTheme: defaultTheme.outlinedButtonTheme,
  inputDecorationTheme: defaultTheme.inputDecorationTheme
);
