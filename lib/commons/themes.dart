import 'package:flutter/material.dart';

class CustomColors {
  static const Color darkGreen = Color(0xff407336);
  static const Color green = Color(0xff6cc15a);
}

class Default {
  static const Color primary = CustomColors.green;
  static Color onPrimaryLight = Colors.grey.shade100;
  static const Color onPrimaryDark = Color(0xFF002020);

  static const Color secondary = CustomColors.darkGreen;

  static Color surfaceLight = Colors.grey.shade100;
  static Color onSurfaceLight = Colors.grey.shade300;
  static const Color surfaceDark = Color(0xFF002020);
  static const Color onSurfaceDark = Color(0xFF004C4C);

  static const double borderRadius = 12.0;
  static const double padding = 16.0;
  static const double elevation = 2.0;
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
          primary: Default.primary,
          minimumSize: const Size.square(48),
          padding: const EdgeInsets.all(Default.padding),
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
      secondary: Default.secondary,
      surface: Default.surfaceLight,
      onSurface: Default.onSurfaceLight,
      tertiary: Colors.white,
      onTertiary: Colors.black
  ),
  appBarTheme: AppBarTheme(
      elevation: Default.elevation,
      backgroundColor: Colors.grey[200],
      foregroundColor: Colors.black87
  ),
  floatingActionButtonTheme: defaultTheme.floatingActionButtonTheme.copyWith(
    foregroundColor: Colors.grey[900],
    backgroundColor: Default.surfaceLight,
  ),
  elevatedButtonTheme: defaultTheme.elevatedButtonTheme,
  outlinedButtonTheme: defaultTheme.outlinedButtonTheme,
  inputDecorationTheme: defaultTheme.inputDecorationTheme.copyWith(
      enabledBorder: defaultTheme.inputDecorationTheme.enabledBorder!.copyWith(
          borderSide: defaultTheme.inputDecorationTheme.enabledBorder!.borderSide.copyWith(
              color: Default.onSurfaceLight
          )
      )
  ),
  toggleableActiveColor: defaultTheme.toggleableActiveColor,
);

final ThemeData darkTheme = ThemeData.dark().copyWith(
  colorScheme: ThemeData.dark().colorScheme.copyWith(
      primary: Default.primary,
      onPrimary: Default.onPrimaryDark,
      secondary: Default.secondary,
      surface: Default.surfaceDark,
      onSurface: Default.onSurfaceDark,
      tertiary: Colors.black,
      onTertiary: Colors.white
  ),
  appBarTheme: AppBarTheme(
      elevation: Default.elevation,
      backgroundColor: Colors.grey[900],
      foregroundColor: Colors.white
  ),
  floatingActionButtonTheme: defaultTheme.floatingActionButtonTheme.copyWith(
    foregroundColor: Colors.grey[50],
    backgroundColor: Default.surfaceDark,
  ),
  elevatedButtonTheme: defaultTheme.elevatedButtonTheme,
  outlinedButtonTheme: defaultTheme.outlinedButtonTheme,
  inputDecorationTheme: defaultTheme.inputDecorationTheme.copyWith(
      enabledBorder: defaultTheme.inputDecorationTheme.enabledBorder!.copyWith(
          borderSide: defaultTheme.inputDecorationTheme.enabledBorder!.borderSide.copyWith(
              color: Default.onSurfaceDark
          )
      )
  ),
  toggleableActiveColor: defaultTheme.toggleableActiveColor,
);

final ThemeData highContrastDarkTheme = ThemeData.dark().copyWith(
  colorScheme: const ColorScheme.highContrastDark(),
);

final ThemeData highContrastLightTheme = ThemeData.light().copyWith(
  colorScheme: const ColorScheme.highContrastLight(),
);
