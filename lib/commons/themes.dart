import 'package:flutter/material.dart';

class CustomColors {
  static const Color DarkGreen = const Color(0xff407336);
  static const Color Green = const Color(0xff6cc15a);
  static const Color LightGreen = const Color(0xffe9ffe4);
}

final ThemeData appTheme = ThemeData.light().copyWith(
    colorScheme: ThemeData.light().colorScheme.copyWith(
      primary: CustomColors.Green,
      secondary: CustomColors.LightGreen,
      onPrimary: Colors.white,
      onSecondary: CustomColors.DarkGreen,
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
        smallSizeConstraints: BoxConstraints.tight(Size.square(48)),
        shape: const RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(
            const Radius.circular(10)
          )
        )
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
            primary: CustomColors.Green,
            padding: EdgeInsets.all(20.0),
            textStyle:TextStyle(fontSize: 24)
        )
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
            primary: CustomColors.DarkGreen,
            backgroundColor: CustomColors.LightGreen,
            side: BorderSide(
              style: BorderStyle.none,
            )
        )
    ),
    iconTheme: IconThemeData(
      color: Colors.black87
    )
  );
