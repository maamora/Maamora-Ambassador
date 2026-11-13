import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../design_system/design_system.dart';
import '../../../core/l10n/app_strings.dart';

// ── Design tokens (match project palette) ─────────────────────────────────
const Color _primary = MaamoraColors.primary;
const Color _secondary = MaamoraColors.textPrimary;
const Color _background = Colors.white;
const Color _surface = Colors.white;
const Color _onBackground = MaamoraColors.textPrimary;
const Color _onSurfaceVariant = MaamoraColors.textSecondary;
const Color _cardBorder = MaamoraColors.border;
const Color _orangeLight = MaamoraColors.primarySoft;

// ── données factices, à remplacer ─────────────────────────────────────────
List<_DashStat> _mockStats(BuildContext context) => [
  _DashStat(
    icon: Icons.hourglass_top_rounded,
    value: '3',
    label: context.tr('ad_dash_pending_amb'),
    iconColor: MaamoraColors.primary,
    iconBg: MaamoraColors.warningSoft,
  ),
  _DashStat(
    icon: Icons.groups_rounded,
    value: '7',
    label: context.tr('ad_full_groups'),
    iconColor: _primary,
    iconBg: _orangeLight,
  ),
  _DashStat(
    icon: Icons.link,
    value: '12',
    label: context.tr('ad_inv_sent'),
    iconColor: MaamoraColors.success,
    iconBg: MaamoraColors.successSoft,
  ),
  _DashStat(
    icon: Icons.payments_outlined,
    value: '4',
    label: context.tr('ad_dash_pending_comm'),
    iconColor: MaamoraColors.infoBlue,
    iconBg: MaamoraColors.infoBlueSoft,
  ),
];

class AdminDashboardScreen extends StatelessWidget {
  /// Called when user taps a section card to navigate there.
  /// [section] can be: 'pending_ambassadors' | 'groups' | 'invites' | 'commissions'
  final void Function(String section)? onNavigateTo;

  const AdminDashboardScreen({super.key, this.onNavigateTo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 20),
              _buildStatsGrid(context),
              const SizedBox(height: 24),
              _buildQuickActions(context),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.tr('ad_dash_title'),
                style: GoogleFonts.cairo(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: _onBackground,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                context.tr('ad_dash_overview'),
                style: GoogleFonts.cairo(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: _onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        // Admin badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: _secondary,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.admin_panel_settings_rounded,
                  color: Colors.white, size: 13),
              const SizedBox(width: 4),
              Text(
                'Admin',
                style: GoogleFonts.cairo(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Résumé',
          style: GoogleFonts.cairo(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: _onBackground,
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.3,
          children: _mockStats(context).map((stat) {
            return _DashStatCard(stat: stat, onTap: () {});
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.tr('ad_quick_actions'),
          style: GoogleFonts.cairo(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: _onBackground,
          ),
        ),
        const SizedBox(height: 12),
        _QuickActionRow(
          icon: Icons.link,
          label: context.tr('ad_invite'),
          subtitle: context.tr('ad_generate_link'),
          onTap: () => onNavigateTo?.call('invites'),
        ),
        const SizedBox(height: 10),
        _QuickActionRow(
          icon: Icons.person_search_rounded,
          label: context.tr('ad_pending_apps'),
          subtitle: context.tr('ad_apps_sub'),
          badgeCount: 3,
          onTap: () => onNavigateTo?.call('pending_ambassadors'),
        ),
        const SizedBox(height: 10),
        _QuickActionRow(
          icon: Icons.inventory_2_outlined,
          label: context.tr('ad_full_groups'),
          subtitle: context.tr('ad_groups_sub'),
          badgeCount: 7,
          onTap: () => onNavigateTo?.call('groups'),
        ),
        const SizedBox(height: 10),
        _QuickActionRow(
          icon: Icons.payments_outlined,
          label: context.tr('ad_comm_title'),
          subtitle: context.tr('ad_see_history'),
          onTap: () => onNavigateTo?.call('commissions'),
        ),
        const SizedBox(height: 10),
        _QuickActionRow(
          icon: Icons.history_rounded,
          label: context.tr('ad_log_title'),
          subtitle: context.tr('ad_log_sub'),
          onTap: () => onNavigateTo?.call('audit'),
        ),
      ],
    );
  }
}

// ── Internal widgets ──────────────────────────────────────────────────────

class _DashStat {
  final IconData icon;
  final String value;
  final String label;
  final Color iconColor;
  final Color iconBg;

  const _DashStat({
    required this.icon,
    required this.value,
    required this.label,
    required this.iconColor,
    required this.iconBg,
  });
}

class _DashStatCard extends StatelessWidget {
  final _DashStat stat;
  final VoidCallback? onTap;

  const _DashStatCard({required this.stat, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _cardBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: stat.iconBg,
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Icon(stat.icon, color: stat.iconColor, size: 18),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stat.value,
                  style: GoogleFonts.cairo(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: _onBackground,
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  stat.label,
                  style: GoogleFonts.cairo(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: _onSurfaceVariant,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final int? badgeCount;
  final VoidCallback? onTap;

  const _QuickActionRow({
    required this.icon,
    required this.label,
    required this.subtitle,
    this.badgeCount,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _cardBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: _orangeLight,
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Icon(icon, color: _primary, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _onBackground,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: _onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (badgeCount != null) ...[
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$badgeCount',
                  style: GoogleFonts.cairo(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right_rounded,
                color: _onSurfaceVariant, size: 20),
          ],
        ),
      ),
    );
  }
}
