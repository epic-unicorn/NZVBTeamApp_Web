import 'package:flutter/material.dart';

final darkTheme = ThemeData(
    primaryColor: const Color(0xFF212121),
    secondaryHeaderColor: Colors.grey[800],
    focusColor: Color(0xFFdb8a2d),
    brightness: Brightness.dark,
    backgroundColor: const Color(0xFF212121),
    accentColor: Color(0xFFffba5d),
    accentIconTheme: IconThemeData(color: Colors.white),
    dividerColor: Colors.white);

final lightTheme = ThemeData(
    primaryColor: Color(0xFFdb8a2d),
    secondaryHeaderColor: Colors.black12,
    focusColor: Colors.grey[300],
    brightness: Brightness.light,
    backgroundColor: Colors.white,
    accentColor: Color(0xFFffba5d),
    accentIconTheme: IconThemeData(color: Colors.white),
    dividerColor: Colors.black);
