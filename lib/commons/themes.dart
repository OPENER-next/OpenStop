import 'package:flutter/material.dart';

TextStyle defaultStyle = TextStyle(color: Colors.grey, fontSize: 12.0);
TextStyle linkStyle = TextStyle(color: Colors.blue);

final ThemeData appTheme = ThemeData.light().copyWith(
    //primarySwatch: Colors.grey,
    colorScheme: ThemeData.light().colorScheme.copyWith(
      primary: const Color(0xff00cc7f),
      secondary: const Color(0xfff0ca00),
      brightness: Brightness.dark,
      background: const Color(0xFF212121),
    ),
    textTheme: const TextTheme(
        headline5: TextStyle(
            color: Colors.black87,
        ),
        bodyText2: TextStyle(
            color: Colors.black87,
        ),
        bodyText1: TextStyle(
            color: Colors.black87,
        )
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
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(Color(0xff00cc7f)),
        padding: MaterialStateProperty.all(EdgeInsets.all(20.0)),
        textStyle: MaterialStateProperty.all(TextStyle(fontSize: 24))
      )
    ),
  );
