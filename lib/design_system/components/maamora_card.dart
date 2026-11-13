import 'dart:ui';

import 'package:flutter/material.dart';

import '../maamora_tokens.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// MAAMORA CARD — 2 recipes only (design rule):
///   [MaamoraCard]  white surface, warm hairline, soft shadow → 90% of screens
///   [MaamoraGlassCard] frosted aero-glass for overlays / pinned elements
/// Radius is fixed (18) by the token system; padding is optically centered.
/// ─────────────────────────────────────────────────────────────────────────────

class MaamoraCard extends StatelessWidget {
  const MaamoraCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.shadow = MaamoraShadows.soft,
    this.border = MaamoraColors.border,
    this.color = MaamoraColors.surface,
    this.radius = MaamoraRadius.card,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final List<BoxShadow> shadow;
  final Color border;
  final Color color;
  final double radius;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final body = Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: border),
        boxShadow: shadow,
      ),
      child: child,
    );
    if (onTap == null) return body;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedScale(
        duration: MaamoraDurations.fast,
        scale: 1.0,
        child: body,
      ),
    );
  }
}

/// Frosted aero-glass card — blur + hairline, for overlays & pinned items.
class MaamoraGlassCard extends StatelessWidget {
  const MaamoraGlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = MaamoraRadius.card,
    this.borderColor = MaamoraColors.border,
    this.backgroundColor = MaamoraColors.surface,
    this.backgroundAlpha = 0.72,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color borderColor;
  final Color backgroundColor;
  final double backgroundAlpha;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          width: double.infinity,
          padding: padding,
          decoration: BoxDecoration(
            color: backgroundColor.withValues(alpha: backgroundAlpha),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: borderColor),
            boxShadow: MaamoraShadows.soft,
          ),
          child: child,
        ),
      ),
    );
  }
}
