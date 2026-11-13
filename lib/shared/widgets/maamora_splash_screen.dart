import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../design_system/design_system.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// SPLASH — animated logo with a slowly breathing gradient + brand-shine.
/// Presentation only: after the animation it routes to `/login` (the app
/// router itself redirects signed-in users, so no auth logic is touched).
/// ─────────────────────────────────────────────────────────────────────────────

class MaamoraSplashScreen extends StatefulWidget {
  const MaamoraSplashScreen({super.key});

  @override
  State<MaamoraSplashScreen> createState() => _MaamoraSplashScreenState();
}

class _MaamoraSplashScreenState extends State<MaamoraSplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
  )..forward();

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 1600), () {
      if (mounted) context.go('/login');
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MaamoraColors.scaffold,
      body: Center(
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, child) {
            final breathe =
                CurvedAnimation(parent: _c, curve: Curves.easeOut).value;
            final slowPulse = 1.0 + 0.04 * (1 - breathe);
            return Transform.scale(
              scale: slowPulse,
              child: child,
            );
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Logo in a breathing orange-glow disc.
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.7, end: 1.0),
                duration: const Duration(milliseconds: 900),
                curve: Curves.easeOutBack,
                builder: (context, t, child) {
                  return Opacity(
                    opacity: t.clamp(0.0, 1.0),
                    child: Transform.scale(scale: t, child: child),
                  );
                },
                child: Container(
                  width: 148,
                  height: 148,
                  decoration: BoxDecoration(
                    color: MaamoraColors.surface,
                    shape: BoxShape.circle,
                    boxShadow: MaamoraShadows.glow(MaamoraColors.primary,
                        0.35),
                  ),
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(28),
                  child: Image.asset(
                    'assets/images/maamora_logo.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 22),
              Text(
                'Maamora',
                style: GoogleFonts.cairo(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: MaamoraColors.primary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'ambassador · app privée',
                style: MaamoraTheme.support(),
              ),
              const SizedBox(height: 36),
              SizedBox(
                width: 120,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: _c.value,
                    minHeight: 3,
                    backgroundColor: MaamoraColors.surfaceLow,
                    valueColor: const AlwaysStoppedAnimation(
                        MaamoraColors.primary),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
