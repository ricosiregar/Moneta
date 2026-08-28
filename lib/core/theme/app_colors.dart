import 'package:flutter/material.dart';

abstract class AppColors {
  static const Color primaryYellow = Color(0xFFFFEA00);
  static const Color amberOrange = Color(0xFFFFA700);
  static const Color deepOrange = Color(0xFFFF7200);

  static const LinearGradient yellowGradient = LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [
      Color(0xFFFFEA00), // Vibrant bright yellow (top right)
      Color(0xFFFFA700), // Warm amber yellow (center)
      Color(0xFFFF7200), // Energetic golden orange (bottom left)
    ],
  );

  static const Color darkPill = Color(0xFF131D26);
  static const Color textDark = Color(0xFF141414);
  static const Color textMuted = Color(0xFF8E8E93);
  static const Color accentExpense = Color(
    0xFF2B5B84,
  ); // Denim Blue for expenses & accents

  // Backgrounds
  static const Color bgOffWhite = Color(0xFFF9F9F5);
  static const Color toggleYellowBg = Color(0xFFFFF7D6);
  static const Color cardWhite = Colors.white;
}
