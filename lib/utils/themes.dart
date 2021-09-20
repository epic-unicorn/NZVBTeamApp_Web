import 'package:flutter/material.dart';

final darkTheme = ThemeData(
    primaryColor: Color(0xFF212121),
    focusColor: Color(0xFFdb8a2d),
    secondaryHeaderColor: Colors.grey[800],
    brightness: Brightness.dark,
    iconTheme: IconThemeData(color: Colors.white),
    backgroundColor: const Color(0xFF212121),
    accentColor: Color(0xFFffba5d),
    accentIconTheme: IconThemeData(color: Colors.white),
    dividerColor: Colors.white);

final lightTheme = ThemeData(
    primaryColor: Colors.amber,
    secondaryHeaderColor: Colors.black12,
    focusColor: Colors.grey[300],
    brightness: Brightness.light,
    accentColor: Color(0xFFffba5d),
    accentIconTheme: IconThemeData(color: Colors.white),
    iconTheme: IconThemeData(color: Colors.white),
    backgroundColor: Colors.white,
    dividerColor: Colors.black);
