import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../shared/theme/app_theme.dart';
import 'maamora_tokens.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// MAAMORA THEME — the app theme, upgraded in place.
///
/// Built on the existing `AppTheme.lightTheme` (so every hard-tuned detail
/// like CTA height / radius / Cairo fonts stays intact) then layered with the
/// Design System improvements: cream scaffold, unified input focus glow,
/// orange progress bars, premium snackbars. Dark tokens are defined in
/// `maamora_tokens.dart` and can be wired to `context.theme` later.
/// ─────────────────────────────────────────────────────────────────────────────

class MaamoraTheme {
  MaamoraTheme._();

  static ThemeData light() {
    final base = AppTheme.lightTheme;

    // Cream scaffold per the Maamora charte; cards stay pure white.
    final withCream = base.copyWith(
      scaffoldBackgroundColor: MaamoraColors.scaffold,
      colorScheme: base.colorScheme.copyWith(
        surface: MaamoraColors.surface,
        onSurface: MaamoraColors.textPrimary,
        secondary: MaamoraColors.textPrimary,
      ),
      inputDecorationTheme: base.inputDecorationTheme.copyWith(
        fillColor: MaamoraColors.surface,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(MaamoraRadius.input),
          borderSide: const BorderSide(
            color: MaamoraColors.primary,
            width: 1.6,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(MaamoraRadius.input),
          borderSide: const BorderSide(
            color: MaamoraColors.border,
          ),
        ),
      ),
      appBarTheme: base.appBarTheme.copyWith(
        backgroundColor: MaamoraColors.scaffold,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      snackBarTheme: base.snackBarTheme,
    );

    return withCream;
  }

  // ── Typographic scale (used by re-styled screens) ──────────────────────────

  /// The single hero metric per screen: 48px+ bold.
  static TextStyle heroMetric() => GoogleFonts.cairo(
        fontSize: 50,
        fontWeight: FontWeight.w800,
        height: 1.05,
        color: Colors.white,
      );

  static TextStyle heroMetricDark() => GoogleFonts.cairo(
        fontSize: 50,
        fontWeight: FontWeight.w800,
        height: 1.05,
        color: MaamoraColors.textPrimary,
      );

  static TextStyle screenTitle() => GoogleFonts.cairo(
        fontSize: 26,
        fontWeight: FontWeight.w800,
        color: MaamoraColors.textPrimary,
        height: 1.15,
      );

  static TextStyle support() => GoogleFonts.cairo(
        fontSize: 13.5,
        fontWeight: FontWeight.w500,
        color: MaamoraColors.textSecondary,
        height: 1.5,
      );

  static TextStyle sectionHeader() => GoogleFonts.cairo(
        fontSize: 16,
        fontWeight: FontWeight.w800,
        color: MaamoraColors.textPrimary,
      );

  static TextStyle eyebrow() => GoogleFonts.cairo(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
        color: MaamoraColors.textSecondary,
      );

  static TextStyle metricValue() => GoogleFonts.cairo(
        fontSize: 17,
        fontWeight: FontWeight.w800,
        color: MaamoraColors.textPrimary,
      );
}
