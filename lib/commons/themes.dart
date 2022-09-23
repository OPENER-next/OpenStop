import 'package:flutter/material.dart';

class Default {
  static const Color primary = Color(0xFFEC7C72);

  // Foreground Selected (FloatingAction)Button / Background Account Image
  static Color onPrimaryLight = Colors.grey.shade100;
  static const Color onPrimaryDark = Color(0xFF002020);

  // Background Unselected FloatingActionButton
  static Color primaryContainerLight = Colors.grey.shade100;
  static const Color primaryContainerDark = Color(0xFF002020);

  // Foreground Unselected (FloatingAction)Button
  static Color onPrimaryContainerLight = Colors.grey.shade900;
  static Color onPrimaryContainerDark = Colors.grey.shade50;

  // toggleableActiveColor
  static const Color secondary = Color(0xFFEC7C72);

  // Background Header Scaffold
  static const Color surface = Color(0xFFEC7C72);

  // Foreground Header Scaffold
  static Color onSurfaceLight = Colors.grey.shade100;
  static const Color onSurfaceDark = Color(0xFF002020);

  // Background QuestionDialog
  static Color backgroundLight = Colors.grey.shade100;
  static const Color backgroundDark = Color(0xFF002020);

  // Foreground QuestionDialog (Border, Lines)
  static Color onBackgroundLight = Colors.grey.shade300;
  static const Color onBackgroundDark = Color(0xFF003144);

  static const shadow = Colors.black26;

  static const double borderRadius = 12.0;
  static const double padding = 12.0;
}

// Default theme for all common theme settings
final ThemeData defaultTheme = ThemeData(
  useMaterial3: true,
  floatingActionButtonTheme: FloatingActionButtonThemeData(
      smallSizeConstraints: BoxConstraints.tight(const Size.square(48)),
      largeSizeConstraints: BoxConstraints.tight(const Size.square(70)),
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
  snackBarTheme: SnackBarThemeData(
      actionTextColor: Default.primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Default.borderRadius)
      )
  )
);

final ThemeData lightTheme = ThemeData.light().copyWith(
  useMaterial3: true,
  colorScheme: ThemeData.light().colorScheme.copyWith(
      primary: Default.primary,
      onPrimary: Default.onPrimaryLight,
      primaryContainer: Default.primaryContainerLight,
      onPrimaryContainer: Default.onPrimaryContainerLight,
      surface: Default.surface,
      onSurface: Default.onSurfaceLight,
      background: Default.backgroundLight,
      onBackground: Default.onBackgroundLight,
      tertiary: Colors.white,
      onTertiary: Colors.black,
      shadow: Default.shadow,
      secondary: Default.secondary
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
  snackBarTheme: defaultTheme.snackBarTheme.copyWith(
    backgroundColor: Colors.grey.shade900,
  ),
  // To have the same background color for licenses as for every other scaffold
  cardColor: Default.backgroundLight,
  // Background Body Drawer, Background Table
  canvasColor: Default.backgroundLight
);

final ThemeData darkTheme = ThemeData.dark().copyWith(
  useMaterial3: true,
  colorScheme: ThemeData.dark().colorScheme.copyWith(
      primary: Default.primary,
      onPrimary: Default.onPrimaryDark,
      primaryContainer: Default.primaryContainerDark,
      onPrimaryContainer: Default.onPrimaryContainerDark,
      surface: Default.surface,
      onSurface: Default.onSurfaceDark,
      background: Default.backgroundDark,
      onBackground: Default.onBackgroundDark,
      tertiary: Colors.black,
      onTertiary: Colors.white,
      shadow: Default.shadow,
      secondary: Default.secondary
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
  snackBarTheme: defaultTheme.snackBarTheme,
  // To have the same background color for licenses as for every other scaffold
  cardColor: Default.backgroundDark,
  // Background Body Drawer, Background Table
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
