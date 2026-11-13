import 'package:flutter/material.dart';

import '../design/app_tokens.dart';
import '../theme/app_colors.dart';

/// Rounded square with a tinted background and a centered icon.
class IconTile extends StatelessWidget {
  const IconTile({
    super.key,
    required this.icon,
    this.size = 48,
    this.color = AppColors.primaryText,
    this.tint,
  });

  final IconData icon;
  final double size;
  final Color color;
  final Color? tint;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: tint ?? AppColors.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Icon(icon, size: size * 0.5, color: color),
    );
  }
}
