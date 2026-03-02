import 'package:flutter/material.dart';

class AppTheme {
  static const primary = Color.fromARGB(255, 19, 109, 236);
  static const primaryLight = Color(0xFFEBF2FF);
  static const background = Color(0xFFF4F6FB);
  static const surface = Color(0xFFFFFFFF);
  static const border = Color(0xFFE5E7EB);
  static const textPrimary = Color(0xFF111827);
  static const textSecondary = Color(0xFF6B7280);
  static const textMuted = Color(0xFF9CA3AF);
  // Strict Semantic Colors
  static const success = Color(0xFF10B981); // > 90%
  static const successLight = Color(0xFFD1FAE5);
  static const warning = Color(0xFFF59E0B); // 80% - 90%
  static const warningLight = Color(0xFFFEF3C7);
  static const danger = Color(0xFFEF4444); // < 80%
  static const dangerLight = Color(0xFFFEE2E2);

  static const shadowColor = Color(0x1A1E6FFF);
  static const List<BoxShadow> cardShadow = [
    BoxShadow(color: shadowColor, blurRadius: 18, offset: Offset(0, 4)),
  ];

  static List<BoxShadow>? softCardShadow;

  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: primary),
    scaffoldBackgroundColor: background,
    fontFamily: 'Segoe UI',
    cardTheme: CardThemeData(
      elevation: 0, // Handled by custom hover cards
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: surface,
    ),
  );
}
