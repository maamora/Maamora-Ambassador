import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ── Design tokens (match project palette) ─────────────────────────────────
const Color _onBackground = Color(0xFF1A2433);

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
        config.label,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: config.foreground,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _BadgeConfig {
  final Color background;
  final Color border;
  final Color foreground;
  final String label;

  const _BadgeConfig({
    required this.background,
    required this.border,
    required this.foreground,
    required this.label,
  });
}

_BadgeConfig _badgeConfig(String status) {
  switch (status.toLowerCase()) {
    // ── Invite code statuses ──────────────────────────────────────────────
    case 'unused':
      return const _BadgeConfig(
        background: Color(0xFFDCEEE3),
        border: Color(0xFF88C4A0),
        foreground: Color(0xFF1B4332),
        label: 'Unused',
      );
    case 'used':
      return const _BadgeConfig(
        background: Color(0xFFE8DDD3),
        border: Color(0xFFB8A898),
        foreground: _onBackground,
        label: 'Used',
      );
    case 'expired':
      return const _BadgeConfig(
        background: Color(0xFFF9DEDC),
        border: Color(0xFFE8A8A4),
        foreground: Color(0xFF8B1E1A),
        label: 'Expired',
      );
    case 'revoked':
      return const _BadgeConfig(
        background: Color(0xFFEEEEEE),
        border: Color(0xFFBBBBBB),
        foreground: Color(0xFF555555),
        label: 'Revoked',
      );

    // ── Ambassador statuses ───────────────────────────────────────────────
    case 'pending':
      return const _BadgeConfig(
        background: Color(0xFFFCEBC9),
        border: Color(0xFFE8C070),
        foreground: Color(0xFF7A4800),
        label: 'Pending',
      );
    case 'active':
      return const _BadgeConfig(
        background: Color(0xFFDCEEE3),
        border: Color(0xFF88C4A0),
        foreground: Color(0xFF1B4332),
        label: 'Active',
      );
    case 'rejected':
      return const _BadgeConfig(
        background: Color(0xFFF9DEDC),
        border: Color(0xFFE8A8A4),
        foreground: Color(0xFF8B1E1A),
        label: 'Rejected',
      );
    case 'suspended':
      return const _BadgeConfig(
        background: Color(0xFFEEEEEE),
        border: Color(0xFFBBBBBB),
        foreground: Color(0xFF555555),
        label: 'Suspended',
      );

    // ── Commission statuses ───────────────────────────────────────────────
    case 'paid':
      return const _BadgeConfig(
        background: Color(0xFFDCEEE3),
        border: Color(0xFF88C4A0),
        foreground: Color(0xFF1B4332),
        label: 'Paid',
      );
    case 'failed':
      return const _BadgeConfig(
        background: Color(0xFFF9DEDC),
        border: Color(0xFFE8A8A4),
        foreground: Color(0xFF8B1E1A),
        label: 'Failed',
      );

    // ── Group statuses ────────────────────────────────────────────────────
    case 'full':
      return const _BadgeConfig(
        background: Color(0xFFFCEBC9),
        border: Color(0xFFE8C070),
        foreground: Color(0xFF7A4800),
        label: '15/15 Full',
      );
    case 'open':
      return const _BadgeConfig(
        background: Color(0xFFDCEEE3),
        border: Color(0xFF88C4A0),
        foreground: Color(0xFF1B4332),
        label: 'Open',
      );
    case 'closed':
      return const _BadgeConfig(
        background: Color(0xFFEEEEEE),
        border: Color(0xFFBBBBBB),
        foreground: Color(0xFF555555),
        label: 'Closed',
      );
    case 'commission_paid':
      return const _BadgeConfig(
        background: Color(0xFFDCEEE3),
        border: Color(0xFF88C4A0),
        foreground: Color(0xFF1B4332),
        label: 'Commission Paid',
      );

    default:
      return _BadgeConfig(
        background: const Color(0xFFEEEEEE),
        border: const Color(0xFFBBBBBB),
        foreground: _onBackground,
        label: status,
      );
  }
}
