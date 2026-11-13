import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';

import '../maamora_icons.dart';
import '../maamora_tokens.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// MAAMORA TOAST — custom in-app message sliding from the TOP (never the
/// system snackbar). Auto-dismiss after 2.4s, tap to dismiss.
///
///   MaamoraToast.success(context, 'Lien copié !');
///   MaamoraToast.error(context, 'Presse-papiers vide');
/// ─────────────────────────────────────────────────────────────────────────────

enum MaamoraToastKind { success, error, info }

class MaamoraToast {
  MaamoraToast._();

  static OverlayEntry? _current;
  static Timer? _timer;

  static void show(
    BuildContext context,
    String message, {
    String? subtitle,
    IconData? icon,
    MaamoraToastKind kind = MaamoraToastKind.info,
    Duration duration = const Duration(milliseconds: 2400),
  }) {
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return;

    // One toast at a time — replace politely.
    _dismiss();

    final entry = OverlayEntry(
      builder: (context) {
        return _ToastView(
          message: message,
          subtitle: subtitle,
          icon: icon,
          kind: kind,
          onDismiss: _dismiss,
        );
      },
    );
    _current = entry;
    overlay.insert(entry);
    _timer = Timer(duration, _dismiss);
  }

  static void success(BuildContext context, String message,
      {String? subtitle, IconData? icon}) {
    show(context, message,
        subtitle: subtitle,
        icon: icon ?? MaamoraIcons.checkFilled,
        kind: MaamoraToastKind.success);
  }

  static void error(BuildContext context, String message,
      {String? subtitle, IconData? icon}) {
    show(context, message,
        subtitle: subtitle,
        icon: icon ?? MaamoraIcons.close,
        kind: MaamoraToastKind.error);
  }

  static void info(BuildContext context, String message,
      {String? subtitle, IconData? icon}) {
    show(context, message,
        subtitle: subtitle, icon: icon, kind: MaamoraToastKind.info);
  }

  static void _dismiss() {
    _timer?.cancel();
    _timer = null;
    _current?.remove();
    _current = null;
  }
}

class _ToastView extends StatefulWidget {
  const _ToastView({
    required this.message,
    this.subtitle,
    this.icon,
    required this.kind,
    required this.onDismiss,
  });

  final String message;
  final String? subtitle;
  final IconData? icon;
  final MaamoraToastKind kind;
  final VoidCallback onDismiss;

  @override
  State<_ToastView> createState() => _ToastViewState();
}

class _ToastViewState extends State<_ToastView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 320))
        ..forward();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  Color _bg() {
    switch (widget.kind) {
      case MaamoraToastKind.success:
        return MaamoraColors.success;
      case MaamoraToastKind.error:
        return MaamoraColors.danger;
      case MaamoraToastKind.info:
        return MaamoraColors.textPrimary;
    }
  }

  IconData _defaultIcon() {
    switch (widget.kind) {
      case MaamoraToastKind.success:
        return MaamoraIcons.checkFilled;
      case MaamoraToastKind.error:
        return MaamoraIcons.close;
      case MaamoraToastKind.info:
        return MaamoraIcons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = CurvedAnimation(parent: _c, curve: Curves.easeOutBack);
    return Positioned(
      top: MediaQuery.paddingOf(context).top + 12,
      left: 20,
      right: 20,
      child: GestureDetector(
        onTap: dismiss,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(MaamoraRadius.card),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: AnimatedBuilder(
              animation: _c,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, -80 * (1 - t.value)),
                  child: Opacity(
                    opacity: _c.value.clamp(0.0, 1.0),
                    child: Transform.rotate(
                      angle: 0.01 * (1 - t.value),
                      child: child,
                    ),
                  ),
                );
              },
              child: Material(
                color: Colors.transparent,
                child: _buildBody(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: _bg().withValues(alpha: 0.97),
        borderRadius: BorderRadius.circular(MaamoraRadius.card),
        boxShadow: MaamoraShadows.raised,
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: Icon(
              widget.icon ?? _defaultIcon(),
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.message,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (widget.subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    widget.subtitle!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  void dismiss() {
    final c = _c;
    c.reverse().then((_) {
      if (!c.isAnimating) MaamoraToast._dismiss();
    });
  }
}
