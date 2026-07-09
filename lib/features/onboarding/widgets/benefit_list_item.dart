import 'package:flutter/material.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_theme.dart';

/// A single benefit row as shown in the wireframe: icon on the left,
/// bold title + gray subtitle stacked on the right. No card background,
/// no border, no tag pill — unlike BenefitCard, which is the boxed
/// variant from the original HTML mockup. Use this one to match the
/// flat-list wireframe.
class BenefitListItem extends StatelessWidget {
  const BenefitListItem({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: iconColor, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTheme.headlineSm.copyWith(fontSize: 17)),
              const SizedBox(height: 2),
              Text(subtitle, style: AppTheme.bodySm),
            ],
          ),
        ),
      ],
    );
  }
}
