import 'package:flutter/material.dart';
import '../../../shared/widgets/shared_app_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../providers/my_groups_provider.dart';
import '../../../shared/widgets/design_kit.dart';
import '../../../design_system/design_system.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../shared/navigation/app_routes.dart';

// Colors: charte centralisée (tokens DS)
const Color _surfaceContainerLowest = MaamoraColors.surface;
const Color _onBackground = MaamoraColors.textPrimary;
const Color _onSurfaceVariant = MaamoraColors.textSecondary;
const Color _outlineVariant = MaamoraColors.border;

class MyGroupsScreen extends ConsumerWidget {
  const MyGroupsScreen({super.key});

  /// Pull-to-refresh: invalidates the groups provider; the current list stays
  /// on screen until the new one arrives.
  Future<void> _refresh(WidgetRef ref) async {
    ref.invalidate(myGroupsProvider);
    await ref.read(myGroupsProvider.future);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupsAsync = ref.watch(myGroupsProvider);

    return Scaffold(
      backgroundColor: MaamoraColors.scaffold,
      appBar: const SharedAppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: MaamoraSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: MaamoraSpacing.lg),
              Row(
                children: [
                  // Localized tooltip + icon mirrored in Arabic.
                  BackButton(
                    color: _onBackground,
                    onPressed: () => context.pop(),
                  ),
                  const SizedBox(width: MaamoraSpacing.xs),
                  Expanded(
                    child: Text(
                      context.tr('groups_title'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: MaamoraTheme.screenTitle(),
                    ),
                  ),
                  IconButton(
                    tooltip: context.tr('common_refresh'),
                    icon: const Icon(Icons.refresh, color: _onSurfaceVariant),
                    onPressed: () =>
                        ref.read(myGroupsProvider.notifier).refresh(),
                  ),
                ],
              ),
              const SizedBox(height: MaamoraSpacing.lg),
              Expanded(
                child: groupsAsync.when(
                  data: (groups) {
                    if (groups.isEmpty) {
                      // Still pullable, and the empty state offers the action.
                      return RefreshIndicator(
                        color: MaamoraColors.primary,
                        onRefresh: () => _refresh(ref),
                        child: ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            MaamoraEmptyState(
                              icon: MaamoraIcons.users,
                              title: context.tr('groups_empty'),
                              subtitle: context.tr('groups_empty_sub'),
                              actionLabel: context.tr('dash_new_group'),
                              onAction: () =>
                                  context.push(AppRoutes.createGroup),
                            ),
                          ],
                        ),
                      );
                    }
                    return RefreshIndicator(
                      color: MaamoraColors.primary,
                      onRefresh: () => _refresh(ref),
                      child: ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: groups.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: MaamoraSpacing.md),
                        padding: const EdgeInsetsDirectional.only(
                          bottom: MaamoraSpacing.xl,
                        ),
                        itemBuilder: (context, index) {
                          final g = groups[index];
                          return _GroupOrderCard(
                            imageUrl: g.productImageUrl ?? '',
                            title: g.productName,
                            membersCount: g.membersCount,
                            membersTotal: g.seatsTotal,
                            statut: g.status.name,
                            progressRatio: g.progressRatio,
                            isConfirmed: g.commissionAssigned,
                            prixGroupe: g.pricePerPerson,
                            originalPrice: g.pricePerPerson,
                            onTap: () {
                              // TODO: Add new flow for order details if needed
                              MaamoraToast.info(
                                context,
                                context.tr('groups_order_soon'),
                              );
                            },
                            onInvite: () {
                              // TODO: Implement direct share logic
                              MaamoraToast.info(
                                context,
                                context.tr('groups_share_soon'),
                              );
                            },
                          );
                        },
                      ),
                    );
                  },
                  loading: () => const AppSkeletonList(count: 4),
                  error: (err, _) => Center(
                    child: MaamoraErrorState(
                      title: context.tr('groups_failed'),
                      onRetry: () =>
                          ref.read(myGroupsProvider.notifier).refresh(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GroupOrderCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final int membersCount;
  final int membersTotal;
  final String statut;
  final double progressRatio;
  final bool isConfirmed;
  final double? prixGroupe;
  final double originalPrice;
  final VoidCallback onTap;
  final VoidCallback onInvite;

  const _GroupOrderCard({
    required this.imageUrl,
    required this.title,
    required this.membersCount,
    required this.membersTotal,
    required this.statut,
    required this.progressRatio,
    required this.isConfirmed,
    required this.originalPrice,
    this.prixGroupe,
    required this.onTap,
    required this.onInvite,
  });

  @override
  Widget build(BuildContext context) {
    return MaamoraTappable(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _surfaceContainerLowest,
          borderRadius: MaamoraRadius.cardSmR,
          border: Border.all(color: _outlineVariant),
          boxShadow: MaamoraShadows.soft,
        ),
        child: Row(
          children: [
            // Product image small
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 64,
                height: 64,
                color: MaamoraColors.creamIntense,
                child: imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        cacheWidth: 192,
                        excludeFromSemantics: true,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(
                              Icons.image_not_supported_outlined,
                              size: 24,
                              color: _outlineVariant,
                            ),
                      )
                    : const Icon(
                        Icons.image_not_supported_outlined,
                        size: 24,
                        color: _outlineVariant,
                      ),
              ),
            ),
            const SizedBox(width: MaamoraSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.cairo(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: _onBackground,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.people_alt_outlined,
                        size: 14,
                        color: _onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          context.tr(
                            'groups_filled',
                            args: {'a': membersCount, 'b': membersTotal},
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.cairo(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: _onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ThinProgress(value: progressRatio, height: 6),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Status badge: colour + icon + label (never colour alone).
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isConfirmed
                    ? MaamoraColors.successSoft
                    : MaamoraColors.surfaceLow,
                borderRadius: BorderRadius.circular(MaamoraRadius.chip),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isConfirmed
                        ? Icons.check_circle_rounded
                        : Icons.schedule_rounded,
                    size: 12,
                    color: isConfirmed
                        ? MaamoraColors.successOn
                        : MaamoraColors.textPrimary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    isConfirmed
                        ? context.tr('groups_confirmed')
                        : context.tr('groups_pending'),
                    style: GoogleFonts.cairo(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isConfirmed
                          ? MaamoraColors.successOn
                          : MaamoraColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
