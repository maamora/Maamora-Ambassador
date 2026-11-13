import 'package:flutter/material.dart';

/// Design tokens. One place to tune spacing, radii, icon sizes and shadows so
/// every screen stays consistent. Colors live in `AppColors` (brand palette).

/// 4-pt spacing scale.
abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
}

abstract final class AppRadius {
  static const double sm = 10;
  static const double md = 14;
  static const double lg = 18;
  static const double xl = 24;

  static BorderRadius get card => BorderRadius.circular(lg);
}

abstract final class AppIconSize {
  static const double sm = 16;
  static const double md = 20;
  static const double lg = 24;
}

abstract final class AppShadows {
  static List<BoxShadow> get soft => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 14,
          offset: const Offset(0, 4),
        ),
      ];
}

extension ThemeTextX on BuildContext {
  /// Shortcut for `Theme.of(context).textTheme` (Cairo, set in AppTheme).
  TextTheme get text => Theme.of(this).textTheme;
}
