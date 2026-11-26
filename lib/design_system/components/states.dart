import 'package:flutter/material.dart';

import '../../core/l10n/app_strings.dart';
import '../maamora_icons.dart';
import '../maamora_tokens.dart';
import 'maamora_button.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// STATES — empty & error presentations. Loading skeletons live in
/// skeletons.dart. Every list/screen must render through these.
///
/// Texts default to the i18n keys `common_error_title` / `common_retry`, so a
/// screen never shows French while the app is in Arabic.
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
    return _StateFrame(
      borderColor: MaamoraColors.border,
      iconBg: MaamoraColors.primarySoft,
      iconColor: MaamoraColors.primary,
      icon: icon,
      title: title,
      subtitle: subtitle,
      action: actionLabel != null && onAction != null
          ? MaamoraButton(
              label: actionLabel!,
              onPressed: onAction,
              expanded: false,
            )
          : null,
    );
  }
}

class MaamoraErrorState extends StatelessWidget {
  const MaamoraErrorState({
    super.key,
    this.title,
    this.subtitle,
    this.onRetry,
    this.retryLabel,
  });

  /// Defaults to `common_error_title`.
  final String? title;
  final String? subtitle;
  final VoidCallback? onRetry;

  /// Defaults to `common_retry`.
  final String? retryLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: _StateFrame(
        borderColor: MaamoraColors.dangerSoft,
        iconBg: MaamoraColors.dangerSoft,
        iconColor: MaamoraColors.danger,
        icon: MaamoraIcons.info,
        title: title ?? context.tr('common_error_title'),
        subtitle: subtitle,
        subtitleMaxLines: 3,
        action: onRetry != null
            ? MaamoraButton(
                label: retryLabel ?? context.tr('common_retry'),
                leadingIcon: MaamoraIcons.restart,
                onPressed: onRetry,
                expanded: false,
              )
            : null,
      ),
    );
  }
}

/// Shared layout of both states: icon tile → title → subtitle → action.
class _StateFrame extends StatelessWidget {
  const _StateFrame({
    required this.borderColor,
    required this.iconBg,
    required this.iconColor,
    required this.icon,
    required this.title,
    this.subtitle,
    this.subtitleMaxLines,
    this.action,
  });

  final Color borderColor;
  final Color iconBg;
  final Color iconColor;
  final IconData icon;
  final String title;
  final String? subtitle;
  final int? subtitleMaxLines;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: 36,
        horizontal: MaamoraSpacing.screen,
      ),
      decoration: BoxDecoration(
        color: MaamoraColors.surface,
        borderRadius: MaamoraRadius.cardR,
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          ExcludeSemantics(
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: MaamoraRadius.cardR,
              ),
              child: Icon(icon, color: iconColor, size: 28),
            ),
          ),
          const SizedBox(height: MaamoraSpacing.lg),
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
            const SizedBox(height: MaamoraSpacing.sm),
            Text(
              subtitle!,
              textAlign: TextAlign.center,
              maxLines: subtitleMaxLines,
              overflow: subtitleMaxLines != null
                  ? TextOverflow.ellipsis
                  : TextOverflow.clip,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                color: MaamoraColors.textSecondary, // D5 en attente
                height: 1.5,
              ),
            ),
          ],
          if (action != null) ...[
            const SizedBox(height: MaamoraSpacing.xl - MaamoraSpacing.xs),
            FractionallySizedBox(widthFactor: 0.7, child: action),
          ],
        ],
      ),
    );
  }
}
