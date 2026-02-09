import 'package:flutter/material.dart';

abstract class AppColors {
  //Dark Theme colors
  static const darkTextColor = Color(0xFFffffff);
  static const darkBackgroundColor = Color(0xFF253137);
  static const darkPrimaryColor = Color(0xFF00e677);
  static const darkPrimaryFgColor = Color(0xFF253137);
  static const darkSecondaryColor = Color(0xFF00bd61);
  static const darkSecondaryFgColor = Color(0xFF253137);

  //Light Theme colors
  static const lightTextColor = Color(0xFF253137);
  static const lightBackgroundColor = Color(0xFFECEFF1);
  static const lightPrimaryColor = Color(0xFF00bd61);
  static const lightPrimaryFgColor = Color(0xFFffffff);
  static const lightSecondaryColor = Color(0xFF008C48);
  static const lightSecondaryFgColor = Color(0xFFffffff);

  //Accent colors
  static const accentColor = Color(0xFF9d00e6);
  static const accentFgColor = Color(0xFFffffff);
}

const ColorScheme lightColorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: AppColors.lightPrimaryColor,
  onPrimary: AppColors.lightPrimaryFgColor,
  secondary: AppColors.lightSecondaryColor,
  onSecondary: AppColors.lightSecondaryFgColor,
  tertiary: AppColors.accentColor,
  onTertiary: AppColors.accentFgColor,
  error: Color(0xffB3261E),
  onError: Colors.white,
  surface: AppColors.lightBackgroundColor,
  onSurface: AppColors.lightTextColor,
);

const ColorScheme darkColorScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: AppColors.darkPrimaryColor,
  onPrimary: AppColors.darkPrimaryFgColor,
  secondary: AppColors.darkSecondaryColor,
  onSecondary: AppColors.darkSecondaryFgColor,
  tertiary: AppColors.accentColor,
  onTertiary: AppColors.accentFgColor,
  error: Color(0xffF2B8B5),
  onError: Color(0xff601410),
  surface: AppColors.darkBackgroundColor,
  onSurface: AppColors.darkTextColor,
);
