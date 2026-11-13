import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/l10n/app_strings.dart';
import '../../../shared/design/app_tokens.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/pressable_scale.dart';

/// Opens the "how many members joined?" sheet. Returns the chosen count, or
/// null if dismissed.
Future<int?> showAddMembersSheet(
  BuildContext context, {
  required String groupName,
  required int available,
}) {
  return showModalBottomSheet<int>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (_) => AddMembersSheet(groupName: groupName, available: available),
  );
}

class AddMembersSheet extends StatefulWidget {
  const AddMembersSheet({
    super.key,
    required this.groupName,
    required this.available,
  });

  final String groupName;
  final int available;

  @override
  State<AddMembersSheet> createState() => _AddMembersSheetState();
}

class _AddMembersSheetState extends State<AddMembersSheet> {
  int _count = 1;
  late final TextEditingController _controller;

  int get _max => widget.available < 1 ? 1 : widget.available;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: '1');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _setCount(int value) {
    final clamped = value.clamp(1, _max).toInt();
    setState(() {
      _count = clamped;
      _controller.text = '$clamped';
      _controller.selection =
          TextSelection.collapsed(offset: _controller.text.length);
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = context.text;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final quick = const [5, 10, 20, 50].where((n) => n <= _max).toList();

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xl,
        0,
        AppSpacing.xl,
        AppSpacing.xl + bottomInset,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            context.tr('dash_sheet_title'),
            style: t.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            widget.groupName,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: t.bodyMedium?.copyWith(color: AppColors.textMuted),
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _StepButton(
                icon: Icons.remove_rounded,
                label: '-1',
                enabled: _count > 1,
                onTap: () => _setCount(_count - 1),
              ),
              const SizedBox(width: AppSpacing.lg),
              SizedBox(
                width: 96,
                child: TextField(
                  controller: _controller,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: t.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                  onChanged: (value) {
                    final parsed = int.tryParse(value);
                    if (parsed != null) {
                      setState(() => _count = parsed.clamp(1, _max).toInt());
                    }
                  },
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              _StepButton(
                icon: Icons.add_rounded,
                label: '+1',
                enabled: _count < _max,
                onTap: () => _setCount(_count + 1),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            context.tr('dash_seats_remaining', args: {'n': _max}),
            textAlign: TextAlign.center,
            style: t.bodySmall?.copyWith(color: AppColors.textMuted),
          ),
          if (quick.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final n in quick)
                  ChoiceChip(
                    label: Text('+$n'),
                    selected: _count == n,
                    showCheckmark: false,
                    selectedColor: AppColors.primary,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.10),
                    side: BorderSide.none,
                    shape: const StadiumBorder(),
                    labelStyle: t.labelLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color:
                          _count == n ? Colors.white : AppColors.primaryText,
                    ),
                    onSelected: (_) => _setCount(n),
                  ),
              ],
            ),
          ],
          const SizedBox(height: AppSpacing.xl),
          AppButton(
            label: _count == 1
                ? context.tr('dash_add_one')
                : context.tr('dash_add_many', args: {'n': _count}),
            leadingIcon: Icons.group_add_outlined,
            onPressed: () => Navigator.of(context).pop(_count),
          ),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({
    required this.icon,
    required this.label,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      enabled: enabled,
      child: Material(
        color: enabled ? AppColors.primary : AppColors.surfaceContainerLow,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: enabled ? onTap : null,
          child: SizedBox(
            width: 52,
            height: 52,
            child: Icon(
              icon,
              semanticLabel: label,
              color: enabled ? Colors.white : AppColors.textMuted,
            ),
          ),
        ),
      ),
    );
  }
}
