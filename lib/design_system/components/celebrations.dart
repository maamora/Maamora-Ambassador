import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// CELEBRATIONS
///   [MaamoraParticles]    floating soft particles behind hero cards (loop)
///   [MaamoraConfetti]     one-shot confetti burst (points earned, tier up)
///   showConfettiBurst()   overlay helper — call once, it cleans up itself
/// ─────────────────────────────────────────────────────────────────────────────

/// Palette = charte only (orange, navy, gold tier).
const List<Color> _kConfettiColors = [
  Color(0xFFFB7701),
  Color(0xFF1A2433),
  Color(0xFFD4AF37),
  Color(0xFFCD7F32),
  Color(0xFFFFD9BF), // primary tint
];

class MaamoraParticles extends StatefulWidget {
  const MaamoraParticles({
    super.key,
    this.count = 8,
    this.color = Colors.white,
    this.maxRadius = 2.2,
    this.maxOpacity = 0.35,
  });

  final int count;
  final Color color;
  final double maxRadius;
  final double maxOpacity;

  @override
  State<MaamoraParticles> createState() => _MaamoraParticlesState();
}

class _MaamoraParticlesState extends State<MaamoraParticles>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 5),
  )..repeat();
  late final List<_Mote> _motes;

  @override
  void initState() {
    super.initState();
    final rnd = Random(7);
    _motes = List.generate(widget.count, (i) {
      return _Mote(
        seedX: rnd.nextDouble(),
        seedY: rnd.nextDouble(),
        radius: 0.8 + rnd.nextDouble() * (widget.maxRadius - 0.8),
        speed: 0.4 + rnd.nextDouble() * 0.8,
        phase: rnd.nextDouble() * 2 * pi,
      );
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) {
          return CustomPaint(
            painter: _MotesPainter(
              motes: _motes,
              t: _c.value,
              color: widget.color,
              maxOpacity: widget.maxOpacity,
            ),
            size: Size.infinite,
          );
        },
      ),
    );
  }
}

class _Mote {
  final double seedX;
  final double seedY;
  final double radius;
  final double speed;
  final double phase;
  const _Mote({
    required this.seedX,
    required this.seedY,
    required this.radius,
    required this.speed,
    required this.phase,
  });
}

class _MotesPainter extends CustomPainter {
  _MotesPainter({
    required this.motes,
    required this.t,
    required this.color,
    required this.maxOpacity,
  });

  final List<_Mote> motes;
  final double t;
  final Color color;
  final double maxOpacity;

  @override
  void paint(Canvas canvas, Size size) {
    for (final m in motes) {
      // Drift upward with a gentle sine sway — transform-only, cheap.
      final tt = (t * m.speed + m.phase / (2 * pi)) % 1.0;
      final x = size.width * (m.seedX + 0.04 * sin(tt * 2 * pi));
      final y = size.height * (1.05 - tt * 1.1 + m.seedY * 0.05);
      final opacity = maxOpacity * sin(tt * pi);
      if (opacity <= 0) continue;
      canvas.drawCircle(
        Offset(x, y),
        m.radius,
        Paint()..color = color.withValues(alpha: opacity),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _MotesPainter old) => old.t != t;
}

/// One-shot burst, wrapped once around a screen and triggered by controller.
class MaamoraConfetti extends StatefulWidget {
  const MaamoraConfetti({
    super.key,
    this.autoPlay = true,
    this.blastDirectionality = BlastDirectionality.explosive,
    this.controller,
  });

  final bool autoPlay;
  final BlastDirectionality blastDirectionality;

  /// When provided, [fire] is not called automatically; caller drives it.
  final ConfettiController? controller;

  @override
  State<MaamoraConfetti> createState() => _MaamoraConfettiState();
}

class _MaamoraConfettiState extends State<MaamoraConfetti> {
  late final ConfettiController _c =
      widget.controller ??
      (ConfettiController(duration: const Duration(seconds: 2)));

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _c.play();
    }
  }

  @override
  void dispose() {
    // Only dispose a controller we created ourselves.
    if (widget.controller == null) _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConfettiWidget(
        confettiController: _c,
        blastDirectionality: widget.blastDirectionality,
        shouldLoop: false,
        numberOfParticles: 90,
        maxBlastForce: 26,
        minBlastForce: 8,
        gravity: 0.28,
        emissionFrequency: 0.02,
        colors: _kConfettiColors,
      ),
    );
  }
}

/// Standalone top-center burst overlaid on whatever is showing now.
void showConfettiBurst(BuildContext context) {
  final overlay = Overlay.maybeOf(context, rootOverlay: true);
  if (overlay == null) return;
  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (context) {
      // Removes itself when the confetti animation naturally ends.
      return Positioned.fill(child: IgnorePointer(child: _OverlayConfetti(onDone: () {
        if (entry.mounted) entry.remove();
      })));
    },
  );
  overlay.insert(entry);
}

class _OverlayConfetti extends StatefulWidget {
  const _OverlayConfetti({required this.onDone});
  final VoidCallback onDone;

  @override
  State<_OverlayConfetti> createState() => _OverlayConfettiState();
}

class _OverlayConfettiState extends State<_OverlayConfetti> {
  late final ConfettiController _c =
      ConfettiController(duration: const Duration(seconds: 2))..play();

  @override
  void initState() {
    super.initState();
    // Cleanup window: hard cap so the entry stays alive exactly long enough
    // for the burst to finish falling, then remove the overlay.
    Future<void>.delayed(const Duration(milliseconds: 3600), widget.onDone);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConfettiWidget(
        confettiController: _c,
        blastDirectionality: BlastDirectionality.explosive,
        numberOfParticles: 80,
        gravity: 0.26,
        colors: _kConfettiColors,
      ),
    );
  }
}
