import 'package:flutter/material.dart';

class Default {
  static const Color primary = Color(0xFFEC7C72);
  static Color onPrimaryLight = Colors.grey.shade100;
  static const Color onPrimaryDark = Color(0xFF002020);

  // Background FloatingActionButton / Overscroll Color
  static Color secondaryLight = Colors.grey.shade100;
  static const Color secondaryDark = Color(0xFF002020);

  // Foreground FloatingActionButton
  static Color onSecondaryLight = Colors.grey.shade900;
  static Color onSecondaryDark = Colors.grey.shade50;

  // Background Header Scaffold (darkTheme only, primary in lightTheme)
  static Color surfaceLight = Colors.grey;
  static const Color surfaceDark = Color(0xFF005050);

  // Foreground Scaffold Header
  static Color onSurfaceLight = Colors.grey.shade300;
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
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(Default.borderRadius)),
        borderSide: BorderSide(
            width: 1.0,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(Default.borderRadius)),
        borderSide: BorderSide(
            width: 1.0,
            color: Default.primary
        ),
      )
  ),
  toggleableActiveColor: Default.primary,
);

final ThemeData lightTheme = ThemeData.light().copyWith(
  colorScheme: ThemeData.light().colorScheme.copyWith(
      primary: Default.primary,
      onPrimary: Default.onPrimaryLight,
      secondary: Default.secondaryLight,
      onSecondary: Default.onSecondaryLight,
      surface: Default.surfaceLight,
      onSurface: Default.onSurfaceLight,
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
      enabledBorder: defaultTheme.inputDecorationTheme.enabledBorder!.copyWith(
          borderSide: defaultTheme.inputDecorationTheme.enabledBorder!.borderSide.copyWith(
              color: Default.onBackgroundLight
          )
      )
  ),
  toggleableActiveColor: defaultTheme.toggleableActiveColor,
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
      enabledBorder: defaultTheme.inputDecorationTheme.enabledBorder!.copyWith(
          borderSide: defaultTheme.inputDecorationTheme.enabledBorder!.borderSide.copyWith(
              color: Default.onBackgroundDark
          )
      )
  ),
  toggleableActiveColor: defaultTheme.toggleableActiveColor,
  cardColor: Default.backgroundDark,
  scaffoldBackgroundColor: Default.backgroundDark,
  canvasColor: Default.backgroundDark
);

final ThemeData highContrastDarkTheme = ThemeData.dark().copyWith(
  colorScheme: const ColorScheme.highContrastDark(),
);

final ThemeData highContrastLightTheme = ThemeData.light().copyWith(
  colorScheme: const ColorScheme.highContrastLight(),
);
