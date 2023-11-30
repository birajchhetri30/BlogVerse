import 'package:flutter/material.dart';

class CustomTheme {
  ThemeData getTheme() {
    return ThemeData(
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: Color.fromARGB(193, 52, 31, 100),
        onPrimary: Colors.white,
        secondary: Color.fromARGB(193, 227, 192, 96),
        onSecondary: Colors.white,
        background: Color.fromARGB(193, 75, 45, 146),
        onBackground: Colors.grey,
        surface: Colors.black,
        onSurface: Colors.white,
        error: Colors.red,
        onError: Colors.white
        )
    );
  }
}
