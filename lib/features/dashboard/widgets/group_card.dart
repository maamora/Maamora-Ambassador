import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/app_strings.dart';
import '../../../models/models.dart';
import '../../../shared/design/app_tokens.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/widgets/design_kit.dart';
import '../../../shared/widgets/icon_tile.dart';
import '../../../shared/widgets/pressable_scale.dart';
import '../../groups/providers/my_groups_provider.dart';
import 'add_members_sheet.dart';

/// One group deal: product, status, seats progress, price and earnings.
class GroupCard extends ConsumerStatefulWidget {
  const GroupCard({
    super.key,
    required this.group,
    required this.commissionRate,
  });

  final DealGroup group;
  final double commissionRate;

  @override
  ConsumerState<GroupCard> createState() => _GroupCardState();
}

class _GroupCardState extends ConsumerState<GroupCard> {
  bool _isAdding = false;

  DealGroup get _group => widget.group;
  bool get _isFull => _group.membersCount >= _group.seatsTotal;

  Future<void> _handleAddMember() async {
    if (_isFull) return;

    final count = await showAddMembersSheet(
      context,
      groupName: _group.productName,
      available: _group.seatsTotal - _group.membersCount,
    );
    if (count == null || count <= 0 || !mounted) return;

    // Read everything that needs `context` BEFORE the async gap: this card is
    // replaced while the list refreshes, so `context` may be gone afterwards.
    final messenger = ScaffoldMessenger.of(context);
    final successText = count == 1
        ? context.tr('dash_added_one')
        : context.tr('dash_added_many', args: {'n': count});
    final failText = context.tr('dash_add_failed');

    setState(() => _isAdding = true);
    try {
      await ref
          .read(myGroupsProvider.notifier)
          .addParticipant(_group.id, count: count);
      messenger.showSnackBar(
        SnackBar(content: Text(successText), backgroundColor: AppColors.success),
      );
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(failText)));
    } finally {
      if (mounted) setState(() => _isAdding = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.text;
    final group = _group;
    final full = _isFull;
    final ratio = group.seatsTotal > 0
        ? (group.membersCount / group.seatsTotal).clamp(0.0, 1.0).toDouble()
        : 0.0;
    final estimated =
        (group.pricePerPerson * group.seatsTotal * widget.commissionRate)
            .toInt();
    final unit = context.tr('dash_unit_dh');
    final accent = full ? AppColors.success : AppColors.primary;
    final accentText = full ? AppColors.success : AppColors.primaryText;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.card,
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: AppShadows.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const IconTile(icon: Icons.shopping_bag_outlined),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group.productName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: t.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700, height: 1.25),
                    ),
                    const SizedBox(height: AppSpacing.sm - 2),
                    _StatusChip(
                      label: context.tr(full ? 'dash_closed' : 'dash_active'),
                      color: accent,
                      textColor: accentText,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              if (full)
                Text(
                  '+$estimated $unit',
                  style: t.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.success,
                  ),
                )
              else
                _AddMemberButton(
                  loading: _isAdding,
                  tooltip: context.tr('dash_add_members'),
                  onPressed: _handleAddMember,
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  context.tr('dash_seats_filled', args: {
                    'a': group.membersCount,
                    'b': group.seatsTotal,
                  }),
                  style: t.bodySmall?.copyWith(color: AppColors.textMuted),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                '${(ratio * 100).round()}%',
                style: t.bodySmall
                    ?.copyWith(fontWeight: FontWeight.w800, color: accentText),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ThinProgress(value: ratio, height: 8, color: accent),
          if (!full) ...[
            const SizedBox(height: AppSpacing.md),
            const Divider(height: 1, color: AppColors.cardBorder),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: _Metric(
                    label: context.tr('dash_product_price'),
                    value: '${group.pricePerPerson.toInt()} $unit',
                  ),
                ),
                Expanded(
                  child: _Metric(
                    label: context.tr('dash_est_earnings'),
                    value: '$estimated $unit',
                    color: AppColors.primaryText,
                    alignEnd: true,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.color,
    required this.textColor,
  });

  final String label;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: context.text.labelSmall
                ?.copyWith(fontWeight: FontWeight.w700, color: textColor),
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.label,
    required this.value,
    this.color,
    this.alignEnd = false,
  });

  final String label;
  final String value;
  final Color? color;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    final t = context.text;
    return Column(
      crossAxisAlignment:
          alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: t.labelSmall?.copyWith(color: AppColors.textMuted),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: t.titleSmall?.copyWith(fontWeight: FontWeight.w800, color: color),
        ),
      ],
    );
  }
}

class _AddMemberButton extends StatelessWidget {
  const _AddMemberButton({
    required this.loading,
    required this.tooltip,
    required this.onPressed,
  });

  final bool loading;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: PressableScale(
        enabled: !loading,
        child: Material(
          color: AppColors.primary.withValues(alpha: 0.10),
          shape: CircleBorder(
            side: BorderSide(color: AppColors.primary.withValues(alpha: 0.4)),
          ),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: loading ? null : onPressed,
            // 48x48: minimum comfortable touch target.
            child: SizedBox(
              width: 48,
              height: 48,
              child: Center(
                child: loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(
                        Icons.group_add_outlined,
                        size: AppIconSize.md,
                        color: AppColors.primaryText,
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
