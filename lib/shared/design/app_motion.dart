import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Motion tokens + the one entry animation used across the app.
abstract final class AppMotion {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration medium = Duration(milliseconds: 350);
  static const Duration slow = Duration(milliseconds: 800);
  static const Duration stagger = Duration(milliseconds: 60);
  static const Curve emphasized = Curves.easeOutCubic;

  /// True when the user asked the OS to reduce motion (accessibility).
  static bool reduced(BuildContext context) =>
      MediaQuery.disableAnimationsOf(context);
}

extension AppEnterX on Widget {
  /// Fade + slide-up entrance, staggered by [index] (capped so long lists do
  /// not wait seconds). Skipped when the user prefers reduced motion.
  ///
  ///   SectionCard(...).enter(context, index: 2)
  Widget enter(BuildContext context, {int index = 0, double dy = 0.06}) {
    if (AppMotion.reduced(context)) return this;
    final step = index < 0 ? 0 : (index > 6 ? 6 : index);
    return animate(delay: AppMotion.stagger * step)
        .fadeIn(duration: AppMotion.medium, curve: AppMotion.emphasized)
        .slideY(
          begin: dy,
          end: 0,
          duration: AppMotion.medium,
          curve: AppMotion.emphasized,
        );
  }
}
