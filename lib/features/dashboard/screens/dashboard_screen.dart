import 'package:flutter/material.dart';
import 'dart:ui';
import '../../../models/models.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/widgets/tier_badge.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // ⚠️ ajoutez cet import en haut du fichier


class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {

    const Color beigeBackground = Color(0xFFFDF8F0);
    const Color cardBackground = Color(0xFFFAECD6);
    const Color primaryRed = Color(0xFFCC4A33);
    const Color textDark = Color(0xFF222222);

    return Scaffold(
      backgroundColor: beigeBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: textDark),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Ambassador',
          style: TextStyle(
            color: textDark,
            fontWeight: FontWeight.w900,
            fontSize: 22,
            fontStyle: FontStyle.italic,
          ),
        ),
        centerTitle: true,
        actions: [
  IconButton(
    icon: const Icon(Icons.more_horiz, color: textDark),
    onPressed: () async {
      final supabase = Supabase.instance.client;
      try {
        final test = await supabase.from('ambassadors').select();
        print('✅ Supabase connecté, résultat: $test');
      } catch (e) {
        print('❌ Erreur Supabase: $e');
      }
    },
  ),
],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Current Level Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardBackground,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: textDark, width: 1.5),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1A000000),
                    offset: Offset(0, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Current level',
                        style: TextStyle(color: textDark.withValues(alpha: 0.6), fontSize: 12),
                      ),
                      Text(
                        'This week',
                        style: TextStyle(color: textDark.withValues(alpha: 0.6), fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.military_tech, color: AppColors.tierSilver, size: 28),
                          const SizedBox(width: 8),
                          const Text(
                            'Silver · Lvl 4',
                            style: TextStyle(
                              color: textDark,
                              fontWeight: FontWeight.w900,
                              fontSize: 22,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                      const Text(
                        '+ 340 DH',
                        style: TextStyle(
                          color: primaryRed,
                          fontWeight: FontWeight.w900,
                          fontSize: 24,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Progress Bar
                  Container(
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: textDark, width: 1),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 35,
                          child: Container(
                            decoration: BoxDecoration(
                              color: primaryRed,
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                        ),
                        const Expanded(flex: 15, child: SizedBox()),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '35 / 50 buyers to 🏅 Gold',
                        style: TextStyle(color: textDark, fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                      Text(
                        '+ 200 DH bonus',
                        style: TextStyle(color: textDark.withValues(alpha: 0.6), fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Weekly goals Title
            const Text(
              'Weekly goals',
              style: TextStyle(
                color: textDark,
                fontWeight: FontWeight.w900,
                fontSize: 20,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 12),
            
            // Goals List
            _buildGoalCard(
              title: 'Organize 3 group buys',
              reward: '+50 DH',
              progress: 0.6,
              isCompleted: false,
              primaryRed: primaryRed,
              textDark: textDark,
            ),
            const SizedBox(height: 10),
            _buildGoalCard(
              title: 'Bring 5 new buyers',
              reward: '+80 DH',
              progress: 1.0,
              isCompleted: true,
              primaryRed: primaryRed,
              textDark: textDark,
            ),
            const SizedBox(height: 10),
            _buildGoalCard(
              title: 'Run Saturday pickup',
              reward: '+30 DH',
              progress: 0.0,
              isCompleted: false,
              primaryRed: primaryRed,
              textDark: textDark,
            ),
            
            const SizedBox(height: 24),
            
            // Next payout
            CustomPaint(
              painter: DashedBorderPainter(color: textDark),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Next payout — Mon',
                          style: TextStyle(
                            color: textDark,
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'cash · ambassador meetup',
                          style: TextStyle(
                            color: textDark.withValues(alpha: 0.6),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const Text(
                      '340 DH',
                      style: TextStyle(
                        color: primaryRed,
                        fontWeight: FontWeight.w900,
                        fontSize: 24,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // CTA Button
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryRed,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: textDark, width: 1.5),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Invite a neighbor →',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalCard({
    required String title,
    required String reward,
    required double progress,
    required bool isCompleted,
    required Color primaryRed,
    required Color textDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: textDark, width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            offset: Offset(0, 2),
            blurRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              Row(
                children: [
                  Text(
                    reward,
                    style: TextStyle(
                      color: isCompleted ? const Color(0xFF4A90E2) : textDark.withValues(alpha: 0.5),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  if (isCompleted) ...[
                    const SizedBox(width: 4),
                    const Icon(Icons.check, size: 16, color: Color(0xFF4A90E2)),
                  ]
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 10,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(5),
              border: Border.all(color: textDark, width: 1),
            ),
            child: Row(
              children: [
                if (progress > 0)
                  Expanded(
                    flex: (progress * 100).toInt(),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isCompleted ? primaryRed : const Color(0xFFE59866),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                if (progress < 1.0)
                  Expanded(
                    flex: ((1 - progress) * 100).toInt(),
                    child: const SizedBox(),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DashedBorderPainter extends CustomPainter {
  final Color color;

  DashedBorderPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    const double dashWidth = 5;
    const double dashSpace = 4;
    final RRect rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(12),
    );

    Path path = Path()..addRRect(rrect);
    Path dashPath = Path();

    for (PathMetric measurePath in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < measurePath.length) {
        dashPath.addPath(
          measurePath.extractPath(distance, distance + dashWidth),
          Offset.zero,
        );
        distance += dashWidth + dashSpace;
      }
    }
    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
