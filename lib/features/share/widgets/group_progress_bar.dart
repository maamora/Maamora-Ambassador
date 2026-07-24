import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../models/models.dart';

class GroupProgressBar extends StatelessWidget {
  final ProductGroup group;

  const GroupProgressBar({
    super.key,
    required this.group,
  });

  @override
  Widget build(BuildContext context) {
    final progress = group.progressRatio;
    final isUnlocked = group.isUnlocked;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  isUnlocked ? Icons.check_circle : Icons.groups_outlined,
                  size: 16,
                  color: isUnlocked ? const Color(0xFF2E7D32) : const Color(0xFFFB7701),
                ),
                const SizedBox(width: 6),
                Text(
                  isUnlocked ? 'Groupe Débloqué !' : 'Achat Groupé',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isUnlocked ? const Color(0xFF2E7D32) : const Color(0xFF251912),
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: isUnlocked
                    ? const Color(0xFFE8F5E9)
                    : const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${group.compteurActuel}/${group.seuilMin} participants',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isUnlocked ? const Color(0xFF2E7D32) : const Color(0xFFE65100),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Stack(
          children: [
            Container(
              height: 10,
              decoration: BoxDecoration(
                color: const Color(0xFFF4EDE4),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            AnimatedFractionallySizedBox(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOutCubic,
              widthFactor: progress,
              child: Container(
                height: 10,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isUnlocked
                        ? [const Color(0xFF4CAF50), const Color(0xFF2E7D32)]
                        : [const Color(0xFFFF9800), const Color(0xFFFB7701)],
                  ),
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: [
                    BoxShadow(
                      color: (isUnlocked ? const Color(0xFF4CAF50) : const Color(0xFFFB7701))
                          .withValues(alpha: 0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
