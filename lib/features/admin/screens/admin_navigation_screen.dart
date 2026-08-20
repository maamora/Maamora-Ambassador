import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../shared/widgets/shared_app_bar.dart';
import '../../../features/admin/screens/admin_profile_screen.dart';
import '../providers/admin_groups_provider.dart';
import '../providers/pending_ambassadors_provider.dart';
import 'admin_dashboard_screen.dart';
import 'admin_invite_ambassador_screen.dart';
import 'admin_ambassadors_pending_screen.dart';
import 'admin_ambassadors_list_screen.dart';
import 'admin_groups_pending_screen.dart';
import 'admin_commissions_screen.dart';
import 'admin_audit_log_screen.dart';

// ── Design tokens ──────────────────────────────────────────────────────────
const Color _primary = Color(0xFFFB7701);
const Color _surface = Color(0xFFFFF8F5);
const Color _onSurfaceVariant = Color(0xFF584236);

/// Admin navigation shell with 4 bottom-nav tabs that match the screenshots:
///   [Apps]  [Ambassadors]  [Groups]  [Settings]
///
/// "Apps" = Invite ambassador (main admin action)
/// "Ambassadors" = sub-tabs for Pending + All ambassadors
/// "Groups" = Completed groups pending commission
/// "Settings" = Commissions + Audit log
class AdminNavigationScreen extends ConsumerStatefulWidget {
  const AdminNavigationScreen({super.key});

  @override
  ConsumerState<AdminNavigationScreen> createState() => _AdminNavigationScreenState();
}

class _AdminNavigationScreenState extends ConsumerState<AdminNavigationScreen> {
  int _currentIndex = 0;
  // Ambassadors sub-tab: 0 = Pending, 1 = All
  int _ambassadorsSubTab = 0;
  // Settings sub-tab: 0 = Commissions, 1 = Audit Log
  int _settingsSubTab = 0;

  // Navigate from dashboard quick-action to a specific tab
  void _navigateFromDashboard(String section) {
    switch (section) {
      case 'invites':
        setState(() => _currentIndex = 0);
        break;
      case 'pending_ambassadors':
        setState(() {
          _currentIndex = 1;
          _ambassadorsSubTab = 0;
        });
        break;
      case 'groups':
        setState(() => _currentIndex = 2);
        break;
      case 'commissions':
        setState(() {
          _currentIndex = 3;
          _settingsSubTab = 0;
        });
        break;
      case 'audit':
        setState(() {
          _currentIndex = 3;
          _settingsSubTab = 1;
        });
        break;
    }
  }

  String _getTitle() {
    switch (_currentIndex) {
      case 0:
        return 'Admin Applications';
      case 1:
        return _ambassadorsSubTab == 0
            ? 'Candidatures'
            : 'Ambassadeurs';
      case 2:
        return 'Groupes complets';
      case 3:
        return _settingsSubTab == 0 ? 'Commissions' : 'Journal d\'audit';
      default:
        return 'Admin';
    }
  }

  Widget _buildCurrentPage() {
    switch (_currentIndex) {
      case 0:
        // Invite ambassador — the primary "Apps" tab
        return const AdminInviteAmbassadorScreen();
      case 1:
        // Ambassadors tab with sub-tabs
        return _AmbassadorsTabWrapper(
          currentSubTab: _ambassadorsSubTab,
          onSubTabChanged: (i) => setState(() => _ambassadorsSubTab = i),
        );
      case 2:
        return const AdminGroupsPendingScreen();
      case 3:
        // Settings tab: commissions + audit log
        return _SettingsTabWrapper(
          currentSubTab: _settingsSubTab,
          onSubTabChanged: (i) => setState(() => _settingsSubTab = i),
        );
      default:
        return AdminDashboardScreen(onNavigateTo: _navigateFromDashboard);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SharedAppBar(
        title: _getTitle(),
        onAvatarTap: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => DraggableScrollableSheet(
            initialChildSize: 0.75,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            expand: false,
            builder: (ctx, scrollController) => Container(
              decoration: const BoxDecoration(
                color: Color(0xFFFAF5F0),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD8CEC7),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: const AdminProfileContent(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: _buildCurrentPage(),
      bottomNavigationBar: _AdminBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        pendingAmbassadors: ref.watch(pendingAmbassadorsCountProvider).value ?? 0,
        pendingGroups: ref.watch(adminGroupsProvider).pendingCommissionCount,
      ),
    );
  }
}

// ── Ambassadors tab with sub-tabs ─────────────────────────────────────────

class _AmbassadorsTabWrapper extends ConsumerWidget {
  final int currentSubTab;
  final void Function(int) onSubTabChanged;

  const _AmbassadorsTabWrapper({
    required this.currentSubTab,
    required this.onSubTabChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingAmbassadorsCount = ref.watch(pendingAmbassadorsCountProvider).value ?? 0;

    return Column(
      children: [
        // Sub-tab bar
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              _SubTabChip(
                label: 'En attente',
                isActive: currentSubTab == 0,
                badge: pendingAmbassadorsCount,
                onTap: () => onSubTabChanged(0),
              ),
              const SizedBox(width: 8),
              _SubTabChip(
                label: 'Tous',
                isActive: currentSubTab == 1,
                onTap: () => onSubTabChanged(1),
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: Color(0xFFEDE8E4)),
        Expanded(
          child: currentSubTab == 0
              ? const AdminAmbassadorsPendingScreen()
              : const AdminAmbassadorsListScreen(),
        ),
      ],
    );
  }
}

// ── Settings tab with sub-tabs ────────────────────────────────────────────

class _SettingsTabWrapper extends StatelessWidget {
  final int currentSubTab;
  final void Function(int) onSubTabChanged;

  const _SettingsTabWrapper({
    required this.currentSubTab,
    required this.onSubTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              _SubTabChip(
                label: 'Commissions',
                isActive: currentSubTab == 0,
                onTap: () => onSubTabChanged(0),
              ),
              const SizedBox(width: 8),
              _SubTabChip(
                label: 'Journal d\'audit',
                isActive: currentSubTab == 1,
                onTap: () => onSubTabChanged(1),
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: Color(0xFFEDE8E4)),
        Expanded(
          child: currentSubTab == 0
              ? const AdminCommissionsScreen()
              : const AdminAuditLogScreen(),
        ),
      ],
    );
  }
}

// ── Sub-tab chip ──────────────────────────────────────────────────────────

class _SubTabChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final int? badge;
  final VoidCallback onTap;

  const _SubTabChip({
    required this.label,
    required this.isActive,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? _primary : const Color(0xFFEDE8E4),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isActive ? Colors.white : _onSurfaceVariant,
              ),
            ),
            if (badge != null && badge! > 0) ...[
              const SizedBox(width: 4),
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: isActive
                      ? Colors.white.withValues(alpha: 0.3)
                      : _primary,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  '$badge',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: isActive ? Colors.white : Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Admin Bottom Nav Bar ──────────────────────────────────────────────────

class _AdminBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final void Function(int) onTap;
  final int pendingAmbassadors;
  final int pendingGroups;

  const _AdminBottomNavBar({
    required this.currentIndex,
    required this.onTap,
    required this.pendingAmbassadors,
    required this.pendingGroups,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 16,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _AdminNavItem(
                icon: Icons.grid_view_rounded,
                label: 'Apps',
                isActive: currentIndex == 0,
                onTap: () => onTap(0),
              ),
              _AdminNavItem(
                icon: Icons.people_rounded,
                label: 'Ambassadors',
                isActive: currentIndex == 1,
                badge: pendingAmbassadors,
                onTap: () => onTap(1),
              ),
              _AdminNavItem(
                icon: Icons.inventory_2_outlined,
                label: 'Groups',
                isActive: currentIndex == 2,
                badge: pendingGroups,
                onTap: () => onTap(2),
              ),
              _AdminNavItem(
                icon: Icons.account_balance_wallet_rounded,
                label: 'Finances',
                isActive: currentIndex == 3,
                onTap: () => onTap(3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AdminNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final int? badge;
  final VoidCallback onTap;

  const _AdminNavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 72,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  icon,
                  color: isActive ? _primary : _onSurfaceVariant,
                  size: 24,
                ),
                if (badge != null && badge! > 0)
                  Positioned(
                    top: -4,
                    right: -6,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: const BoxDecoration(
                        color: _primary,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '$badge',
                        style: GoogleFonts.inter(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                color: isActive ? _primary : _onSurfaceVariant,
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
