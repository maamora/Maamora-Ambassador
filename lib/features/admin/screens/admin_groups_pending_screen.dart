import 'package:flutter/material.dart';
import '../../../shared/widgets/design_kit.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/admin_groups_provider.dart';
import '../../../design_system/design_system.dart';
import '../../../core/l10n/app_strings.dart';

// ── Design tokens ──────────────────────────────────────────────────────────
const Color _primary = MaamoraColors.primary;
const Color _background = Colors.white;
const Color _surface = Colors.white;
const Color _onBackground = MaamoraColors.textPrimary;
const Color _onSurfaceVariant = MaamoraColors.textSecondary;
const Color _cardBorder = MaamoraColors.border;
const Color _orangeLight = MaamoraColors.warningSoft;

// ── Filter enum ───────────────────────────────────────────────────────────
// 3 états EXCLUSIFS — chaque groupe n'apparaît que dans un seul filtre
enum _GroupFilter { enCours, enAttente, traites }

extension _GroupFilterLabel on _GroupFilter {
  String label(BuildContext context) {
    switch (this) {
      case _GroupFilter.enCours:
        return context.tr('ad_in_progress_n', args: {'n': ''});
      case _GroupFilter.enAttente:
        return context.tr('ad_pending');
      case _GroupFilter.traites:
        return context.tr('ad_done');
    }
  }

  IconData get icon {
    switch (this) {
      case _GroupFilter.enCours:
        return Icons.timelapse_rounded;
      case _GroupFilter.enAttente:
        return Icons.pending_actions_rounded;
      case _GroupFilter.traites:
        return Icons.check_circle_rounded;
    }
  }
}

class AdminGroupsPendingScreen extends ConsumerStatefulWidget {
  const AdminGroupsPendingScreen({super.key});

  @override
  ConsumerState<AdminGroupsPendingScreen> createState() =>
      _AdminGroupsPendingScreenState();
}

class _AdminGroupsPendingScreenState
    extends ConsumerState<AdminGroupsPendingScreen> {
  _GroupFilter _activeFilter = _GroupFilter.enCours;

  List<AdminGroupItem> _applyFilter(List<AdminGroupItem> all) {
    switch (_activeFilter) {
      case _GroupFilter.enCours:
        // Pas encore plein
        return all.where((g) => !g.isComplete).toList();
      case _GroupFilter.enAttente:
        // Plein MAIS commission pas encore assignée
        return all.where((g) => g.isComplete && !g.commissionAssigned).toList();
      case _GroupFilter.traites:
        // Plein ET commission déjà payée
        return all.where((g) => g.isComplete && g.commissionAssigned).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminGroupsProvider);
    final notifier = ref.read(adminGroupsProvider.notifier);

    // Show error snackbar when error changes
    ref.listen<AdminGroupsState>(adminGroupsProvider, (prev, next) {
      if (next.error != null && next.error != prev?.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: MaamoraColors.danger,
          ),
        );
      }
    });

    final filtered = _applyFilter(state.groups);
    final countEnCours =
        state.groups.where((g) => !g.isComplete).length;
    final countEnAttente = state.groups
        .where((g) => g.isComplete && !g.commissionAssigned)
        .length;
    final countTraites = state.groups
        .where((g) => g.isComplete && g.commissionAssigned)
        .length;

    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ───────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.tr('ad_groups_title'),
                          style: GoogleFonts.cairo(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: _onBackground,
                          ),
                        ),
                        if (!state.isLoading)
                          Text(
                            '${context.tr('ad_in_progress_n', args: {'n': '$countEnCours'})} · '
                            '${context.tr('ad_pending_n', args: {'n': '$countEnAttente'})} · '
                            '${context.tr('ad_done_n', args: {'n': '$countTraites'})}',
                            style: GoogleFonts.cairo(
                                fontSize: 13, color: _onSurfaceVariant),
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: notifier.fetchGroups,
                    icon: const Icon(Icons.refresh_rounded, color: _primary),
                    tooltip: context.tr('common_refresh'),
                  ),
                ],
              ),
            ),

            // ── Filter chips (3 états exclusifs) ─────────────────────────
            // Wrap : les chips passent à la ligne au lieu de déborder (fix
            // de la barre jaune « overflowed by 24 px » en haut de page).
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 8),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _FilterChip(
                    label: _GroupFilter.enCours.label(context),
                    icon: _GroupFilter.enCours.icon,
                    count: countEnCours,
                    isActive: _activeFilter == _GroupFilter.enCours,
                    onTap: () =>
                        setState(() => _activeFilter = _GroupFilter.enCours),
                  ),
                  _FilterChip(
                    label: _GroupFilter.enAttente.label(context),
                    icon: _GroupFilter.enAttente.icon,
                    count: countEnAttente,
                    isActive: _activeFilter == _GroupFilter.enAttente,
                    color: MaamoraColors.primary,
                    onTap: () =>
                        setState(() => _activeFilter = _GroupFilter.enAttente),
                  ),
                  _FilterChip(
                    label: _GroupFilter.traites.label(context),
                    icon: _GroupFilter.traites.icon,
                    count: countTraites,
                    isActive: _activeFilter == _GroupFilter.traites,
                    color: MaamoraColors.success,
                    onTap: () =>
                        setState(() => _activeFilter = _GroupFilter.traites),
                  ),
                ],
              ),
            ),

            // ── List ─────────────────────────────────────────────────────
            Expanded(
              child: state.isLoading
                  ? const AppLoader()
                  : state.error != null && state.groups.isEmpty
                      ? _buildError(notifier.fetchGroups)
                      : filtered.isEmpty
                          ? _buildEmpty()
                          : RefreshIndicator(
                              color: _primary,
                              onRefresh: notifier.fetchGroups,
                              child: ListView.separated(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 4),
                                itemCount: filtered.length,
                                separatorBuilder: (_, _) =>
                                    const SizedBox(height: 10),
                                itemBuilder: (ctx, i) => _GroupCard(
                                  group: filtered[i],
                                  onAssign: filtered[i].isComplete &&
                                          !filtered[i].commissionAssigned
                                      ? () => _handleAssign(
                                            ctx,
                                            filtered[i],
                                            notifier,
                                          )
                                      : null,
                                ),
                              ),
                            ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(VoidCallback onRetry) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded,
                size: 48, color: _onSurfaceVariant),
            const SizedBox(height: 12),
            Text(
              context.tr('ad_groups_load_err'),
              textAlign: TextAlign.center,
              style:
                  GoogleFonts.cairo(fontSize: 14, color: _onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(context.tr('common_retry')),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.inventory_2_outlined,
                size: 48, color: _onSurfaceVariant),
            const SizedBox(height: 12),
            Text(
              context.tr('ad_groups_cat_empty'),
              textAlign: TextAlign.center,
              style:
                  GoogleFonts.cairo(fontSize: 14, color: _onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleAssign(
    BuildContext ctx,
    AdminGroupItem group,
    AdminGroupsNotifier notifier,
  ) async {
    final confirmed = await showDialog<bool>(
      context: ctx,
      builder: (_) => AlertDialog(
        title: Text(
          context.tr('ad_assign_commission'),
          style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
        ),
        content: Text(
          context.tr('ad_assign_confirm', args: {'name': group.productName}),
          style: GoogleFonts.cairo(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(context.tr('common_cancel')),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: MaamoraColors.warningDeep,
              foregroundColor: Colors.white,
            ),
            child: Text(context.tr('common_confirm')),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await notifier.assignCommission(group.id);
      if (ctx.mounted) {
        ScaffoldMessenger.of(ctx).showSnackBar(
          SnackBar(
            content: Text(ctx.tr('ad_assigned_for', args: {'name': group.productName})),
            backgroundColor: MaamoraColors.success,
          ),
        );
      }
    }
  }
}

// ── Filter Chip ───────────────────────────────────────────────────────────

class _FilterChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final int count;
  final bool isActive;
  final VoidCallback onTap;
  final Color? color;

  const _FilterChip({
    required this.label,
    required this.count,
    required this.isActive,
    required this.onTap,
    this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = color ?? _primary;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isActive ? activeColor : MaamoraColors.surfaceLow,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: activeColor.withValues(alpha: 0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 13,
                  color: isActive ? Colors.white : _onSurfaceVariant),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: GoogleFonts.cairo(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isActive ? Colors.white : _onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 5),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: isActive
                    ? Colors.white.withValues(alpha: 0.25)
                    : activeColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: GoogleFonts.cairo(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: isActive ? Colors.white : activeColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Group Card ────────────────────────────────────────────────────────────


class _GroupCard extends StatelessWidget {
  final AdminGroupItem group;
  /// null = disabled (not full or already paid)
  final VoidCallback? onAssign;

  const _GroupCard({required this.group, required this.onAssign});

  @override
  Widget build(BuildContext context) {
    final isFull = group.isComplete;
    final progressRatio =
        group.seatsTotal > 0 ? group.membersCount / group.seatsTotal : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isFull
              ? MaamoraColors.warningEdge.withValues(alpha: 0.6)
              : _cardBorder,
        ),
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
        children: [
          // ── Top row: name + badge ──────────────────────────────────
          Row(
            children: [
              Expanded(
                child: Text(
                  group.productName,
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: _onBackground,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              // Full badge or progress badge
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isFull
                      ? _orangeLight
                      : MaamoraColors.surfaceLow,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isFull
                        ? MaamoraColors.warningEdge
                        : _cardBorder,
                    width: 1,
                  ),
                ),
                child: Text(
                  isFull
                      ? context.tr('ad_full_short', args: {'a': '${group.membersCount}', 'b': '${group.seatsTotal}'})
                      : '${group.membersCount}/${group.seatsTotal}',
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isFull
                        ? MaamoraColors.warningDeep
                        : _onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // ── Progress bar (only for non-full groups) ────────────────
          if (!isFull) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progressRatio.clamp(0.0, 1.0),
                minHeight: 5,
                backgroundColor: MaamoraColors.surfaceLow,
                valueColor: const AlwaysStoppedAnimation<Color>(_primary),
              ),
            ),
            const SizedBox(height: 8),
          ],

              // ── Ambassador + date ──────────────────────────────────────
              Row(
                children: [
                  const Icon(Icons.person_outline,
                      size: 14, color: _onSurfaceVariant),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      context.tr('ad_ambassador_label', args: {'name': group.ambassadorName}),
                      style: GoogleFonts.cairo(
                          fontSize: 13, color: _onSurfaceVariant),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Icon(Icons.access_time_rounded,
                      size: 14, color: _onSurfaceVariant),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      group.completedAt,
                      style: GoogleFonts.cairo(
                          fontSize: 13, color: _onSurfaceVariant),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
          Text(
            context.tr('ad_price_per', args: {'n': group.pricePerPerson.toStringAsFixed(0)}),
            style: GoogleFonts.cairo(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _primary,
            ),
          ),
          const SizedBox(height: 12),

          // ── Action button ──────────────────────────────────────────
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: group.commissionAssigned
                // Already paid
                ? Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: MaamoraColors.surfaceLow,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_circle_rounded,
                            size: 16, color: MaamoraColors.disabledBorder),
                        const SizedBox(width: 6),
                        Text(
                          context.tr('ad_comm_paid'),
                          style: GoogleFonts.cairo(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: MaamoraColors.disabledBorder,
                          ),
                        ),
                      ],
                    ),
                  )
                : isFull
                    // Full + unpaid → active button
                    ? ElevatedButton(
                        onPressed: onAssign,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: MaamoraColors.warningDeep,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          context.tr('ad_assign_commission'),
                          style: GoogleFonts.cairo(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      )
                    // Not full → disabled button
                    : Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: MaamoraColors.surfaceLow,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.lock_outline_rounded,
                                size: 14, color: MaamoraColors.textFaint),
                            const SizedBox(width: 6),
                            Text(
                              context.tr('ad_group_incomplete'),
                              style: GoogleFonts.cairo(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: MaamoraColors.textFaint,
                              ),
                            ),
                          ],
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
