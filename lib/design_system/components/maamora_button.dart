import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';

import '../maamora_tokens.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// MAAMORA BUTTON — every CTA of the app.
///
/// • press scale 0.96 (spring), light haptic feedback, distinct pressed state
/// • morphs into a loading spinner instead of swapping text
/// • optional gradient / icon slots; same 54px height app-wide
/// ─────────────────────────────────────────────────────────────────────────────

enum MaamoraButtonVariant { filled, outlined, dark, ghost, whatsapp, danger }

class MaamoraButton extends StatefulWidget {
  const MaamoraButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.leadingIcon,
    this.trailingIcon,
    this.variant = MaamoraButtonVariant.filled,
    this.gradient,
    this.expanded = true,
    this.height = 54,
    this.fontSize = 15,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final MaamoraButtonVariant variant;
  final List<Color>? gradient;
  final bool expanded;
  final double height;
  final double fontSize;

  @override
  State<MaamoraButton> createState() => _MaamoraButtonState();
}

class _MaamoraButtonState extends State<MaamoraButton> {
  bool _pressed = false;

  BoxDecoration _decoration() {
    switch (widget.variant) {
      case MaamoraButtonVariant.filled:
        if (widget.gradient != null) {
          return BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: widget.gradient!,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: MaamoraShadows.glow(widget.gradient![1]),
          );
        }
        return BoxDecoration(
          color: MaamoraColors.primary,
          borderRadius: BorderRadius.circular(16),
          boxShadow: MaamoraShadows.glow(MaamoraColors.primary, 0.26),
        );
      case MaamoraButtonVariant.outlined:
        return BoxDecoration(
          color: MaamoraColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: MaamoraColors.borderStrong),
        );
      case MaamoraButtonVariant.dark:
        return BoxDecoration(
          color: MaamoraColors.textPrimary,
          borderRadius: BorderRadius.circular(16),
          boxShadow: MaamoraShadows.glow(MaamoraColors.textPrimary, 0.30),
        );
      case MaamoraButtonVariant.ghost:
        return BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        );
      case MaamoraButtonVariant.whatsapp:
        return BoxDecoration(
          color: const Color(0xFF25D366),
          borderRadius: BorderRadius.circular(16),
          boxShadow: MaamoraShadows.glow(const Color(0xFF25D366), 0.30),
        );
      case MaamoraButtonVariant.danger:
        return BoxDecoration(
          color: MaamoraColors.danger,
          borderRadius: BorderRadius.circular(16),
          boxShadow: MaamoraShadows.glow(MaamoraColors.danger, 0.26),
        );
    }
  }

  Color get _fg {
    switch (widget.variant) {
      case MaamoraButtonVariant.outlined:
        return MaamoraColors.textPrimary;
      case MaamoraButtonVariant.ghost:
        return MaamoraColors.primary;
      default:
        return Colors.white;
    }
  }

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  Widget _content() {
    if (widget.isLoading) {
      return SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(
          strokeWidth: 2.4,
          valueColor: AlwaysStoppedAnimation(_fg == MaamoraColors.textPrimary
              ? MaamoraColors.primary
              : _fg),
        ),
      );
    }
    final fg = _fg;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.leadingIcon != null) ...[
          Icon(widget.leadingIcon, color: fg, size: 20),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Text(
            widget.label,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: GoogleFonts.cairo(
              fontSize: widget.fontSize,
              fontWeight: FontWeight.w800,
              color: fg,
            ),
          ),
        ),
        if (widget.trailingIcon != null) ...[
          const SizedBox(width: 8),
          Icon(widget.trailingIcon, color: fg, size: 20),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final disabled = widget.isLoading || widget.onPressed == null;

    return AnimatedScale(
      duration: MaamoraDurations.fast,
      curve: Curves.easeOutBack,
      scale: _pressed && !disabled ? 0.96 : 1.0,
      child: Opacity(
        opacity: widget.onPressed == null && !widget.isLoading ? 0.55 : 1,
        child: IgnorePointer(
          ignoring: disabled,
          child: GestureDetector(
              onTapDown: (_) => _setPressed(true),
              onTapCancel: () => _setPressed(false),
              onTapUp: (_) => _setPressed(false),
              onTap: widget.onPressed == null
                  ? null
                  : () {
                      HapticFeedback.lightImpact();
                      widget.onPressed!();
                    },
              child: Container(
                width: widget.expanded ? double.infinity : null,
                height: widget.height,
                padding: widget.expanded
                    ? null
                    : const EdgeInsets.symmetric(horizontal: 20),
                constraints: widget.expanded
                    ? null
                    : const BoxConstraints(minWidth: 96),
                alignment: Alignment.center,
                decoration: _decoration(),
                child: _content(),
              ),
            ),
          ),
        ),
      );
  }
}
