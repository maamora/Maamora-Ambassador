import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../theme/app_colors.dart';

Color tierColor(Tier tier) {
  switch (tier) {
    case Tier.bronze:
      return AppColors.tierBronze;
    case Tier.silver:
      return AppColors.tierSilver;
    case Tier.gold:
      return AppColors.tierGold;
    case Tier.platinum:
      return AppColors.tierPlatinum;
  }
}

/// Widget partagé — utilisé par le dashboard (Dev 3) ET le leaderboard
/// (Dev 4). Ne créez pas votre propre version dans votre feature,
/// modifiez celle-ci si besoin (et prévenez l'autre dev concerné).
class TierBadge extends StatelessWidget {
  final Tier tier;
  final bool large;
  const TierBadge({super.key, required this.tier, this.large = false});

  @override
  Widget build(BuildContext context) {
    final color = tierColor(tier);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: large ? 14 : 10,
        vertical: large ? 8 : 5,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.military_tech, color: color, size: large ? 20 : 14),
          const SizedBox(width: 4),
          Text(
            tier.label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: large ? 14 : 11,
            ),
          ),
        ],
      ),
    );
  }
}
