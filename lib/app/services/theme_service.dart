import 'package:flutter/material.dart';

class ThemeService extends ValueNotifier<ThemeMode> {
  ThemeService._() : super(ThemeMode.light);
  static final ThemeService instance = ThemeService._();

  bool get isDark => value == ThemeMode.dark;

  void toggle() {
    value = isDark ? ThemeMode.light : ThemeMode.dark;
  }

  static const Color primary = Color.fromARGB(255, 109, 177, 177);
  static const Color accent = Color.fromARGB(255, 253, 170, 41);

  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(seedColor: primary, brightness: Brightness.light),
    primaryColor: primary,
    canvasColor: accent,
    hintColor: const Color.fromARGB(255, 60, 60, 60),
    shadowColor: const Color.fromARGB(255, 160, 160, 160),
    scaffoldBackgroundColor: Colors.white,
    cardColor: Colors.white,
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(seedColor: primary, brightness: Brightness.dark),
    primaryColor: primary,
    canvasColor: accent,
    hintColor: const Color.fromARGB(255, 200, 200, 200),
    shadowColor: const Color.fromARGB(255, 100, 100, 100),
    scaffoldBackgroundColor: const Color(0xFF121212),
    cardColor: const Color(0xFF1E1E1E),
  );
}
