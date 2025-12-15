import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primarySwatch: Colors.lightGreen,
    scaffoldBackgroundColor: Colors.white,
    colorScheme: _colorSchemeLight,
    appBarTheme: const AppBarTheme(
      // backgroundColor: Colors.blue,
      // foregroundColor: Colors.white,
    ),
    textTheme: const TextTheme(),
    searchBarTheme: _searchBarThemeData,
  );
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

SearchBarThemeData _searchBarThemeData = SearchBarThemeData(
  elevation: WidgetStatePropertyAll(0),
  shape: WidgetStatePropertyAll(
    RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(50),
      side: BorderSide(color: Colors.green),
    ),
  ),
  backgroundColor: WidgetStatePropertyAll(Colors.white),
  hintStyle: WidgetStatePropertyAll(TextStyle(color: Colors.grey[600])),
);
