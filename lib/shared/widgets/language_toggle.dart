import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/l10n/locale_provider.dart';
import '../../design_system/maamora_tokens.dart';
import '../theme/app_colors.dart';

/// Small AR | FR pill to switch language anywhere in the app.
class LanguageToggle extends ConsumerWidget {
  const LanguageToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(localeProvider).languageCode;

    Widget seg(String label, String code) {
      final active = current == code;
      return Semantics(
        button: true,
        selected: active,
        label: code == 'ar' ? 'العربية' : 'Français',
        excludeSemantics: true,
        child: GestureDetector(
          onTap: () => ref.read(localeProvider.notifier).set(Locale(code)),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: active ? AppColors.secondary : Colors.transparent,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              label,
              style: GoogleFonts.cairo(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: active
                    ? MaamoraColors.onPrimary
                    : AppColors.onSurfaceVariant,
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: MaamoraColors.surface,
        borderRadius: BorderRadius.circular(MaamoraRadius.chip),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [seg('عربي', 'ar'), seg('FR', 'fr')],
      ),
    );
  }
}
