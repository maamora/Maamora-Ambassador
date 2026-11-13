import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons_200.dart';
import 'package:lucide_icons_flutter/lucide_icons_500.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// MAAMORA ICONS
///
/// exactly ONE family: Lucide — outline weight 200 at rest (~1.8px optical
/// stroke), weight 500 for emphasized states. Never mix Material pictograms
/// into this mapping.
/// Gamification pictograms that need a filled/glow look (bottom-nav actives,
/// gain bolt) are custom painters — still part of this single family.
/// ─────────────────────────────────────────────────────────────────────────────

/// Base Lucide outline (200) — the app-wide entry point.
abstract final class MaamoraIcons {
  // Navigation & identity
  static const IconData home = LucideIcons200.house;
  static const IconData board = LucideIcons200.trophy;
  static const IconData share = LucideIcons200.share2;
  static const IconData wallet = LucideIcons200.wallet;

  // Share screen
  static const IconData link = LucideIcons200.link;
  static const IconData copy = LucideIcons200.copy;
  static const IconData qrCode = LucideIcons200.qrCode;
  static const IconData paste = LucideIcons200.clipboardPaste;
  static const IconData restart = LucideIcons200.rotateCcw;
  static const IconData send = LucideIcons200.send;
  static const IconData edit = LucideIcons200.pencil;
  static const IconData whatsapp = LucideIcons200.messageCircle;

  // Dashboard
  static const IconData users = LucideIcons200.users;
  static const IconData referral = LucideIcons200.userPlus;
  static const IconData level = LucideIcons200.award;
  static const IconData timer = LucideIcons200.timer;
  static const IconData plus = LucideIcons200.plus;
  static const IconData groupAdd = LucideIcons200.userRoundPlus;

  // Leaderboard
  static const IconData location = LucideIcons200.mapPin;
  static const IconData arrowUp = LucideIcons200.arrowUp;
  static const IconData medal = LucideIcons200.medal;
  static const IconData crown = LucideIcons200.crown;

  // Wallet & earnings
  static const IconData payments = LucideIcons200.banknoteArrowUp;
  static const IconData verifiedUser = LucideIcons200.shieldCheck;
  static const IconData shoppingBag = LucideIcons200.shoppingBag;
  static const IconData payout = LucideIcons200.banknoteArrowDown;
  static const IconData bank = LucideIcons200.landmark;
  static const IconData cash = LucideIcons200.banknote;
  static const IconData receipt = LucideIcons200.receiptText;
  static const IconData chevronRight = LucideIcons200.chevronRight;

  // Rewards / gamification
  static const IconData flame = LucideIcons200.flame;
  static const IconData trophy = LucideIcons200.trophy;
  static const IconData gift = LucideIcons200.ticket;
  static const IconData sparkles = LucideIcons200.sparkles;
  static const IconData check = LucideIcons200.check;

  // Generic
  static const IconData close = LucideIcons200.x;
  static const IconData info = LucideIcons200.info;
  static const IconData settings = LucideIcons200.settings;
  static const IconData language = LucideIcons200.globe;
  static const IconData back = LucideIcons200.chevronLeft;
  static const IconData arrowForward = LucideIcons200.arrowRight;
  static const IconData logout = LucideIcons200.logOut;

  // Emphasized (500) — "filled" emphasis inside chips & buttons.
  static const IconData trophyFilled = LucideIcons500.trophy;
  static const IconData flameFilled = LucideIcons500.flame;
  static const IconData checkFilled = LucideIcons500.check;
  static const IconData boltFilled = LucideIcons500.zap;
}

/// Bolt badge with glow — the "You gained points" pictogram.
class MaamoraBolt extends StatelessWidget {
  const MaamoraBolt({super.key, this.color, this.size = 22});
  final Color? color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _BoltPainter(color: color ?? const Color(0xFFFB7701)),
    );
  }
}

class _BoltPainter extends CustomPainter {
  _BoltPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final path = Path()
      ..moveTo(w * 0.58, h * 0.04)
      ..lineTo(w * 0.20, h * 0.56)
      ..lineTo(w * 0.44, h * 0.56)
      ..lineTo(w * 0.40, h * 0.96)
      ..lineTo(w * 0.80, h * 0.44)
      ..lineTo(w * 0.54, h * 0.44)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _BoltPainter old) => old.color != color;
}

/// ── Filled bottom-nav actives ────────────────────────────────────────────────
///
/// Solid-fill companions of the four nav tabs. The inactive state renders the
/// Lucide 200 outline (see [MaamoraIcons]); the active tab crossfades into one
/// of these filled glyphs with a spring scale (see bottom_nav_bar.dart).

enum MaamoraFilledGlyph { house, trophy, share, wallet }

class MaamoraFilledIcon extends StatelessWidget {
  const MaamoraFilledIcon({
    super.key,
    required this.glyph,
    required this.color,
    this.size = 24,
  });

  final MaamoraFilledGlyph glyph;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: switch (glyph) {
          MaamoraFilledGlyph.house => _HouseFilledPainter(color: color),
          MaamoraFilledGlyph.trophy => _TrophyFilledPainter(color: color),
          MaamoraFilledGlyph.share => _ShareFilledPainter(color: color),
          MaamoraFilledGlyph.wallet => _WalletFilledPainter(color: color),
        },
      ),
    );
  }
}

class _HouseFilledPainter extends CustomPainter {
  _HouseFilledPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final path = Path()
      ..moveTo(w * 0.06, h * 0.44)
      ..quadraticBezierTo(w * 0.06, h * 0.38, w * 0.11, h * 0.33)
      ..lineTo(w * 0.42, h * 0.09)
      ..quadraticBezierTo(w * 0.5, h * 0.02, w * 0.58, h * 0.09)
      ..lineTo(w * 0.89, h * 0.33)
      ..quadraticBezierTo(w * 0.94, h * 0.38, w * 0.94, h * 0.44)
      ..lineTo(w * 0.94, h * 0.82)
      ..quadraticBezierTo(w * 0.94, h * 0.94, w * 0.82, h * 0.94)
      ..lineTo(w * 0.63, h * 0.94)
      ..lineTo(w * 0.63, h * 0.72)
      ..quadraticBezierTo(w * 0.5, h * 0.62, w * 0.37, h * 0.72)
      ..lineTo(w * 0.37, h * 0.94)
      ..lineTo(w * 0.18, h * 0.94)
      ..quadraticBezierTo(w * 0.06, h * 0.94, w * 0.06, h * 0.82)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _HouseFilledPainter old) => old.color != color;
}

class _TrophyFilledPainter extends CustomPainter {
  _TrophyFilledPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final paint = Paint()..color = color;
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.height * 0.07
      ..strokeCap = StrokeCap.round;

    // Side handles
    canvas.drawCircle(Offset(w * 0.13, h * 0.30), w * 0.10, stroke);
    canvas.drawCircle(Offset(w * 0.87, h * 0.30), w * 0.10, stroke);

    // Cup body
    final cup = Path()
      ..moveTo(w * 0.22, h * 0.10)
      ..lineTo(w * 0.78, h * 0.10)
      ..cubicTo(w * 0.78, h * 0.52, w * 0.66, h * 0.62, w * 0.5, h * 0.62)
      ..cubicTo(w * 0.34, h * 0.62, w * 0.22, h * 0.52, w * 0.22, h * 0.10)
      ..close();
    canvas.drawPath(cup, paint);

    // Stem
    canvas.drawRRect(
      RRect.fromLTRBAndCorners(
        w * 0.46,
        h * 0.62,
        w * 0.54,
        h * 0.80,
        bottomRight: const Radius.circular(2),
        bottomLeft: const Radius.circular(2),
        topLeft: const Radius.circular(2),
        topRight: const Radius.circular(2),
      ),
      paint,
    );

    // Base
    canvas.drawRRect(
      RRect.fromLTRBAndCorners(
        w * 0.30,
        h * 0.84,
        w * 0.70,
        h * 0.92,
        topLeft: const Radius.circular(2),
        topRight: const Radius.circular(2),
        bottomLeft: const Radius.circular(2),
        bottomRight: const Radius.circular(2),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _TrophyFilledPainter old) => old.color != color;
}

class _ShareFilledPainter extends CustomPainter {
  _ShareFilledPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final path = Path()
      ..moveTo(w * 0.96, h * 0.04)
      ..lineTo(w * 0.72, h * 0.94)
      ..lineTo(w * 0.52, h * 0.68)
      ..lineTo(w * 0.30, h * 0.78)
      ..lineTo(w * 0.30, h * 0.62)
      ..lineTo(w * 0.66, h * 0.30)
      ..lineTo(w * 0.38, h * 0.56)
      ..lineTo(w * 0.90, h * 0.90)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _ShareFilledPainter old) => old.color != color;
}

class _WalletFilledPainter extends CustomPainter {
  _WalletFilledPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final paint = Paint()..color = color;
    final r = const Radius.circular(4);

    // Body
    canvas.drawRRect(
      RRect.fromLTRBAndCorners(
        w * 0.04,
        h * 0.18,
        w * 0.92,
        h * 0.84,
        topLeft: r,
        topRight: r,
        bottomLeft: r,
        bottomRight: r,
      ),
      paint,
    );
    // Flap
    canvas.drawRRect(
      RRect.fromLTRBAndCorners(
        w * 0.72,
        h * 0.40,
        w * 0.96,
        h * 0.62,
        topRight: r,
        bottomRight: r,
      ),
      paint,
    );
    // Punch dot
    canvas.drawCircle(
      Offset(w * 0.82, h * 0.51),
      w * 0.045,
      Paint()..color = const Color(0xFFFFFFFF),
    );
  }

  @override
  bool shouldRepaint(covariant _WalletFilledPainter old) => old.color != color;
}
