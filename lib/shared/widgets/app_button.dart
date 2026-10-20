import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

/// Maamora buttons: orange (filled), white with border (outlined), navy (dark).
/// Rounded 16, soft colored shadow, built-in loading state.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.trailingIcon,
    this.leadingIcon,
    this.variant = AppButtonVariant.filled,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? trailingIcon;
  final IconData? leadingIcon;
  final AppButtonVariant variant;

  @override
  Widget build(BuildContext context) {
    final disabled = isLoading || onPressed == null;
    final solid = variant != AppButtonVariant.outlined;
    final bg =
        variant == AppButtonVariant.dark ? AppColors.secondary : AppColors.primary;
    final fg = solid ? Colors.white : AppColors.secondary;
    final radius = BorderRadius.circular(16);

    final content = isLoading
        ? SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2.5, color: fg),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (leadingIcon != null) ...[
                Icon(leadingIcon, color: fg, size: 24),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.cairo(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: fg,
                  ),
                ),
              ),
              if (trailingIcon != null) ...[
                const SizedBox(width: 8),
                Icon(trailingIcon, color: fg, size: 20),
              ],
            ],
          );

    return Opacity(
      opacity: (onPressed == null && !isLoading) ? 0.5 : 1,
      child: Container(
        width: double.infinity,
        height: 54,
        decoration: BoxDecoration(
          color: solid ? bg : Colors.white,
          borderRadius: radius,
          border: solid ? null : Border.all(color: AppColors.outlineVariant),
          boxShadow: solid
              ? [
                  BoxShadow(
                    color: bg.withValues(alpha: 0.28),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: radius,
            onTap: disabled ? null : onPressed,
            child: Center(child: content),
          ),
        ),
      ),
    );
  }
}

enum AppButtonVariant { filled, outlined, dark }
