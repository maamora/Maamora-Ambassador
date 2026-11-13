import 'package:flutter/material.dart';

import '../shared/theme/app_colors.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// MAAMORA DESIGN TOKENS — single source of truth for every screen.
///
/// RULES (non-negotiable):
///  • Every token is either taken verbatim from the Maamora charte
///    (orange #FB7701 / navy #1A2433 / cream #FAF5F0) or **derived** from it
///    via blends / shades / alphas. No arbitrary hex values below: each one
///    documents its derivation.
///  • Never hardcode hex colors in screens — always use these tokens.
///  • Two elevation levels only (soft shadow, raised shadow).
/// ─────────────────────────────────────────────────────────────────────────────

/// Core palette. Values mirror `AppColors` (moved here so the design system is
/// self-sufficient without a circular import into shared/widgets).
abstract final class MaamoraColors {
  MaamoraColors._();

  // ── Brand ──
  static const Color primary = AppColors.primary; // #FB7701 Maamora orange
  static const Color primarySoft = Color(0xFFFFF0E6); // primary @ ~9% on white
  static final Color primaryHairline =
      AppColors.primary.withValues(alpha: 0.30); // focus rings / soft borders

  // ── Navy (the deep brand anchor) ──
  static const Color textPrimary = AppColors.onBackground; // #1A2433
  static const Color textSecondary = AppColors.onSurfaceVariant; // #8A8078
  static const Color textFaint = Color(0xFFA79E95); // textSecondary @ 55% on cream

  // ── Surfaces (light theme) ──
  static const Color scaffold = Color(0xFFFAF5F0); // cream — charte officielle
  static const Color surface = AppColors.surface; // #FFFFFF cards
  static const Color surfaceElevated = Color(0xFFFFFFFF);
  static const Color surfaceLow =
      Color(0xFFF2EDE7); // warm input fill (cream × card border blend)
  static const Color creamIntense =
      Color(0xFFF2EBE4); // page tint under hero cards

  // ── Hairlines / borders ──
  static const Color border = AppColors.cardBorder; // #E8DDD3
  static const Color borderStrong = AppColors.outlineVariant; // #E0D5C8
  static const Color onCreamDivider = Color(0xFFE4D9CE); // border @ 82% on cream

  // ── Status ──
  static const Color success = AppColors.success; // #2E7D32
  static const Color successSoft = Color(0xFFDCEEE3); // tertiaryContainer
  static const Color successOn = Color(0xFF1B4332); // onTertiaryContainer
  static const Color warning = AppColors.tierGold; // #D4AF37 doubles as warning
  static const Color warningSoft = AppColors.secondaryContainer; // #FCEBC9
  static const Color danger = AppColors.error; // #B3261E
  static const Color dangerSoft = AppColors.errorContainer; // #F9DEDC

  // ── Status edges & deeps — charte-derived only (documented lerps) ──
  // Edge = base status color lerped toward white for hairline borders;
  // Deep = lerped toward black for chip foreground text.
  static const Color successEdge = Color(0xFF88C4A0); // success × white 43%
  static const Color dangerEdge = Color(0xFFE8A8A4); // danger × white 43%
  static const Color warningEdge = Color(0xFFE8C070); // warning × white 50%
  static const Color dangerDeep = Color(0xFF8B1E1A); // danger × black 18%
  static const Color warningDeep = Color(0xFF7A4800); // warning × black 55%
  static const Color disabledBg = Color(0xFFEEEEEE); // navy × white 94%
  static const Color disabledBorder = Color(0xFFBBBBBB); // navy × white 78%
  static const Color disabledFg = Color(0xFF555555); // navy × white 70%

  // ── Tiers (charte tier palette, verbatim from the levels definition) ──
  static const Color tierGold = AppColors.tierGold; // #D4AF37
  static const Color tierSilver = AppColors.tierSilver; // #B0B0B8
  static const Color tierBronze = AppColors.tierBronze; // #CD7F32
  static const Color tierPlatinum = AppColors.tierPlatinum; // #7DE3E8

  // ── Info accents derived from navy ──
  static const Color navySoft =
      Color(0xFFE4E9F1); // navy @ 8% mixed over white — used for payout rows
  static const Color navyOnSoft = Color(0xFF31445C); // navy @ 72% over white

  // ── Admin badge neutrals (charte-derived greys / info-blue) ──
  static const Color infoBlue = Color(0xFF1A5FAD); // navy lerped toward blue
  static const Color infoBlueSoft = Color(0xFFD6E8FF); // infoBlue × white 85%
  static const Color peach = Color(0xFFFFD4A8); // primary × white 40%
  static const Color whatsapp =
      Color(0xFF25D366); // third-party brand green (kept for WA affordance)
  static const Color whatsappLight =
      Color(0xFF3EDC81); // whatsapp × white 30% (button gradient highlight)

  // ── Primary halo (wallet card glow) ──
  static const Color primaryHalo =
      Color(0x2EFB7701); // primary @ 18% alpha, over transparent
  static const Color primaryHaloEnd =
      Color(0x00FB7701); // primary @ 0% alpha, radial fade-out

  // ── Warm shadow ink (never pure black) ──
  static const Color shadowInk = Color(0xFF1A2433); // navy as shadow color
}

abstract final class MaamoraDarkColors {
  /// Dark surface tokens. All derived by deepening navy #1A2433 and lifting
  /// cream text tones. Ready for a future dark build (no screen uses them yet).
  static const Color scaffold = Color(0xFF0F1620); // navy deepened
  static const Color surface = Color(0xFF1C2736); // navy + 8% lift
  static const Color surfaceElevated = Color(0xFF243347); // navy + 14% lift
  static const Color surfaceLow = Color(0xFF15202D);
  static const Color border = Color(0xFF2E3D52);
  static const Color borderStrong = Color(0xFF3A4C66);
  static const Color textPrimary = Color(0xFFF5F1EA); // cream-lifted ink
  static const Color textSecondary = Color(0xFFB7B2AB); // warm secondary
  static const Color textFaint = Color(0xFF84807A);
  static const Color primarySoft = Color(0xFF3D2A12); // orange @ dark surface
}

/// Elevation (2 levels only).
abstract final class MaamoraShadows {
  static const List<BoxShadow> soft = [
    BoxShadow(
      color: Color(0x0F1A2433), // navy @ 6%
      blurRadius: 14,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> raised = [
    BoxShadow(
      color: Color(0x1A1A2433), // navy @ 10%
      blurRadius: 24,
      offset: Offset(0, 10),
    ),
  ];

  /// Colored glow used sparingly (hero balance card, pinned leaderboard row).
  static List<BoxShadow> glow(Color color, [double alpha = 0.32]) => [
        BoxShadow(
          color: color.withValues(alpha: alpha),
          blurRadius: 24,
          offset: const Offset(0, 10),
        ),
      ];
}

abstract final class MaamoraRadius {
  static const double card = 18;
  static const double cardSm = 16;
  static const double sheet = 24;
  static const double input = 14;
  static const double chip = 999;
  static BorderRadius get cardR => BorderRadius.circular(card);
  static BorderRadius get cardSmR => BorderRadius.circular(cardSm);
  static BorderRadius get sheetR => BorderRadius.circular(sheet);
  static BorderRadius get inputR => BorderRadius.circular(input);
}

abstract final class MaamoraDurations {
  static const Duration staggerStep = Duration(milliseconds: 90); // 80–120ms
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 450);
  static const Duration countUp = Duration(milliseconds: 1200);
  static const Duration shine = Duration(seconds: 4); // tier badge sweep loop
  static const Duration floatLoop = Duration(milliseconds: 2600);
}

/// ── Gradients ────────────────────────────────────────────────────────────────

abstract final class MaamoraGradients {
  // Hero cards (existing design_kit palette, kept verbatim).
  static const Color heroOrangeTo = Color(0xFFFF9A44); // primary tinted 40%
  static const Color heroNavyFrom = Color(0xFF283656); // navy lifted
  static const List<Color> heroOrange = [heroOrangeTo, MaamoraColors.primary];
  static const List<Color> heroNavy = [heroNavyFrom, MaamoraColors.textPrimary];

  // ── Metallic tiers (Bronze / Silver / Gold / Platinum) ──
  // Each is highlight → mid → depth of one charte tier color.
  static final List<Color> bronze = [
    _lerp(AppColors.tierBronze, 0.55), // ← white 55%
    AppColors.tierBronze, // #CD7F32
    _darken(AppColors.tierBronze, 0.20),
  ];

  static final List<Color> silver = [
    _lerp(AppColors.tierSilver, 0.65),
    AppColors.tierSilver, // #B0B0B8
    _darken(AppColors.tierSilver, 0.22),
  ];

  static final List<Color> gold = [
    _lerp(AppColors.tierGold, 0.60),
    AppColors.tierGold, // #D4AF37
    _darken(AppColors.tierGold, 0.22),
  ];

  static final List<Color> platinum = [
    _lerp(AppColors.tierPlatinum, 0.55),
    AppColors.tierPlatinum, // #7DE3E8
    _darken(AppColors.tierPlatinum, 0.18),
  ];

  // Progress gauge (liquid orange):
  static const List<Color> liquid = [heroOrangeTo, MaamoraColors.primary];

  static Color _lerp(Color base, double towardWhite) =>
      Color.lerp(base, Colors.white, towardWhite)!;

  static Color _darken(Color base, double amount) =>
      Color.lerp(base, Colors.black, amount)!;
}

/// Everything a tier renders with: gradient, glow color, on-color.
class MaamoraTierStyle {
  final List<Color> gradient;
  final Color glow;
  final Color onColor;
  const MaamoraTierStyle(this.gradient, this.glow, this.onColor)
      : assert(gradient.length == 3);

  static final MaamoraTierStyle neutral = MaamoraTierStyle(
    [
      MaamoraColors.navyOnSoft,
      MaamoraColors.textPrimary,
      Color.lerp(MaamoraColors.textPrimary, Colors.black, 0.30)!, // navy deep
    ],
    MaamoraColors.navyOnSoft,
    Color(0xFFF6E9DF),
  );
  static final MaamoraTierStyle bronze =
      MaamoraTierStyle(MaamoraGradients.bronze, AppColors.tierBronze, Colors.white);
  static final MaamoraTierStyle silver =
      MaamoraTierStyle(MaamoraGradients.silver, AppColors.tierSilver, Colors.white);
  static final MaamoraTierStyle gold =
      MaamoraTierStyle(MaamoraGradients.gold, AppColors.tierGold, Colors.white);

  static MaamoraTierStyle ofLevel(int index) {
    // Mirror of AmbassadorLevel without importing models here.
    switch (index) {
      case 1:
        return bronze;
      case 2:
        return silver;
      case 3:
        return gold;
      case 4:
        return MaamoraTierStyle(MaamoraGradients.platinum,
            AppColors.tierPlatinum, MaamoraColors.textPrimary);
      default:
        return neutral;
    }
  }
}

/// Axis / spacing tokens.
abstract final class MaamoraSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double screen = 20; // horizontal screen padding
}
