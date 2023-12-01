import 'package:flutter/material.dart';

class CustomTheme {
  ThemeData getTheme() {
    return ThemeData(
        colorScheme: const ColorScheme(
            brightness: Brightness.light,
            primary: Color.fromARGB(193, 40, 31, 80),
            onPrimary: Colors.white,
            secondary: Color.fromARGB(255, 255, 216, 148),
            onSecondary: Colors.white,
            background: Color.fromARGB(193, 90, 77, 156),
            onBackground: Color.fromARGB(255, 190, 190, 190),
            surface: Colors.black,
            onSurface: Colors.white,
            error: Colors.red,
            onError: Colors.white),
        useMaterial3: true,
        fontFamily: 'Bahnschrift');
  }
}
