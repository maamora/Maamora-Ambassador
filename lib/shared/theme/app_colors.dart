import 'package:flutter/material.dart';

/// Palette centralisée — ne pas coder de couleurs en dur (Color(0xFF...))
/// directement dans vos écrans, utilisez ces constantes pour rester cohérent.
class AppColors {
  AppColors._();

  // ── Brand tokens ──────────────────────────────────────────────────────────
  static const Color primary = Color(0xFFfb7701); // Maamora orange
  static const Color secondary = Color(0xFF1a2433); // dark navy

  // ── Background & surface ──────────────────────────────────────────────────
  static const Color background = Color(0xFFFAF5F0); // warm cream
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceContainer = Color(0xFFFFFFFF);
  static const Color surfaceContainerHigh = Color(0xFFFCF8F2);
  static const Color surfaceContainerLow = Color(0xFFF5EDE4); // light input fill

  // ── Text / on-surface tokens ───────────────────────────────────────────────
  static const Color onBackground = Color(0xFF1a2433);
  static const Color onSurface = Color(0xFF1a2433);
  static const Color onSurfaceVariant = Color(0xFF8A8078);
  static const Color onPrimaryContainer = Color(0xFFFFFFFF);

  // ── CTA ────────────────────────────────────────────────────────────────────
  static const Color primaryContainer = Color(0xFFfb7701); // orange CTA

  // ── Border ─────────────────────────────────────────────────────────────────
  static const Color cardBorder = Color(0xFFE8DDD3);
  static const Color outlineVariant = Color(0xFFE0D5C8);

  // ── Tier colors ────────────────────────────────────────────────────────────
  static const Color tierBronze = Color(0xFFCD7F32);
  static const Color tierSilver = Color(0xFFB0B0B8);
  static const Color tierGold = Color(0xFFD4AF37);
  static const Color tierPlatinum = Color(0xFF7DE3E8);

  // ── Status ─────────────────────────────────────────────────────────────────
  static const Color success = Color(0xFF2E7D32);
  static const Color error = Color(0xFFB3261E);
  static const Color errorContainer = Color(0xFFF9DEDC);

  // ── Accent containers ──────────────────────────────────────────────────────
  static const Color secondaryContainer = Color(0xFFFCEBC9);
  static const Color tertiary = Color(0xFF3F7A5A);
  static const Color tertiaryContainer = Color(0xFFDCEEE3);
  static const Color onTertiaryContainer = Color(0xFF1B4332);
}
