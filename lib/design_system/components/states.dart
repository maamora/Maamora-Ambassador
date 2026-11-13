import 'package:flutter/material.dart';

import '../maamora_icons.dart';
import '../maamora_tokens.dart';
import 'maamora_button.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// STATES — empty & error presentations. Loading skeletons live in
/// skeletons.dart. Every list/screen must render through these.
/// ─────────────────────────────────────────────────────────────────────────────

class MaamoraEmptyState extends StatelessWidget {
  const MaamoraEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 22),
      decoration: BoxDecoration(
        color: MaamoraColors.surface,
        borderRadius: BorderRadius.circular(MaamoraRadius.card),
        border: Border.all(color: MaamoraColors.border),
      ),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: MaamoraColors.primarySoft,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, color: MaamoraColors.primary, size: 28),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: MaamoraColors.textPrimary,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 6),
            Text(
              subtitle!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                color: MaamoraColors.textSecondary,
                height: 1.5,
              ),
            ),
          ],
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 18),
            FractionallySizedBox(
              widthFactor: 0.7,
              child: MaamoraButton(
                label: actionLabel!,
                onPressed: onAction,
                expanded: false,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class MaamoraErrorState extends StatelessWidget {
  const MaamoraErrorState({
    super.key,
    this.title = 'Une erreur est survenue',
    this.subtitle,
    this.onRetry,
  });

  final String title;
  final String? subtitle;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 22),
      decoration: BoxDecoration(
        color: MaamoraColors.surface,
        borderRadius: BorderRadius.circular(MaamoraRadius.card),
        border: Border.all(color: MaamoraColors.dangerSoft),
      ),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: MaamoraColors.dangerSoft,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(MaamoraIcons.info,
                color: MaamoraColors.danger, size: 28),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: MaamoraColors.textPrimary,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 6),
            Text(
              subtitle!,
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                color: MaamoraColors.textSecondary,
                height: 1.5,
              ),
            ),
          ],
          if (onRetry != null) ...[
            const SizedBox(height: 18),
            FractionallySizedBox(
              widthFactor: 0.7,
              child: MaamoraButton(
                label: 'Réessayer',
                leadingIcon: MaamoraIcons.restart,
                onPressed: onRetry,
                expanded: false,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
