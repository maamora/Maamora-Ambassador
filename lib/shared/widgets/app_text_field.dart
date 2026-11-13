import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../../design_system/design_system.dart';

/// App-wide text field: light filled background, rounded corners, leading
/// icon, focus ring in primary color. On focus the border glows orange and
/// the icon turns brand — presentation only, styles upgraded by the DS.
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    required this.label,
    required this.icon,
    this.controller,
    this.obscureText = false,
    this.keyboardType,
    this.suffixIcon,
    this.validator,
    this.autofillHints,
  });

  final String label;
  final IconData icon;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final Iterable<String>? autofillHints;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.only(start: 4, bottom: 8),
          child: Text(widget.label, style: AppTheme.labelMd),
        ),
        // Animated focus glow: shadow only appears while focused (60fps ok —
        // the shadow animates via the implicit controller).
        AnimatedContainer(
          duration: MaamoraDurations.fast,
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(MaamoraRadius.input),
            boxShadow: _focusNode.hasFocus
                ? [
                    BoxShadow(
                      color: MaamoraColors.primary.withValues(alpha: 0.16),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : const [],
          ),
          child: TextFormField(
            controller: widget.controller,
            focusNode: _focusNode,
            obscureText: widget.obscureText,
            keyboardType: widget.keyboardType,
            validator: widget.validator,
            autofillHints: widget.autofillHints,
            style: AppTheme.bodyMd.copyWith(color: AppColors.onSurface),
            decoration: InputDecoration(
              filled: true,
              fillColor: MaamoraColors.surface,
              prefixIcon: AnimatedSwitcher(
                duration: MaamoraDurations.fast,
                child: Icon(
                  widget.icon,
                  key: ValueKey(_focusNode.hasFocus),
                  color: _focusNode.hasFocus
                      ? MaamoraColors.primary
                      : MaamoraColors.textSecondary,
                ),
              ),
              suffixIcon: widget.suffixIcon,
              hintStyle: AppTheme.bodyMd.copyWith(
                color: AppColors.onSurfaceVariant.withValues(alpha: 0.4),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(MaamoraRadius.input),
                borderSide: const BorderSide(color: MaamoraColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(MaamoraRadius.input),
                borderSide: const BorderSide(color: MaamoraColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(MaamoraRadius.input),
                borderSide: const BorderSide(
                  color: MaamoraColors.primary,
                  width: 1.6,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(MaamoraRadius.input),
                borderSide: const BorderSide(color: MaamoraColors.danger),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
