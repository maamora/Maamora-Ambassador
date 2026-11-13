import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../design_system/design_system.dart';
import '../../../core/l10n/app_strings.dart';

// ── Design tokens (match project palette) ─────────────────────────────────
const Color _onBackground = MaamoraColors.textPrimary;

/// Reusable colored badge for admin status labels.
///
/// Supported [status] values and their meaning:
///   invite codes  : 'unused' | 'used' | 'expired' | 'revoked'
///   ambassadors   : 'pending' | 'active' | 'rejected' | 'suspended'
///   commissions   : 'paid' | 'pending' | 'failed'
///   groups        : 'open' | 'full' | 'closed'
class AdminStatusBadge extends StatelessWidget {
  final String status;

  const AdminStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final config = _badgeConfig(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: config.background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: config.border, width: 1),
      ),
      child: Text(
        _badgeLabel(context, status),
        style: GoogleFonts.cairo(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: config.foreground,
        ),
      ),
    );
  }
}

class _BadgeConfig {
  final Color background;
  final Color border;
  final Color foreground;

  const _BadgeConfig({
    required this.background,
    required this.border,
    required this.foreground,
  });
}

/// Translated label per status code.
String _badgeLabel(BuildContext context, String status) {
  switch (status.toLowerCase()) {
    case 'unused':
      return context.tr('ad_badge_unused');
    case 'used':
      return context.tr('ad_badge_used');
    case 'expired':
      return context.tr('ad_badge_expired');
    case 'revoked':
      return context.tr('ad_badge_revoked');
    case 'pending':
      return context.tr('ad_pending');
    case 'active':
      return context.tr('ad_badge_active');
    case 'rejected':
      return context.tr('ad_badge_rejected');
    case 'suspended':
      return context.tr('ad_badge_suspended');
    case 'paid':
      return context.tr('ad_badge_paid');
    case 'failed':
      return context.tr('ad_badge_failed');
    case 'full':
      return context.tr('ad_badge_full');
    case 'open':
      return context.tr('ad_badge_open');
    case 'closed':
      return context.tr('ad_badge_closed');
    case 'commission_paid':
      return context.tr('ad_comm_paid');
    default:
      return status;
  }
}

_BadgeConfig _badgeConfig(String status) {
  switch (status.toLowerCase()) {
    // ── Invite code statuses ──────────────────────────────────────────────
    case 'unused':
      return const _BadgeConfig(
        background: MaamoraColors.successSoft,
        border: MaamoraColors.successEdge,
        foreground: MaamoraColors.successOn,
      );
    case 'used':
      return const _BadgeConfig(
        background: MaamoraColors.border,
        border: MaamoraColors.borderStrong,
        foreground: _onBackground,
      );
    case 'expired':
      return const _BadgeConfig(
        background: MaamoraColors.dangerSoft,
        border: MaamoraColors.dangerEdge,
        foreground: MaamoraColors.dangerDeep,
      );
    case 'revoked':
      return const _BadgeConfig(
        background: MaamoraColors.disabledBg,
        border: MaamoraColors.disabledBorder,
        foreground: MaamoraColors.disabledFg,
      );

    // ── Ambassador statuses ───────────────────────────────────────────────
    case 'pending':
      return const _BadgeConfig(
        background: MaamoraColors.warningSoft,
        border: MaamoraColors.warningEdge,
        foreground: MaamoraColors.warningDeep,
      );
    case 'active':
      return const _BadgeConfig(
        background: MaamoraColors.successSoft,
        border: MaamoraColors.successEdge,
        foreground: MaamoraColors.successOn,
      );
    case 'rejected':
      return const _BadgeConfig(
        background: MaamoraColors.dangerSoft,
        border: MaamoraColors.dangerEdge,
        foreground: MaamoraColors.dangerDeep,
      );
    case 'suspended':
      return const _BadgeConfig(
        background: MaamoraColors.disabledBg,
        border: MaamoraColors.disabledBorder,
        foreground: MaamoraColors.disabledFg,
      );

    // ── Commission statuses ───────────────────────────────────────────────
    case 'paid':
      return const _BadgeConfig(
        background: MaamoraColors.successSoft,
        border: MaamoraColors.successEdge,
        foreground: MaamoraColors.successOn,
      );
    case 'failed':
      return const _BadgeConfig(
        background: MaamoraColors.dangerSoft,
        border: MaamoraColors.dangerEdge,
        foreground: MaamoraColors.dangerDeep,
      );

    // ── Group statuses ────────────────────────────────────────────────────
    case 'full':
      return const _BadgeConfig(
        background: MaamoraColors.warningSoft,
        border: MaamoraColors.warningEdge,
        foreground: MaamoraColors.warningDeep,
      );
    case 'open':
      return const _BadgeConfig(
        background: MaamoraColors.successSoft,
        border: MaamoraColors.successEdge,
        foreground: MaamoraColors.successOn,
      );
    case 'closed':
      return const _BadgeConfig(
        background: MaamoraColors.disabledBg,
        border: MaamoraColors.disabledBorder,
        foreground: MaamoraColors.disabledFg,
      );
    case 'commission_paid':
      return const _BadgeConfig(
        background: MaamoraColors.successSoft,
        border: MaamoraColors.successEdge,
        foreground: MaamoraColors.successOn,
      );

    default:
      return _BadgeConfig(
        background: MaamoraColors.disabledBg,
        border: MaamoraColors.disabledBorder,
        foreground: _onBackground,
      );
  }
}
