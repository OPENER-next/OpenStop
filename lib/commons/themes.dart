import 'package:flutter/material.dart';

class CustomColors {
  static const Color darkGreen = Color(0xff407336);
  static const Color green = Color(0xff6cc15a);
  static const Color lightGreen = Color(0xffe9ffe4);
}

// Default theme for all common theme settings
final ThemeData defaultTheme = ThemeData(
    floatingActionButtonTheme: FloatingActionButtonThemeData(
        smallSizeConstraints: BoxConstraints.tight(const Size.square(48)),
        largeSizeConstraints: BoxConstraints.tight(const Size.square(70)),
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
                Radius.circular(10)
            )
        )
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
            primary: CustomColors.green,
            padding: const EdgeInsets.all(20.0),
            textStyle:const TextStyle(fontSize: 24)
        )
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
            primary: CustomColors.darkGreen,
            backgroundColor: CustomColors.lightGreen,
            minimumSize: const Size(double.infinity, 48),
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            side: const BorderSide(
              style: BorderStyle.none,
            )
        )
    ),
    inputDecorationTheme: const InputDecorationTheme(
        contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12.0))
        )
    ),
);

final ThemeData lightTheme = ThemeData.light().copyWith(
    colorScheme: ThemeData.light().colorScheme.copyWith(
      primary: CustomColors.green,
      secondary: CustomColors.lightGreen,
      onPrimary: Colors.white,
      onSecondary: CustomColors.darkGreen,
      surface: Colors.grey[50],
    ),
    appBarTheme: AppBarTheme(
        elevation: 2.0,
        backgroundColor: Colors.grey[200],
        foregroundColor: Colors.black87
    ),
    floatingActionButtonTheme: defaultTheme.floatingActionButtonTheme.copyWith(
      foregroundColor: Colors.black,
      backgroundColor: Colors.white,
    ),
    elevatedButtonTheme: defaultTheme.elevatedButtonTheme,
    outlinedButtonTheme: defaultTheme.outlinedButtonTheme,
    inputDecorationTheme: defaultTheme.inputDecorationTheme,
  );

final ThemeData darkTheme = ThemeData.dark().copyWith(
    colorScheme: ThemeData.dark().colorScheme.copyWith(
        primary: CustomColors.green,
        secondary: CustomColors.lightGreen,
        onPrimary: Colors.black87,
        onSecondary: CustomColors.darkGreen,
        surface: Colors.grey[850],
    ),
    appBarTheme: AppBarTheme(
        elevation: 2.0,
        backgroundColor: Colors.grey[900],
        foregroundColor: Colors.white
    ),
    floatingActionButtonTheme: defaultTheme.floatingActionButtonTheme.copyWith(
      foregroundColor: Colors.white,
      backgroundColor: Colors.black,
    ),
    elevatedButtonTheme: defaultTheme.elevatedButtonTheme,
    outlinedButtonTheme: defaultTheme.outlinedButtonTheme,
    inputDecorationTheme: defaultTheme.inputDecorationTheme,
);

final ThemeData highContrastDarkTheme = ThemeData.dark().copyWith(
    colorScheme: const ColorScheme.highContrastDark(),
);

final ThemeData highContrastLightTheme = ThemeData.light().copyWith(
  colorScheme: const ColorScheme.highContrastLight(),
);
