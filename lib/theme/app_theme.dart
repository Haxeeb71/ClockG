import 'package:flutter/material.dart';

class AppTheme {
  static const Color cyberYellow = Color(0xFFFFD300);
  static const Color cyberBlack = Color(0xFF0A0D12);
  static const Color cyberGunmetal = Color(0xFF141923);
  static const Color cyberSurfaceElevated = Color(0xFF1D2330);
  static const Color cyberBorder = Color(0xFF273243);
  static const Color accentTeal = Color(0xFF00FFC6);
  static const Color accentCyan = Color(0xFF00F0FF);
  static const Color accentOrange = Color(0xFFFF9500);
  static const Color accentRed = Color(0xFFFF3366);
  static const Color textMuted = Color(0xFF8A99AD);
  static const Color textBright = Color(0xFFF1F5F9);

  static ThemeData light() {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: const Color(0xFFF4F6F9),
      colorScheme: ColorScheme.fromSeed(
        seedColor: cyberYellow,
        brightness: Brightness.light,
        primary: const Color(0xFFE6BE00),
        secondary: const Color(0xFF00BFA5),
        surface: Colors.white,
        onPrimary: Colors.black,
        onSurface: const Color(0xFF1E293B),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFF4F6F9),
        foregroundColor: Color(0xFF0F172A),
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: Color(0xFF0F172A),
          fontSize: 22,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white,
        elevation: 10,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        elevation: 3,
        indicatorColor: cyberYellow.withValues(alpha: 0.35),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            );
          }
          return const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xFF64748B),
          );
        }),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: cyberYellow,
        foregroundColor: Colors.black,
        elevation: 4,
        shape: StadiumBorder(),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF1F5F9),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: cyberYellow, width: 1.5),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.black;
          return Colors.white;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return cyberYellow;
          return const Color(0xFFCBD5E1);
        }),
      ),
    );
  }

  static ThemeData dark() {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: cyberBlack,
      colorScheme: ColorScheme.fromSeed(
        seedColor: cyberYellow,
        brightness: Brightness.dark,
        primary: cyberYellow,
        secondary: accentTeal,
        surface: cyberGunmetal,
        onPrimary: Colors.black,
        onSurface: textBright,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: cyberBlack,
        foregroundColor: textBright,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: textBright,
          fontSize: 22,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
      ),
      cardTheme: CardThemeData(
        color: cyberGunmetal,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: cyberBorder, width: 1),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: cyberGunmetal,
        elevation: 16,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: cyberBorder, width: 1),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: cyberGunmetal,
        elevation: 0,
        indicatorColor: cyberYellow.withValues(alpha: 0.2),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: cyberYellow, size: 24);
          }
          return const IconThemeData(color: textMuted, size: 22);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: cyberYellow,
              letterSpacing: 0.2,
            );
          }
          return const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: textMuted,
          );
        }),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: cyberYellow,
        foregroundColor: Colors.black,
        elevation: 8,
        shape: const StadiumBorder(),
        splashColor: cyberYellow.withValues(alpha: 0.5),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cyberSurfaceElevated,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        labelStyle: const TextStyle(color: textMuted),
        hintStyle: const TextStyle(color: Color(0xFF536377)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: cyberBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: cyberYellow, width: 1.5),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.black;
          return textMuted;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return cyberYellow;
          return const Color(0xFF1F2937);
        }),
        trackOutlineColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.transparent;
          return cyberBorder;
        }),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: cyberYellow,
        inactiveTrackColor: cyberBorder,
        thumbColor: cyberYellow,
        overlayColor: cyberYellow.withValues(alpha: 0.2),
        valueIndicatorColor: cyberYellow,
        valueIndicatorTextStyle: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: cyberSurfaceElevated,
        selectedColor: cyberYellow,
        labelStyle: const TextStyle(color: textBright, fontSize: 13),
        secondaryLabelStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.w700),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: cyberBorder, width: 1),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: cyberBorder,
        thickness: 1,
        space: 1,
      ),
      textTheme: base.textTheme.apply(
        bodyColor: textBright,
        displayColor: textBright,
      ),
    );
  }
}


