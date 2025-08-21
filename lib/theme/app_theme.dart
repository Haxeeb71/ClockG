import 'package:flutter/material.dart';

class AppTheme {
  static const Color cyberYellow = Color(0xFFFFD300);
  static const Color cyberBlack = Color(0xFF0A0A0A);
  static const Color cyberGunmetal = Color(0xFF1A1F24);
  static const Color accentTeal = Color(0xFF00FFC6);

  static ThemeData light() {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: cyberYellow,
        brightness: Brightness.light,
        primary: cyberYellow,
        secondary: accentTeal,
        surface: Colors.white,
        onPrimary: Colors.black,
      ),
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: cyberYellow,
        foregroundColor: Colors.black,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        selectedItemColor: cyberYellow,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
      ),
      textTheme: base.textTheme.apply(
        bodyColor: Colors.black,
        displayColor: Colors.black,
      ),
    );
  }

  static ThemeData dark() {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: cyberYellow,
        brightness: Brightness.dark,
        primary: cyberYellow,
        secondary: accentTeal,
        surface: cyberGunmetal,
        onPrimary: Colors.black,
      ),
      scaffoldBackgroundColor: cyberBlack,
      appBarTheme: const AppBarTheme(
        backgroundColor: cyberGunmetal,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: cyberYellow,
        foregroundColor: Colors.black,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        selectedItemColor: cyberYellow,
        unselectedItemColor: Colors.grey,
        backgroundColor: cyberGunmetal,
        type: BottomNavigationBarType.fixed,
      ),
      textTheme: base.textTheme.apply(
        bodyColor: Colors.white,
        displayColor: Colors.white,
      ),
    );
  }
}


