import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_strings.dart';
import '../../../core/services/ambassador_state_provider.dart';
import '../../../models/models.dart';
import '../../../shared/design/app_motion.dart';
import '../../../shared/design/app_tokens.dart';
import '../../../shared/navigation/app_routes.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/design_kit.dart';
import '../../../shared/widgets/responsive.dart';
import '../../groups/providers/my_groups_provider.dart';
import '../providers/dashboard_providers.dart';
import '../widgets/dashboard_skeleton.dart';
import '../widgets/group_card.dart';
import '../widgets/level_progress_card.dart';

/// Home tab of the Ambassador app: earnings, level progress and active groups.
///
/// Business logic is unchanged (same providers, same calls). What changed:
/// layout hierarchy (money first), reusable components, staggered entrance
/// animations, skeleton loading, pull-to-refresh and a two-column layout on
/// wide screens.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  Future<void> _refresh(WidgetRef ref) async {
    ref.invalidate(walletBalanceProvider);
    await Future.wait<void>([
      ref.read(myGroupsProvider.notifier).refresh(),
      ref
          .read(walletBalanceProvider.future)
          .then<void>((_) {}, onError: (_) {}),
    ]);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(ambassadorStateProvider);
    final ambassador = state.ambassador;

    final Widget body;
    if (state.isLoading) {
      body = const DashboardSkeleton(key: ValueKey('loading'));
    } else if (ambassador == null) {
      body = _DashboardError(
        key: const ValueKey('error'),
        message: state.errorMessage,
        onRetry: () => ref.invalidate(ambassadorStateProvider),
      );
    } else {
      body = _DashboardContent(
        key: const ValueKey('content'),
        ambassador: ambassador,
        onRefresh: () => _refresh(ref),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        // Respect the user's font size, but keep the layout from breaking.
        child: MediaQuery.withClampedTextScaling(
          minScaleFactor: 1.0,
          maxScaleFactor: 1.3,
          child: AnimatedSwitcher(
            duration: AppMotion.medium,
            switchInCurve: Curves.easeOut,
            child: body,
          ),
        ),
      ),
    );
  }
}

// ── Content ─────────────────────────────────────────────────────────────────

class _DashboardContent extends ConsumerWidget {
  const _DashboardContent({
    super.key,
    required this.ambassador,
    required this.onRefresh,
  });

  final Ambassador ambassador;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupsAsync = ref.watch(myGroupsProvider);

    // Each block gets an entrance index: the stagger is what makes the page
    // feel alive instead of popping in all at once.
    final greeting = _Greeting(ambassador: ambassador).enter(context, index: 0);
    final hero = const _EarningsHero().enter(context, index: 1);
    final stats = _StatsRow(
      ambassador: ambassador,
      groupsCount: groupsAsync.value?.length ?? 0,
    ).enter(context, index: 2);
    final level = LevelProgressCard(ambassador: ambassador)
        .enter(context, index: 3);
    final cta = AppButton(
      label: context.tr('dash_new_group'),
      leadingIcon: Icons.add_rounded,
      onPressed: () => context.push(AppRoutes.createGroup),
    ).enter(context, index: 4);
    final groups = _GroupsSection(
      groupsAsync: groupsAsync,
      commissionRate: ambassador.level.commissionRate,
    ).enter(context, index: 5);

    const gap = SizedBox(height: AppSpacing.lg);

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: onRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ResponsiveBody(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Tablets / landscape: two columns. Phones: one column.
                if (constraints.maxWidth >= 720) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 5,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [greeting, gap, hero, gap, stats, gap, level],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xl),
                      Expanded(
                        flex: 6,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            cta,
                            const SizedBox(height: AppSpacing.xl),
                            groups,
                          ],
                        ),
                      ),
                    ],
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    greeting,
                    gap,
                    hero,
                    gap,
                    stats,
                    gap,
                    level,
                    gap,
                    cta,
                    const SizedBox(height: AppSpacing.xl),
                    groups,
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

// ── Header ──────────────────────────────────────────────────────────────────

class _Greeting extends StatelessWidget {
  const _Greeting({required this.ambassador});

  final Ambassador ambassador;

  @override
  Widget build(BuildContext context) {
    final t = context.text;
    final name = ambassador.fullName.trim().split(' ').first;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.tr('dash_greeting', args: {'name': name}),
                style: t.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w800, height: 1.2),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                context.tr('dash_subtitle'),
                style: t.bodySmall
                    ?.copyWith(color: AppColors.textMuted, height: 1.4),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        LevelBadge(level: ambassador.level),
      ],
    );
  }
}

// ── Earnings hero (wallet balance) ──────────────────────────────────────────

class _EarningsHero extends ConsumerWidget {
  const _EarningsHero();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balance = ref.watch(walletBalanceProvider);
    final label = context.tr('dash_total_earned');
    final unit = context.tr('dash_unit_dh');
    const icon = Icon(
      Icons.account_balance_wallet_outlined,
      color: Colors.white,
      size: AppIconSize.lg,
    );

    return balance.when(
      data: (value) => GradientHeroCard(
        label: label,
        amount: value,
        unit: unit,
        caption: context.tr('dash_paid_friday'),
        trailing: icon,
      ),
      loading: () => const AppSkeleton(
        width: double.infinity,
        height: 132,
        radius: AppRadius.xl,
      ),
      error: (_, _) => GradientHeroCard(
        label: label,
        value: '—',
        caption: context.tr('dash_balance_error'),
        trailing: icon,
      ),
    );
  }
}

// ── Stats ───────────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.ambassador, required this.groupsCount});

  final Ambassador ambassador;
  final int groupsCount;

  @override
  Widget build(BuildContext context) {
    // IntrinsicHeight: the row lives inside the dashboard's vertical
    // SingleChildScrollView (unbounded), where CrossAxisAlignment.stretch
    // alone would hand children an infinite height.
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: StatBox(
              value: '$groupsCount',
              label: context.tr('dash_groups'),
              icon: Icons.groups_outlined,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: StatBox(
              value: '${ambassador.totalValidatedMembers}',
              label: context.tr('dash_referrals'),
              icon: Icons.link,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: StatBox(
              value: ambassador.level.label,
              label: context.tr('dash_level'),
              icon: Icons.military_tech_outlined,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Groups ──────────────────────────────────────────────────────────────────

class _GroupsSection extends ConsumerWidget {
  const _GroupsSection({
    required this.groupsAsync,
    required this.commissionRate,
  });

  final AsyncValue<List<DealGroup>> groupsAsync;
  final double commissionRate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(
          title: context.tr('dash_my_groups'),
          action: context.tr('dash_see_all'),
          onActionTap: () => context.push(AppRoutes.myGroups),
        ),
        const SizedBox(height: AppSpacing.sm),
        groupsAsync.when(
          data: (groups) {
            final active = groups
                .where((g) => g.status != DealGroupStatus.cancelled)
                .take(2)
                .toList();
            if (active.isEmpty) {
              return EmptyState(
                icon: Icons.groups_outlined,
                title: context.tr('dash_no_groups'),
                subtitle: context.tr('dash_no_groups_sub'),
              );
            }
            return Column(
              children: [
                for (var i = 0; i < active.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: GroupCard(
                      key: ValueKey(active[i].id),
                      group: active[i],
                      commissionRate: commissionRate,
                    ).enter(context, index: i),
                  ),
              ],
            );
          },
          loading: () => const AppSkeletonList(count: 2),
          error: (_, _) => _InlineError(
            message: context.tr('dash_load_groups_error'),
            onRetry: () => ref.read(myGroupsProvider.notifier).refresh(),
          ),
        ),
      ],
    );
  }
}

// ── Errors ──────────────────────────────────────────────────────────────────

class _InlineError extends StatelessWidget {
  const _InlineError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Row(
        children: [
          const Icon(Icons.error_outline,
              size: AppIconSize.lg, color: AppColors.error),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: Text(message, style: context.text.bodyMedium)),
          TextButton(
            onPressed: onRetry,
            child: Text(context.tr('common_retry')),
          ),
        ],
      ),
    );
  }
}

class _DashboardError extends StatelessWidget {
  const _DashboardError({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String? message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_outlined,
                size: 48, color: AppColors.textMuted),
            const SizedBox(height: AppSpacing.lg),
            Text(
              message ?? context.tr('dash_error_title'),
              textAlign: TextAlign.center,
              style:
                  context.text.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              width: 220,
              child: AppButton(
                label: context.tr('common_retry'),
                variant: AppButtonVariant.outlined,
                onPressed: onRetry,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
