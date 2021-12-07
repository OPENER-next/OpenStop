import 'package:flutter/material.dart';

class CustomColors {
  static const Color darkGreen = Color(0xff407336);
  static const Color green = Color(0xff6cc15a);
  static const Color lightGreen = Color(0xffe9ffe4);
}

final ThemeData appTheme = ThemeData.light().copyWith(
    colorScheme: ThemeData.light().colorScheme.copyWith(
      primary: CustomColors.green,
      secondary: CustomColors.lightGreen,
      onPrimary: Colors.white,
      onSecondary: CustomColors.darkGreen,
      background: Colors.white,
      surface: Colors.white
    ),
    textTheme: const TextTheme(
        subtitle1: TextStyle(
          color: Colors.black87
        ),
        headline5: TextStyle(
            color: Colors.black87,
        ),
        bodyText2: TextStyle(
            color: Colors.black87,
        ),
        bodyText1: TextStyle(
            color: Colors.black87,
        ),
        caption: TextStyle(
          color: Colors.black45,
        ),
        overline: TextStyle(
          fontSize: 12,
          color: Colors.black38,
        ),
    ),
    buttonTheme: ButtonThemeData(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18.0)
        ),
        buttonColor: Colors.yellow,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
        foregroundColor: Colors.black,
        backgroundColor: Colors.white,
        smallSizeConstraints: BoxConstraints.tight(const Size.square(48)),
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
    iconTheme: const IconThemeData(
      color: Colors.black87
    ),
    inputDecorationTheme: ThemeData.light().inputDecorationTheme.copyWith(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
      border: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12.0))
      )
    )
  );
