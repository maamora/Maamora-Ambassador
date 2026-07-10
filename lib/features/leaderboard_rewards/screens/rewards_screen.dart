import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/services/mock_data_service.dart';
import '../../../models/models.dart';
import '../../../shared/navigation/app_routes.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/widgets/tier_badge.dart';

// Dev 4 - Rewards: recreated from the Maamora Stitch "Rewards & Earnings"
// screen, adapted to the points-based model we actually have.
// - Uses MockDataService.mockCurrentAmbassador + mockOrders.
// - IMPORTANT (brief feature #6): per-order MAD payout amounts are NOT
//   confirmed with the founder yet. We only show `pointsEarned` (real,
//   defined data) and the order's own `amount` (what the customer paid,
//   not a payout figure) — no invented DH reward numbers.

final NumberFormat _pointsFormat = NumberFormat.decimalPattern('en_US');
final NumberFormat _madFormat = NumberFormat.decimalPattern('en_US');
final DateFormat _dateFormat = DateFormat('EEEE, MMM d', 'en_US');

class RewardsScreen extends StatelessWidget {
  const RewardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ambassador = MockDataService.mockCurrentAmbassador;
    final tier = TierInfo.fromPoints(ambassador.points);
    final nextTier = tier.next;
    final orders = MockDataService.mockOrders;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _Header(
              onBack: () => context.canPop()
                  ? context.pop()
                  : context.go(AppRoutes.dashboard),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                children: [
                  _TierProgressCard(
                    ambassador: ambassador,
                    tier: tier,
                    nextTier: nextTier,
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () => context.push(AppRoutes.leaderboard),
                      icon: const Icon(Icons.emoji_events, size: 18),
                      label: const Text('View leaderboard'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primaryContainer,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Past earnings', style: AppTheme.headlineSm),
                      TextButton(
                        // TODO(Dev 4): hook up once a full history screen
                        // exists — static for now, same as other screens.
                        onPressed: () {},
                        child: const Text('View all'),
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: Text(
                      'Payout amount per order is still being confirmed '
                      'with the founder — showing points earned only.',
                      style: AppTheme.bodySm,
                    ),
                  ),
                  if (orders.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Text(
                        'No orders yet — invite a neighbor to get started.',
                        style: AppTheme.bodyMd,
                      ),
                    )
                  else
                    for (final order in orders) _OrderRow(order: order),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => context.push(AppRoutes.share),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryContainer,
                    foregroundColor: AppColors.onPrimaryContainer,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Invite a neighbor',
                        style: AppTheme.headlineSm.copyWith(
                          color: AppColors.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.arrow_forward,
                        size: 18,
                        color: AppColors.onPrimaryContainer,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back, color: AppColors.onBackground),
          ),
          const Expanded(
            child: Text(
              'Rewards',
              textAlign: TextAlign.center,
              style: AppTheme.headlineLg,
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_horiz, color: AppColors.onBackground),
          ),
        ],
      ),
    );
  }
}

/// Current tier + progress toward the next tier.
class _TierProgressCard extends StatelessWidget {
  const _TierProgressCard({
    required this.ambassador,
    required this.tier,
    required this.nextTier,
  });

  final Ambassador ambassador;
  final Tier tier;
  final Tier? nextTier;

  @override
  Widget build(BuildContext context) {
    double progress = 1.0;
    String caption = "You've reached the top tier — nice work!";

    if (nextTier != null) {
      final span = nextTier!.minPoints - tier.minPoints;
      final into = ambassador.points - tier.minPoints;
      progress = span == 0 ? 1.0 : (into / span).clamp(0.0, 1.0).toDouble();
      final remaining = (nextTier!.minPoints - ambassador.points).clamp(
        0,
        nextTier!.minPoints,
      );
      caption = '$remaining pts to ${nextTier!.label}';
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TierBadge(tier: tier, large: true),
              Text(
                '${_pointsFormat.format(ambassador.points)} pts',
                style: AppTheme.headlineLg,
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: AppColors.surfaceContainerLow,
              valueColor: const AlwaysStoppedAnimation(
                AppColors.primaryContainer,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            caption,
            style: AppTheme.bodySm.copyWith(color: AppColors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _OrderRow extends StatelessWidget {
  const _OrderRow({required this.order});

  final ReferralOrder order;

  @override
  Widget build(BuildContext context) {
    final isConfirmed = order.status == OrderStatus.confirmed;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.secondaryContainer,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.shopping_bag_outlined,
              size: 20,
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.productName,
                  style: AppTheme.headlineSm.copyWith(fontSize: 15),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${_dateFormat.format(order.date)} · '
                  '${_madFormat.format(order.amount)} MAD'
                  '${isConfirmed ? '' : ' · ${order.status.label}'}',
                  style: AppTheme.bodySm,
                ),
              ],
            ),
          ),
          Text(
            '+${order.pointsEarned} pts',
            style: AppTheme.labelMd.copyWith(color: AppColors.success),
          ),
        ],
      ),
    );
  }
}
