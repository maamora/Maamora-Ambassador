import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../core/l10n/app_strings.dart';
import '../maamora_tokens.dart';
import '../maamora_icons.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// TIER CELEBRATION — the one cinematic moment of the app.
/// Full-screen overlay: confetti + big tier medal + "Bienvenue au niveau
/// SILVER" revealed letter by letter, auto-dismiss after ~3.4s.
///   TierCelebration.show(context, tierIndex: 2, tierName: 'Silver');
///
/// Watching the ambassador level and firing automatically is done by
/// `TierCelebrationWatcher` (see shared/widgets) — presentation only, zero
/// business logic touched.
/// ─────────────────────────────────────────────────────────────────────────────

class TierCelebration {
  TierCelebration._();

  static Future<void> show(
    BuildContext context, {
    required int tierIndex,
    required String tierName,
    String? subtitle,
  }) {
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return Future.value();

    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => _TierCelebrationView(
        tierIndex: tierIndex,
        tierName: tierName,
        subtitle: subtitle,
        onDone: () {
          if (entry.mounted) entry.remove();
        },
      ),
    );
    overlay.insert(entry);
    return Future<void>.delayed(const Duration(milliseconds: 4200));
  }
}

class _TierCelebrationView extends StatefulWidget {
  const _TierCelebrationView({
    required this.tierIndex,
    required this.tierName,
    this.subtitle,
    required this.onDone,
  });

  final int tierIndex;
  final String tierName;
  final String? subtitle;
  final VoidCallback onDone;

  @override
  State<_TierCelebrationView> createState() => _TierCelebrationViewState();
}

class _TierCelebrationViewState extends State<_TierCelebrationView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 3600), () {
      if (mounted) widget.onDone();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_c.status == AnimationStatus.dismissed) {
      if (MaamoraMotion.reduced(context)) {
        _c.value = 1;
      } else {
        _c.forward();
      }
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final subtitle = widget.subtitle ?? context.tr('celebration_welcome_level');
    // Tap anywhere closes it early; readers hear one sentence.
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onDone,
      child: Semantics(
        liveRegion: true,
        label: '$subtitle ${widget.tierName}',
        excludeSemantics: true,
        child: _buildScene(subtitle),
      ),
    );
  }

  Widget _buildScene(String subtitle) {
    return Material(
      color: Colors.black.withValues(alpha: 0.72),
      child: Container(
        color: MaamoraColors.scaffold.withValues(alpha: 0.92),
        child: Stack(
          children: [
            // Amber glow center
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [Color(0x33FB7701), Color(0x00FB7701)],
                    radius: 0.9,
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Metallic medallion with crown
                    ScaleTransition(
                      scale: CurvedAnimation(
                        parent: _c,
                        curve: const Interval(
                          0,
                          0.55,
                          curve: Curves.easeOutBack,
                        ),
                      ),
                      child: _TierMedallion(
                        tierIndex: widget.tierIndex,
                        size: 132,
                      ),
                    ),
                    const SizedBox(height: 28),
                    // "Bienvenue au niveau" then the tier name, letter stagger.
                    _StaggerLetters(
                      text: widget.tierName.toUpperCase(),
                      controller: _c,
                      interval: const Interval(0.45, 1.0),
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 3,
                        color: MaamoraColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    FadeTransition(
                      opacity: _c,
                      child: Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: MaamoraColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Circular medal with circular metallic gradient & shine sweep.
class _TierMedallion extends StatelessWidget {
  const _TierMedallion({required this.tierIndex, required this.size});
  final int tierIndex;
  final double size;

  @override
  Widget build(BuildContext context) {
    final style = MaamoraTierStyle.ofLevel(tierIndex);
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutBack,
      builder: (context, t, child) {
        return Opacity(
          opacity: t.clamp(0, 1),
          child: Transform.scale(scale: 0.7 + 0.3 * t, child: child),
        );
      },
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: style.gradient,
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: style.glow.withValues(alpha: 0.55),
              blurRadius: 44,
              spreadRadius: 6,
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.22),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: ShaderMask(
                shaderCallback: (bounds) {
                  return const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFFFFFFF), Color(0xFFFFFFFF)],
                  ).createShader(bounds);
                },
                blendMode: BlendMode.srcATop,
                child: Icon(
                  MaamoraIcons.trophyFilled,
                  size: size * 0.36,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Reveal the tier name letter-by-letter (opacity + slight rise per glyph).
/// Arabic letters change shape when joined; splitting them per glyph would
/// render them detached. Detects the Arabic blocks (U+0600–06FF, U+0750–077F,
/// U+FB50–FDFF, U+FE70–FEFF).
bool _isConnectedScript(String text) => text.runes.any(
  (r) =>
      (r >= 0x0600 && r <= 0x06FF) ||
      (r >= 0x0750 && r <= 0x077F) ||
      (r >= 0xFB50 && r <= 0xFDFF) ||
      (r >= 0xFE70 && r <= 0xFEFF),
);

class _StaggerLetters extends StatelessWidget {
  const _StaggerLetters({
    required this.text,
    required this.controller,
    required this.interval,
    required this.style,
  });

  final String text;
  final AnimationController controller;
  final Interval interval;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    final t = CurvedAnimation(parent: controller, curve: interval);
    if (_isConnectedScript(text)) {
      return FadeTransition(
        opacity: t,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.2),
            end: Offset.zero,
          ).animate(t),
          child: Text(text, style: style, textAlign: TextAlign.center),
        ),
      );
    }
    final glyphs = text.runes.toList();
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (var i = 0; i < glyphs.length; i++)
          AnimatedBuilder(
            animation: t,
            builder: (context, _) {
              final start = i / glyphs.length;
              final end = (i + 1.6) / glyphs.length;
              final lt = CurvedAnimation(
                parent: t,
                curve: Interval(
                  start.clamp(0.0, 1.0),
                  end.clamp(0.0, 1.0),
                  curve: Curves.easeOutCubic,
                ),
              ).value;
              return Opacity(
                opacity: lt.clamp(0.0, 1.0),
                child: Transform.translate(
                  offset: Offset(0, 10 * (1 - lt)),
                  child: Text(String.fromCharCode(glyphs[i]), style: style),
                ),
              );
            },
          ),
      ],
    );
  }
}

/// ── Lottie premium layer ─────────────────────────────────────────────────────
///
/// If `assets/animations/celebration.json` (or any premium asset) is added
/// later, wrapping a painter fallback here keeps shipping safe: when the
/// asset is absent, the errorBuilder renders the fallback widget instead.
class MaamoraLottie extends StatelessWidget {
  const MaamoraLottie({
    super.key,
    required this.asset,
    required this.fallback,
    this.width,
    this.height,
    this.repeat = true,
  });

  final String asset;
  final Widget fallback;
  final double? width;
  final double? height;
  final bool repeat;

  @override
  Widget build(BuildContext context) {
    return LottieBuilder.asset(
      asset,
      width: width,
      height: height,
      repeat: repeat,
      errorBuilder: (context, error, stackTrace) => fallback,
    );
  }
}
