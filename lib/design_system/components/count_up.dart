import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../maamora_tokens.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// COUNT UP — animated numeric counter (0 → value, easeOutExpo, 1.2s).
/// Rebuilds only on meaningful frame changes (no setState in parents).
/// ─────────────────────────────────────────────────────────────────────────────

class CountUpText extends StatelessWidget {
  const CountUpText({
    super.key,
    required this.value,
    this.begin = 0,
    this.duration = MaamoraDurations.countUp,
    this.style,
    this.prefix,
    this.suffix,
    this.decimals = 0,
    this.animate = true,
    this.curve = Curves.easeOutExpo,
    this.textAlign = TextAlign.start,
    this.maxLines = 1,
    this.overflow = TextOverflow.ellipsis,
  });

  final double value;
  final double begin;
  final Duration duration;
  final TextStyle? style;
  final String? prefix;
  final String? suffix;
  final int decimals;
  final bool animate;
  final Curve curve;
  final TextAlign textAlign;
  final int maxLines;
  final TextOverflow overflow;

  @override
  Widget build(BuildContext context) {
    if (!animate) return _text(value);
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: begin, end: value),
      duration: duration,
      curve: curve,
      builder: (context, v, _) => _text(v),
    );
  }

  Widget _text(double v) {
    final rendered = v.isNaN || v.isInfinite ? 0.0 : v;
    final formatted = formattedValue(rendered);
    final text = '${prefix ?? ''}$formatted${suffix ?? ''}';
    return Text(
      text,
      style: style ?? GoogleFonts.cairo(),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }

  String formattedValue(double v) {
    final clamped = v < 0.0 ? 0.0 : v;
    String body;
    if (decimals == 0) {
      body = clamped.round().toString();
    } else {
      body = clamped.toStringAsFixed(decimals);
    }
    return body;
  }
}

/// Percentage count-up helper: "42 %" with the same easing.
class CountUpPercent extends StatelessWidget {
  const CountUpPercent({
    super.key,
    required this.percent,
    this.style,
    this.duration = MaamoraDurations.countUp,
  });

  /// 0.0 – 1.0
  final double percent;
  final TextStyle? style;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return CountUpText(
      value: (percent.clamp(0.0, 1.0)) * 100,
      decimals: 0,
      suffix: ' %',
      style: style,
      duration: duration,
    );
  }
}

/// Points counter with a tiny trailing "pts" — the hero-metric pattern.
class CountUpPoints extends StatelessWidget {
  const CountUpPoints({
    super.key,
    required this.value,
    required this.style,
    this.label = 'pts',
    this.labelStyle,
    this.duration = MaamoraDurations.countUp,
  });

  final double value;
  final TextStyle style;
  final String label;
  final TextStyle? labelStyle;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        CountUpText(value: value, style: style, duration: duration),
        const SizedBox(width: 6),
        Text(
          label,
          style:
              labelStyle ?? GoogleFonts.cairo(color: MaamoraColors.textSecondary),
        ),
      ],
    );
  }
}
