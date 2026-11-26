import 'package:flutter/material.dart';

import '../../../design_system/components/maamora_arc_gauge.dart';

import '../../../core/l10n/app_strings.dart';
import '../../../models/models.dart';
import '../../../shared/design/app_tokens.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/widgets/design_kit.dart';
import '../models/level_progress.dart';

/// "Next level" card: tier name, days left and an animated progress bar.
class LevelProgressCard extends StatelessWidget {
  const LevelProgressCard({super.key, required this.ambassador});

  final Ambassador ambassador;

  @override
  Widget build(BuildContext context) {
    final progress = LevelProgress.from(ambassador);
    final t = context.text;

    return SectionCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr(
                        progress.isMax
                            ? 'dash_current_level'
                            : 'dash_next_level',
                      ),
                      style: t.labelMedium?.copyWith(
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      context.tr(progress.nextTierKey),
                      style: t.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              if (!progress.isMax) ...[
                const SizedBox(width: AppSpacing.md),
                _DaysChip(days: progress.daysLeft),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          // The brand arc fills toward the next level; the count sits in
          // its bowl — the one hero moment of the home screen.
          Center(
            child: MaamoraArcGauge(
              value: progress.ratio,
              width: 220,
              semanticLabel: context.tr('dash_level_progress'),
              center: Text(
                progress.isMax
                    ? '${progress.completed}'
                    : '${progress.completed}/${progress.target}',
                style: t.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  height: 1,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          // Full width so the centred line sits right under the arc.
          SizedBox(
            width: double.infinity,
            child: Text(
              progress.isMax
                  ? context.tr('dash_max_rank')
                  : context.tr(
                      'dash_orders_needed',
                      args: {'n': progress.remaining},
                    ),
              textAlign: TextAlign.center,
              style: t.bodyMedium?.copyWith(
                color: AppColors.textMuted,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DaysChip extends StatelessWidget {
  const _DaysChip({required this.days});

  final int days;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.timer_outlined,
            size: AppIconSize.sm,
            color: AppColors.primaryText,
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            context.tr('dash_days_left', args: {'n': days}),
            style: context.text.labelMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.primaryText,
            ),
          ),
        ],
      ),
    );
  }
}
