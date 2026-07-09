import 'package:flutter/material.dart';

/// Palette centralisée — ne pas coder de couleurs en dur (Color(0xFF...))
/// directement dans vos écrans, utilisez ces constantes pour rester cohérent.
class AppColors {
  AppColors._();

  static const Color primary = Color(0xFFCB8A2E); // ocre/doré Maamora
  static const Color background = Color(0xFFFAFAFA);
  static const Color cardBorder = Color(0xFFE0E0E0);

  static const Color tierBronze = Color(0xFFCD7F32);
  static const Color tierSilver = Color(0xFFB0B0B8);
  static const Color tierGold = Color(0xFFD4AF37);
  static const Color tierPlatinum = Color(0xFF7DE3E8);

  static const Color success = Color(0xFF2E7D32);

  // --- Light-mode text/surface tokens ---
  static const Color onBackground = Color(0xFF231A12); // near-black, warm
  static const Color surface = Color(0xFFFFFFFF);
  static const Color outlineVariant = Color(0xFFE0D9CC);

  // --- CTA (Start application button, terracotta like the wireframe) ---
  static const Color primaryContainer = Color(0xFFD9603B);
  static const Color onPrimaryContainer = Color(0xFFFFFFFF);

  // --- Accent colors for benefit icons ---
  static const Color secondary = Color(0xFF8A6D3B);
  static const Color secondaryContainer = Color(0xFFFCEBC9);
  static const Color tertiary = Color(0xFF3F7A5A);
  static const Color tertiaryContainer = Color(0xFFDCEEE3);

  // --- Surface tokens (cards / containers) ---
  static const Color surfaceContainer = Color(0xFFFFFFFF); // benefit cards
  static const Color surfaceContainerHigh = Color(
    0xFFFCF8F2,
  ); // requirements card (slightly tinted)

  // --- On-surface text tokens ---
  static const Color onSurface = Color(0xFF231A12); // same as onBackground
  static const Color onSurfaceVariant = Color(
    0xFF7A7168,
  ); // muted secondary text/icons

  // --- Extra surface tiers ---
  static const Color surfaceContainerLow = Color(
    0xFFF3EEE6,
  ); // light input fill

  // --- Tertiary "on" token (for the tertiaryContainer badge) ---
  static const Color onTertiaryContainer = Color(0xFF1B4332);

  // --- Error tokens ---
  static const Color error = Color(0xFFB3261E);
  static const Color errorContainer = Color(0xFFF9DEDC);
}
