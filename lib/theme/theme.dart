import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primarySwatch: Colors.green,
    scaffoldBackgroundColor: Colors.white,
    colorScheme: _colorSchemeLight,
    appBarTheme: const AppBarTheme(
      // backgroundColor: Colors.blue,
      // foregroundColor: Colors.white,
    ),
    textTheme: const TextTheme(),
  );

  // static final ThemeData darkTheme = ThemeData(
  //   brightness: Brightness.dark,
  //   primarySwatch: Colors.blue,
  //   scaffoldBackgroundColor: Colors.black,
  //   appBarTheme: const AppBarTheme(
  //     backgroundColor: Colors.black,
  //     foregroundColor: Colors.white,
  //   ),
  //   textTheme: const TextTheme(),
  // );
}

ColorScheme _colorSchemeLight = const ColorScheme.light(
  brightness: Brightness.light,
  primary: Colors.green,
  onPrimary: Colors.black,
  secondary: Colors.orangeAccent,
  onSecondary: Colors.black,
  error: Colors.redAccent,
  onError: Colors.white,
  surface: Colors.white,
  onSurface: Colors.black,
);
