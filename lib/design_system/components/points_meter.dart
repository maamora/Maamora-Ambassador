import 'package:flutter/material.dart';

import '../maamora_tokens.dart';
import 'count_up.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// POINTS METER — liquid gauge: gradient fill + slow inner shimmer + CountUp
/// percentage. Runs on transform/opacity only; safe in long lists.
/// ─────────────────────────────────────────────────────────────────────────────

class PointsMeter extends StatelessWidget {
  const PointsMeter({
    super.key,
    required this.value,
    this.height = 10,
    this.trackColor,
    this.trackRadius,
    this.showPercent = true,
    this.percentStyle,
  }) : assert(value >= 0 && value <= 1.001);

  /// 0.0 – 1.0
  final double value;
  final double height;
  final Color? trackColor;
  final BorderRadius? trackRadius;
  final bool showPercent;
  final TextStyle? percentStyle;

  @override
  Widget build(BuildContext context) {
    final clamped = value.clamp(0.0, 1.0);
    final trackColor = this.trackColor ?? MaamoraColors.surfaceLow;

    final meter = TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: clamped),
      duration: MaamoraDurations.countUp,
      curve: Curves.easeOutExpo,
      builder: (context, v, _) => _LiquidBar(
        value: v,
        height: height,
        trackColor: trackColor,
        trackRadius:
            trackRadius ?? BorderRadius.circular(height / 2),
      ),
    );

    if (!showPercent) return meter;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        meter,
        const SizedBox(height: 4),
        CountUpPercent(
          percent: clamped,
          style: percentStyle ??
              const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: MaamoraColors.primary,
              ),
        ),
      ],
    );
  }
}

class _LiquidBar extends StatelessWidget {
  const _LiquidBar({
    required this.value,
    required this.height,
    required this.trackColor,
    required this.trackRadius,
  });

  final double value;
  final double height;
  final Color trackColor;
  final BorderRadius trackRadius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: trackRadius,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxWidth = constraints.maxWidth;
          final fillWidth = (maxWidth * value).clamp(0.0, maxWidth);

          return Stack(
            children: [
              // Track
              Container(
                height: height,
                width: double.infinity,
                color: trackColor,
              ),
              // Fill: gradient + travelling highlight blob (opacity only).
              if (fillWidth > 2)
                SizedBox(
                  height: height,
                  width: fillWidth,
                  child: ClipRRect(
                    borderRadius: trackRadius,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: MaamoraGradients.liquid,
                              ),
                            ),
                          ),
                        ),
                        // Shimmer: a soft white band drifting across the fill.
                        const Positioned.fill(
                          child: _DriftBand(),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _DriftBand extends StatefulWidget {
  const _DriftBand();

  @override
  State<_DriftBand> createState() => _DriftBandState();
}

class _DriftBandState extends State<_DriftBand>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        // Slide an off-screen band across in -1.2 → 1.2 range (transform only).
        final t = _c.value;
        return FractionalTranslation(
          translation: Offset(-1.4 + t * 3.0, 0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width: 60,
              color: Colors.white.withValues(alpha: 0.28),
            ),
          ),
        );
      },
    );
  }
}
