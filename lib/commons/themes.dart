import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Default {
  // Sacffold Header Background
  static const Color primary = Color(0xFFEC7C72);

  // (FloatingAction)Button Foreground Selected / Account Background, Border, Text
  static Color onPrimary = Colors.grey.shade100;

  // FloatingActionButton Background Unselected
  static Color primaryContainerLight = Colors.grey.shade100;
  static const Color primaryContainerDark = Color(0xFF002020);

  // (FloatingAction)Button Foreground Unselected
  static Color onPrimaryContainerLight = Colors.grey.shade900;
  static Color onPrimaryContainerDark = Colors.grey.shade50;

  // Mixed with Background Header Scaffold when scrolled > Transparent so no color change is visible
  static const Color surfaceTint = Colors.transparent;

  // QuestionDialog Background / Scaffold Body Background (Licenses only) / Map Background / Drawer Body Background
  static Color surfaceLight = Colors.grey.shade100;
  static const Color surfaceDark = Color(0xFF002020);

  // QuestionDialog Foreground (Input Border, Progressbar Line) / Divider
  static Color outlineVariantLight = Colors.grey.shade300;
  static const Color outlineVariantDark = Color(0xFF003144);

  // Shadow for Material Widgets (Zoom button, Loading indicator)
  static const shadow = Colors.black;

  static const double borderRadius = 12.0;
  static const double padding = 12.0;
  static const double elevation = 4.0;
}

// Default theme for all common theme settings
final ThemeData defaultTheme = ThemeData(
  appBarTheme: AppBarTheme(
    elevation: Default.elevation,
    scrolledUnderElevation: Default.elevation,
    shadowColor: Default.shadow,
    backgroundColor: Default.primary,
    foregroundColor: Default.onPrimary,
    surfaceTintColor: Colors.transparent,
    systemOverlayStyle: const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemStatusBarContrastEnforced: false,
      systemNavigationBarColor: Colors.black26,
      systemNavigationBarIconBrightness: Brightness.light,
      systemNavigationBarContrastEnforced: false,
    ),
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    smallSizeConstraints: BoxConstraints.tight(const Size.square(48)),
    largeSizeConstraints: BoxConstraints.tight(const Size.square(70)),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(
        Radius.circular(Default.borderRadius)
      )
    ),
    elevation: Default.elevation
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
        color: Default.primary
      )
    )
  ),
  iconButtonTheme: IconButtonThemeData(
    style: ButtonStyle(
      shape: WidgetStateProperty.all(RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Default.borderRadius),
        )
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

final ThemeData lightTheme = ThemeData(
  colorScheme: ThemeData.light().colorScheme.copyWith(
    primary: Default.primary,
    onPrimary: Default.onPrimary,
    primaryContainer: Default.primaryContainerLight,
    onPrimaryContainer: Default.onPrimaryContainerLight,
    surface: Default.surfaceLight,
    tertiary: Colors.white,
    onTertiary: Colors.black,
    shadow: Default.shadow,
    outlineVariant: Default.outlineVariantLight,
  ),
  appBarTheme: defaultTheme.appBarTheme,
  floatingActionButtonTheme: defaultTheme.floatingActionButtonTheme,
  outlinedButtonTheme: defaultTheme.outlinedButtonTheme,
  iconButtonTheme: defaultTheme.iconButtonTheme,
  inputDecorationTheme: defaultTheme.inputDecorationTheme.copyWith(
    border: defaultTheme.inputDecorationTheme.border!,
    enabledBorder: defaultTheme.inputDecorationTheme.border!.copyWith(
      borderSide: defaultTheme.inputDecorationTheme.border!.borderSide.copyWith(
        color: Default.outlineVariantLight,
      )
    )
  ),
  snackBarTheme: defaultTheme.snackBarTheme.copyWith(
    backgroundColor: Colors.grey.shade900,
  )
);

final ThemeData darkTheme = ThemeData(
  colorScheme: ThemeData.dark().colorScheme.copyWith(
    primary: Default.primary,
    onPrimary: Default.onPrimary,
    primaryContainer: Default.primaryContainerDark,
    onPrimaryContainer: Default.onPrimaryContainerDark,
    surface: Default.surfaceDark,
    tertiary: Colors.black,
    onTertiary: Colors.white,
    shadow: Default.shadow,
    outlineVariant: Default.outlineVariantDark,
  ),
  appBarTheme: defaultTheme.appBarTheme,
  floatingActionButtonTheme: defaultTheme.floatingActionButtonTheme,
  outlinedButtonTheme: defaultTheme.outlinedButtonTheme,
  iconButtonTheme: defaultTheme.iconButtonTheme,
  inputDecorationTheme: defaultTheme.inputDecorationTheme.copyWith(
    border: defaultTheme.inputDecorationTheme.border!,
    enabledBorder: defaultTheme.inputDecorationTheme.border!.copyWith(
      borderSide: defaultTheme.inputDecorationTheme.border!.borderSide.copyWith(
        color: Default.outlineVariantDark,
      )
    )
  )
);

final ThemeData highContrastDarkTheme = ThemeData.dark().copyWith(
  colorScheme: const ColorScheme.highContrastDark(),
  floatingActionButtonTheme: defaultTheme.floatingActionButtonTheme,
  outlinedButtonTheme: defaultTheme.outlinedButtonTheme,
  iconButtonTheme: defaultTheme.iconButtonTheme,
  inputDecorationTheme: defaultTheme.inputDecorationTheme
);

final ThemeData highContrastLightTheme = ThemeData.light().copyWith(
  colorScheme: const ColorScheme.highContrastLight(),
  floatingActionButtonTheme: defaultTheme.floatingActionButtonTheme,
  outlinedButtonTheme: defaultTheme.outlinedButtonTheme,
  iconButtonTheme: defaultTheme.iconButtonTheme,
  inputDecorationTheme: defaultTheme.inputDecorationTheme
);
