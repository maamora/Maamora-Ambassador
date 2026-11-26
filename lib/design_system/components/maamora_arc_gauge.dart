import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../maamora_tokens.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// ARC GAUGE — the Maamora logo arc used as the app's progress meter.
///
/// Same geometry as the brand mark (a thick band spanning 108° around the
/// top), so "filling up" — a group gaining members, an ambassador moving to
/// the next level — is told with the brand's own shape.
///
/// • Fills from the reading-start side (left in French, right in Arabic).
/// • Animates from 0 to [value] once (900ms); instant with reduced motion.
/// • Optional [center] widget sits in the bowl under the arc.
/// ─────────────────────────────────────────────────────────────────────────────
class MaamoraArcGauge extends StatelessWidget {
  const MaamoraArcGauge({
    super.key,
    required this.value,
    this.width = 160,
    this.onDark = false,
    this.color,
    this.center,
    this.semanticLabel,
  });

  /// Progress, 0.0 – 1.0 (clamped).
  final double value;
  final double width;

  /// Track colour adapted to a navy background.
  final bool onDark;

  /// Solid fill instead of the brand gradient (e.g. success when complete).
  final Color? color;
  final Widget? center;
  final String? semanticLabel;

  /// Height of the arc band itself for a given width.
  static double arcHeightFor(double width) => width * 0.36;

  @override
  Widget build(BuildContext context) {
    final v = value.isNaN ? 0.0 : value.clamp(0.0, 1.0);
    final reduced = MaamoraMotion.reduced(context);
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final arcH = arcHeightFor(width);

    return Semantics(
      label: semanticLabel,
      value: '${(v * 100).round()} %',
      child: SizedBox(
        width: width,
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            ExcludeSemantics(
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: reduced ? v : 0, end: v),
                duration:
                    reduced ? Duration.zero : const Duration(milliseconds: 900),
                curve: MaamoraMotion.standard,
                builder: (context, t, _) => CustomPaint(
                  size: Size(width, arcH),
                  painter: _ArcPainter(
                    progress: t,
                    rtl: rtl,
                    onDark: onDark,
                    solid: color,
                  ),
                ),
              ),
            ),
            if (center != null)
              Padding(
                padding: EdgeInsets.only(top: arcH * 0.55),
                child: center,
              ),
          ],
        ),
      ),
    );
  }
}

class _ArcPainter extends CustomPainter {
  _ArcPainter({
    required this.progress,
    required this.rtl,
    required this.onDark,
    this.solid,
  });

  final double progress;
  final bool rtl;
  final bool onDark;
  final Color? solid;

  // Brand geometry: 108° band, thickness 23.5% of the outer radius.
  static const double _span = 108 * math.pi / 180;
  static const double _thicknessRatio = 0.235;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final outerR = (w / 2) / math.sin(_span / 2);
    final stroke = outerR * _thicknessRatio;
    final r = outerR - stroke / 2; // stroke is centred on the path
    final center = Offset(w / 2, stroke / 2 + r);
    final rect = Rect.fromCircle(center: center, radius: r);
    final start = -math.pi / 2 - _span / 2;

    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.butt
      ..color = onDark
          ? MaamoraColors.onPrimary.withValues(alpha: 0.14)
          : MaamoraColors.textPrimary.withValues(alpha: 0.08);
    canvas.drawArc(rect, start, _span, false, track);

    if (progress <= 0) return;
    final sweep = _span * progress;
    final fill = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.butt;
    if (solid != null) {
      fill.color = solid!;
    } else {
      fill.shader = LinearGradient(
        colors: rtl
            ? const [MaamoraColors.primary, MaamoraGradients.heroOrangeTo]
            : const [MaamoraGradients.heroOrangeTo, MaamoraColors.primary],
      ).createShader(Rect.fromLTWH(0, 0, w, size.height));
    }
    if (rtl) {
      // Reading start is on the right: fill from the right end leftwards.
      canvas.drawArc(rect, start + _span - sweep, sweep, false, fill);
    } else {
      canvas.drawArc(rect, start, sweep, false, fill);
    }
  }

  @override
  bool shouldRepaint(covariant _ArcPainter old) =>
      old.progress != progress ||
      old.rtl != rtl ||
      old.onDark != onDark ||
      old.solid != solid;
}
