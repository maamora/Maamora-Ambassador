import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../maamora_tokens.dart';
import '../maamora_icons.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// TIER BADGE — metallic look (highlight→mid→depth gradient butted to the
/// charte tier colors), inner sheen, slow shine sweep every 4s, soft glow.
/// ─────────────────────────────────────────────────────────────────────────────
///
/// Usage:
///   TierBadge(level: AmbassadorLevel.silver)          // label + %
///   TierBadge(level: ..., compact: true)              // chip on lists
///   TierBadge(level: ..., showRate: false)            // label only

class TierBadge extends StatefulWidget {
  const TierBadge({
    super.key,
    required this.levelIndex,
    required this.label,
    this.showRate = true,
    this.compact = false,
    this.commissionRate,
    this.size = TierBadgeSize.regular,
    this.animateShine = true,
    this.leadingIcon,
    this.showIcon = true,
  });

  /// Mirror of models' AmbassadorLevel enum: 0 neutral, 1 bronze, 2 silver,
  /// 3 gold, 4+ platinum — used to pick the metallic style without a
  /// models import (keeps the design system reusable).
  final int levelIndex;
  final String label;
  final bool showRate;
  final bool compact;
  final double? commissionRate;
  final TierBadgeSize size;
  final bool animateShine;
  final IconData? leadingIcon;
  final bool showIcon;

  @override
  State<TierBadge> createState() => _TierBadgeState();
}

enum TierBadgeSize { regular, compact, large }

class _TierBadgeState extends State<TierBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shine;

  @override
  void initState() {
    super.initState();
    _shine = AnimationController(
      vsync: this,
      duration: MaamoraDurations.shine,
    );
    if (widget.animateShine) _shine.repeat();
  }

  @override
  void dispose() {
    _shine.dispose();
    super.dispose();
  }

  MaamoraTierStyle get _style => MaamoraTierStyle.ofLevel(widget.levelIndex);

  @override
  Widget build(BuildContext context) {
    final isLarge = widget.size == TierBadgeSize.large;

    // Non-metallic (neutral): flat navy chip, no shine sweep to keep reads calm.
    final iconSize = widget.compact ? 12.0 : (isLarge ? 20.0 : 14.0);
    final fontSize = widget.compact ? 11.0 : (isLarge ? 16.0 : 12.0);
    final horizontal = widget.compact ? 8.0 : (isLarge ? 16.0 : 12.0);
    final vertical = widget.compact ? 4.0 : (isLarge ? 10.0 : 7.0);

    final label = widget.showRate && widget.commissionRate != null
        ? '${widget.label} · ${(widget.commissionRate! * 100).toStringAsFixed(0)}%'
        : widget.label;

    return AnimatedBuilder(
      animation: _shine,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            final t = _shine.value;
            final position = -0.35 + (t * 1.7);
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: const [Colors.transparent, Colors.transparent, Colors.white,
                Colors.transparent, Colors.transparent],
              stops: [
                (position - 0.16).clamp(0.0, 1.0),
                (position - 0.02).clamp(0.0, 1.0),
                position.clamp(0.0, 1.0),
                (position + 0.10).clamp(0.0, 1.0),
                (position + 0.24).clamp(0.0, 1.0),
              ],
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcATop,
          child: child!,
        );
      },
      child: Container(
        padding:
            EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical),
        decoration: BoxDecoration(
          gradient: widget.levelIndex == 0
              ? null
              : LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: _style.gradient,
                ),
          color: widget.levelIndex == 0 ? MaamoraColors.textPrimary : null,
          borderRadius: BorderRadius.circular(999),
          boxShadow: [
            BoxShadow(
              color: _style.glow.withValues(alpha: 0.35),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.showIcon) ...[
              Icon(
                widget.leadingIcon ?? MaamoraIcons.crown,
                color: _style.onColor,
                size: iconSize,
              ),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: GoogleFonts.cairo(
              fontSize: fontSize,
                fontWeight: FontWeight.w800,
                color: _style.onColor,
                shadows: [
                  Shadow(
                    // Inner-edge darkening gives the metallic depth cue.
                    color: Colors.black.withValues(alpha: 0.18),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
