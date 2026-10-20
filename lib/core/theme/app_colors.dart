import 'package:flutter/material.dart';

/// MonTrack Design System - Color Palette & Gradients
/// Modern Pastel Aurora & Frosted Glassmorphism
abstract class AppColors {
  // ── Canvas & Surfaces ──
  static const Color canvas = Color(0xFFF8FAFC); // Slate-50 canvas
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceRaised = Color(0xFFF1F5F9);
  static const Color surfaceMuted = Color(0xFFF8FAFC);

  // ── Typography & Ink ──
  static const Color inkPrimary = Color(0xFF0F172A); // Slate 900
  static const Color inkSecondary = Color(0xFF64748B); // Slate 500
  static const Color inkMuted = Color(0xFF94A3B8); // Slate 400

  // ── Borders ──
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderSubtle = Color(0x99E2E8F0);

  // ── Brand & Accents ──
  static const Color primarySlate = Color(0xFF0F172A);
  static const Color accentBlue = Color(0xFF2563EB);
  static const Color accentCyan = Color(0xFF38BDF8);
  static const Color accentViolet = Color(0xFF4F46E5);

  // ── Semantic ──
  static const Color income = Color(0xFF10B981); // Emerald 500
  static const Color incomeLight = Color(0xFFECFDF5);
  static const Color expense = Color(0xFFEF4444); // Rose 500
  static const Color expenseLight = Color(0xFFFEF2F2);
  static const Color warning = Color(0xFFF59E0B); // Amber 500
  static const Color warningLight = Color(0xFFFFFBEB);

  // ── Atmospheric Pastel Aurora Gradients ──
  static const LinearGradient auroraHeaderGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF86EFAC), // Soft Pastel Mint
      Color(0xFFA7F3D0), // Pastel Emerald
      Color(0xFFDBEAFE), // Light Sky Blue
      Color(0xFFBAE6FD), // Pastel Cyan
      Color(0xFF93C5FD), // Soft Aurora Blue
    ],
  );

  static const LinearGradient auroraMeshGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF86EFAC),
      Color(0xFFBBF7D0),
      Color(0xFFDBEAFE),
      Color(0xFFBAE6FD),
      Color(0xFF93C5FD),
    ],
  );

  // ── Luminous Glass Aurora Gradient (FAB + active pill chip) ──
  // Same as web: 135deg, translucent stops (alpha .92 / .85 / .85 / .92)
  static const LinearGradient luminousFabGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xEB2563EB), // rgba(37, 99, 235, .92)
      Color(0xD951C5F7), // rgba(81, 197, 247, .85)
      Color(0xD944E1CC), // rgba(68, 225, 204, .85)
      Color(0xEB34D399), // rgba(52, 211, 153, .92)
    ],
    stops: [0.0, 0.40, 0.85, 1.0],
  );

  // ── Floating Nav Dock tokens (from web BottomNavigation) ──
  // Active icon gradient: emerald → pale cyan (45%) → royal blue, diagonal (2,2)→(22,22) of a 24 box
  static const LinearGradient navActiveGradient = LinearGradient(
    begin: Alignment(-0.833, -0.833),
    end: Alignment(0.833, 0.833),
    colors: [Color(0xFF10B981), Color(0xFFAFD4DB), Color(0xFF2563EB)],
    stops: [0.0, 0.45, 1.0],
  );
  static const Color navActiveBackground = Color(0xB3F1F5F9); // slate-100 @ 70%
  static const Color navBorder = Color(0xCCE2E8F0); // slate-200 @ 80%

  // ── Hero Card Slate Gradient ──
  static const LinearGradient heroSlateGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF0F172A), // Slate 900
      Color(0xFF1E293B), // Slate 800
    ],
  );

  // ── Primary Action Button Gradient ──
  static const LinearGradient primaryButtonGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF2563EB), // Royal Blue
      Color(0xFF1D4ED8), // Deep Blue
      Color(0xFF4F46E5), // Indigo Accent
    ],
  );

  // ── Glassmorphism Design Tokens ──
  static const Color glassSurface = Color(0xD9FFFFFF); // 85% white
  static const Color glassSurfaceSubtle = Color(0x9EFFFFFF); // 62% white
  static const Color glassSurfaceRaised = Color(0xF2FFFFFF); // 95% white
  static const Color glassSurfaceMuted = Color(0x73FFFFFF); // 45% white
  static const Color glassBorder = Color(0xB3FFFFFF); // 70% white specular rim
  static const Color glassBorderSubtle = Color(0x66FFFFFF); // 40% white
  static const Color glassScrim = Color(0x400F172A); // 25% Slate 900 for frosted barrier

  static const LinearGradient glassCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xE6FFFFFF), // 90%
      Color(0xA6FFFFFF), // 65%
    ],
  );

  static const LinearGradient glassSheetGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xF7FFFFFF), // 97%
      Color(0xEBFFFFFF), // 92%
    ],
  );

  static const LinearGradient glassHeroDarkGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xF00F172A),
      Color(0xD91E293B),
    ],
  );

  static const List<BoxShadow> glassShadowSoft = [
    BoxShadow(
      color: Color(0x0C0F172A),
      blurRadius: 24,
      spreadRadius: -4,
      offset: Offset(0, 8),
    ),
    BoxShadow(
      color: Color(0x080F172A),
      blurRadius: 8,
      spreadRadius: -2,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> glassSheetShadow = [
    BoxShadow(
      color: Color(0x240F172A),
      blurRadius: 36,
      spreadRadius: -6,
      offset: Offset(0, -10),
    ),
  ];

  static const List<BoxShadow> cardShadow = glassShadowSoft;

  // ── Backward Compatibility Aliases ──
  static const Color primaryYellow = Color(0xFF2563EB);
  static const Color amberOrange = Color(0xFFF59E0B);
  static const Color deepOrange = Color(0xFFEF4444);
  static const LinearGradient yellowGradient = auroraHeaderGradient;
  static const Color darkPill = Color(0xFF0F172A);
  static const Color darkPillColor = Color(0xFF0F172A);
  static const Color textDark = Color(0xFF0F172A);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color accentExpense = Color(0xFFEF4444);
  static const Color bgOffWhite = Color(0xFFF8FAFC);
  static const Color toggleYellowBg = Color(0xFFF1F5F9);
  static const Color toggleBgColor = Color(0xFFF1F5F9);
  static const Color cardWhite = Color(0xFFFFFFFF);
}
