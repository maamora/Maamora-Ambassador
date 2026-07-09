import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// App-wide primary CTA button. Filled, rounded, with an optional
/// loading state and trailing icon — matches the design system's
/// "Se connecter" / "Start application" buttons.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.trailingIcon,
    this.variant = AppButtonVariant.filled,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? trailingIcon;
  final AppButtonVariant variant;

  @override
  Widget build(BuildContext context) {
    final isDisabled = isLoading || onPressed == null;
    final child = isLoading
        ? const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: AppColors.onPrimaryContainer,
            ),
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: AppTheme.headlineSm.copyWith(
                  color: variant == AppButtonVariant.filled
                      ? AppColors.onPrimaryContainer
                      : AppColors.onBackground,
                ),
              ),
              if (trailingIcon != null) ...[
                const SizedBox(width: 8),
                Icon(
                  trailingIcon,
                  color: variant == AppButtonVariant.filled
                      ? AppColors.onPrimaryContainer
                      : AppColors.onBackground,
                ),
              ],
            ],
          );

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: variant == AppButtonVariant.filled
          ? FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primaryContainer,
                disabledBackgroundColor: AppColors.primaryContainer.withValues(
                  alpha: 0.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: isDisabled ? null : onPressed,
              child: child,
            )
          : OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.outlineVariant),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: isDisabled ? null : onPressed,
              child: child,
            ),
    );
  }
}

enum AppButtonVariant { filled, outlined }
