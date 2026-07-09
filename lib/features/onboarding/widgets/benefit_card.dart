import 'package:flutter/material.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_theme.dart';

/// A single benefit tile shown in the "Become an ambassador" intro screen
/// (e.g. "5 DH per buyer", "Bonus payouts", "Verified badge", "Free bundles").
class BenefitCard extends StatelessWidget {
  const BenefitCard({
    super.key,
    required this.icon,
    required this.tagLabel,
    required this.tagColor,
    required this.onTagColor,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String tagLabel;
  final Color tagColor;
  final Color onTagColor;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: AppColors.secondary, size: 36),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: tagColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  tagLabel,
                  style: AppTheme.labelMd.copyWith(
                    color: onTagColor,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(title, style: AppTheme.headlineSm),
          const SizedBox(height: 2),
          Text(subtitle, style: AppTheme.bodySm),
        ],
      ),
    );
  }
}
