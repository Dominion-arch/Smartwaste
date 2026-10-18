import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Palette lifted from the web app's main.css so the mobile app feels identical.
class C {
  static const bg = Color(0xFF0A0C0F);
  static const surface = Color(0xFF111318);
  static const surface2 = Color(0xFF181C23);
  static const border = Color(0xFF232830);
  static const border2 = Color(0xFF2E3540);
  static const text = Color(0xFFE8EDF5);
  static const text2 = Color(0xFF8B95A5);
  static const text3 = Color(0xFF55616F);
  static const accent = Color(0xFF00E5A0);
  static const warn = Color(0xFFF5A623);
  static const danger = Color(0xFFFF4757);
  static const info = Color(0xFF3D9EFF);
  static const purple = Color(0xFFB57BEE);

  static Color fill(double p) => p >= 90
      ? danger
      : p >= 75
          ? warn
          : p >= 50
              ? info
              : accent;
}

TextStyle mono({double size = 12, Color color = C.text3, FontWeight? weight}) =>
    GoogleFonts.spaceMono(fontSize: size, color: color, fontWeight: weight);

ThemeData buildTheme(Color primary) {
  final base = ThemeData.dark(useMaterial3: true);
  final text = GoogleFonts.syneTextTheme(base.textTheme)
      .apply(bodyColor: C.text, displayColor: C.text);
  OutlineInputBorder border(Color c) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: c));

  return base.copyWith(
    scaffoldBackgroundColor: C.bg,
    colorScheme: ColorScheme.dark(
      primary: primary,
      secondary: primary,
      surface: C.surface,
      error: C.danger,
    ),
    textTheme: text,
    appBarTheme: AppBarTheme(
      backgroundColor: C.surface,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: text.titleMedium,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: C.surface2,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      labelStyle: mono(size: 11),
      hintStyle: const TextStyle(color: C.text3),
      border: border(C.border2),
      enabledBorder: border(C.border2),
      focusedBorder: border(primary),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: primary == C.accent ? Colors.black : Colors.white,
        minimumSize: const Size.fromHeight(48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: GoogleFonts.syne(fontWeight: FontWeight.w700, fontSize: 14),
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: C.surface,
      selectedItemColor: primary,
      unselectedItemColor: C.text3,
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle: GoogleFonts.syne(fontSize: 11, fontWeight: FontWeight.w700),
      unselectedLabelStyle: GoogleFonts.syne(fontSize: 11),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: C.surface2,
      contentTextStyle: mono(size: 12, color: primary),
      behavior: SnackBarBehavior.floating,
    ),
  );
}
