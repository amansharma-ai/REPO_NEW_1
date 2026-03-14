import 'package:flutter/material.dart';

class AppColors {
  // ── Primary & Accent ──────────────────────────────────────────────────
  static const Color primary = Color(0xFF00C9A7); // vibrant teal / emerald
  static const Color primaryDark = Color(0xFF00A88A);
  static const Color primaryLight = Color(0xFF33D4B9);

  // ── Backgrounds ───────────────────────────────────────────────────────
  static const Color background = Color(0xFF0D0D0D);
  static const Color surface = Color(0xFF1A1A2E);
  static const Color surfaceLight = Color(0xFF252542);
  static const Color card = Color(0xFF16213E);

  // ── Macro colours ─────────────────────────────────────────────────────
  static const Color calories = Color(0xFFFF6B35); // orange
  static const Color protein = Color(0xFF4DA8FF); // blue
  static const Color carbs = Color(0xFF4ADE80); // green
  static const Color fat = Color(0xFFFF6B9D); // pink

  // ── Semantic ──────────────────────────────────────────────────────────
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFFBBF24);
  static const Color error = Color(0xFFEF4444);

  // ── Text ──────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B0C3);
  static const Color textHint = Color(0xFF6B6B80);

  // ── Misc ──────────────────────────────────────────────────────────────
  static const Color divider = Color(0xFF2A2A3D);
  static const Color shimmer = Color(0xFF2A2A3D);

  // ── Gradients ─────────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, Color(0xFF00E5BF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [surface, card],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
