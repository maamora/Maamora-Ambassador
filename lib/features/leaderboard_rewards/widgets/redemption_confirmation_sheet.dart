import 'package:flutter/material.dart';
import '../../../design_system/design_system.dart';
import '../../../core/l10n/app_strings.dart';

// Dev 4 — Confirm Redemption sheet, opened via showModalBottomSheet from
// rewards_screen.dart. Pure presentation: detail rows + onConfirm are
// passed in by the caller, which owns the real balance.

class RedemptionConfirmationSheet extends StatefulWidget {
  const RedemptionConfirmationSheet({
    super.key,
    required this.pointsLabel,
    required this.method,
    required this.valueLabel,
    required this.destination,
    required this.onConfirm,
  });

  final String pointsLabel;
  final String method;
  final String valueLabel;
  final String destination;

  // Throw on failure (shown via SnackBar); on success the sheet pops `true`.
  final Future<void> Function() onConfirm;

  @override
  State<RedemptionConfirmationSheet> createState() =>
      _RedemptionConfirmationSheetState();
}

class _RedemptionConfirmationSheetState
    extends State<RedemptionConfirmationSheet> {
  bool _isSubmitting = false;

  Future<void> _handleConfirm() async {
    setState(() => _isSubmitting = true);
    try {
      await widget.onConfirm();
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      // Toast (root overlay) is visible above the sheet.
      MaamoraToast.error(
        context,
        context.tr('common_error', args: {'e': e.toString()}),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        decoration: const BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsetsDirectional.fromSTEB(
          20,
          12,
          20,
          20 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 5,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: _outlineVariant,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            Text(
              context.tr('rd_title'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w700,
                color: _onSurface,
              ),
            ),
            const SizedBox(height: MaamoraSpacing.xs),
            Text(
              context.tr('rd_sub'),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: _onSurfaceVariant),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: _surfaceContainerLow,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: _outlineVariant.withValues(alpha: 0.6),
                ),
              ),
              child: Column(
                children: [
                  _DetailRow(
                    icon: Icons.star_outline,
                    label: context.tr('rd_amount'),
                    value: widget.pointsLabel,
                  ),
                  _DetailRow(
                    icon: Icons.account_balance_outlined,
                    label: context.tr('rd_method'),
                    value: widget.method,
                  ),
                  _DetailRow(
                    icon: Icons.payments_outlined,
                    label: context.tr('rd_value'),
                    value: widget.valueLabel,
                    valueColor: MaamoraColors.primaryText,
                    valueBold: true,
                  ),
                  _DetailRow(
                    icon: Icons.account_circle_outlined,
                    label: context.tr('rd_destination'),
                    value: widget.destination,
                    isLast: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: _primaryContainer,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: _isSubmitting ? null : _handleConfirm,
                child: _isSubmitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: MaamoraColors.onPrimary,
                        ),
                      )
                    : Text(
                        context.tr('common_confirm'),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: MaamoraColors.onPrimary,
                        ),
                      ),
              ),
            ),
            TextButton(
              onPressed: _isSubmitting
                  ? null
                  : () => Navigator.of(context).pop(false),
              child: Text(
                context.tr('rd_edit'),
                style: const TextStyle(
                  color: _onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
    this.valueBold = false,
    this.isLast = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  final bool valueBold;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(
                  color: _outlineVariant.withValues(alpha: 0.4),
                ),
              ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              ExcludeSemantics(
                child: Icon(icon, size: 20, color: _onSurfaceVariant),
              ),
              const SizedBox(width: MaamoraSpacing.sm),
              Text(
                label,
                style: const TextStyle(fontSize: 14, color: _onSurface),
              ),
            ],
          ),
          const SizedBox(width: MaamoraSpacing.md),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: valueBold ? FontWeight.w800 : FontWeight.w600,
                fontSize: valueBold ? 17 : 14,
                color: valueColor ?? _onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

const Color _surface = MaamoraColors.surface;
const Color _surfaceContainerLow = MaamoraColors.primarySoft;
const Color _onSurface = MaamoraColors.textPrimary;
const Color _onSurfaceVariant = MaamoraColors.textSecondary;
const Color _outlineVariant = MaamoraColors.border;
const Color _primaryContainer = MaamoraColors.primary;
