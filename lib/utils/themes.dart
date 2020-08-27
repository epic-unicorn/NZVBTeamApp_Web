import 'package:flutter/material.dart';

final darkTheme = ThemeData(
  primaryColor: const Color(0xFF212121),
  secondaryHeaderColor: Colors.grey[800],
  focusColor: Color(0xFFdb8a2d),
  buttonColor: Color(0xFFdb8a2d),
  brightness: Brightness.dark,
  textSelectionColor: Colors.white,
  backgroundColor: const Color(0xFF212121),
  accentColor: Color(0xFFffba5d),
  accentIconTheme: IconThemeData(color: Colors.white),
  dividerColor: Colors.white
);

final lightTheme = ThemeData(
  primaryColor: Color(0xFFdb8a2d),
  secondaryHeaderColor: Colors.black12,
  focusColor: Colors.grey[300],
  buttonColor: Color(0xFFdb8a2d),
  brightness: Brightness.light,
  textSelectionColor: Colors.white,
  backgroundColor: Colors.white,
  accentColor: Color(0xFFffba5d),
  accentIconTheme: IconThemeData(color: Colors.white),
  dividerColor: Colors.black
);