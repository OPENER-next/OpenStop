import 'package:flutter/material.dart';

TextStyle defaultStyle = TextStyle(color: Colors.grey, fontSize: 12.0);
TextStyle linkStyle = TextStyle(color: Colors.blue);

final ThemeData appTheme = ThemeData.light().copyWith(
    //primarySwatch: Colors.grey,
    primaryColor: Color(0xff00cc7f),
    accentColor: Color(0xfff0ca00),
    bottomAppBarColor: Color(0xff00cc7f),
    brightness: Brightness.dark,
    backgroundColor: const Color(0xFF212121),
    accentIconTheme: IconThemeData(color: Colors.black),
    dividerColor: Colors.black12,
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
        backgroundColor: Colors.white,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(Color(0xff00cc7f)),
        padding: MaterialStateProperty.all(EdgeInsets.all(20.0)),
        textStyle: MaterialStateProperty.all(TextStyle(fontSize: 24))
      )
    ),
  );
