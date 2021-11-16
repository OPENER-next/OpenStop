import 'package:flutter/material.dart';

final ThemeData appTheme = ThemeData.light().copyWith(
    colorScheme: ThemeData.light().colorScheme.copyWith(
      primary: const Color(0xff00cc7f),
      onPrimary: Colors.white,
      secondary: const Color(0xfff0ca00),
      background: const Color(0xfff7f7f7),
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
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(Color(0xff00cc7f)),
        padding: MaterialStateProperty.all(EdgeInsets.all(20.0)),
        textStyle: MaterialStateProperty.all(TextStyle(fontSize: 24))
      )
    ),
    iconTheme: IconThemeData(
      color: Colors.black87
    )
  );
