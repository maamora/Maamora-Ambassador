import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../design/app_motion.dart';

/// Micro-interaction: the child shrinks slightly while a finger is on it.
/// Uses a raw pointer [Listener], so it never competes with the child's own
/// tap handling (InkWell, buttons...). Visual feedback only.
class PressableScale extends StatefulWidget {
  const PressableScale({
    super.key,
    required this.child,
    this.enabled = true,
    this.scale = 0.96,
    this.haptic = false,
  });

  final Widget child;
  final bool enabled;
  final double scale;
  final bool haptic;

  @override
  State<PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<PressableScale> {
  bool _pressed = false;

  void _set(bool value) {
    if (_pressed != value && mounted) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final active = widget.enabled && !AppMotion.reduced(context);
    return Listener(
      onPointerDown: (_) {
        if (!active) return;
        if (widget.haptic) HapticFeedback.selectionClick();
        _set(true);
      },
      onPointerUp: (_) => _set(false),
      onPointerCancel: (_) => _set(false),
      child: AnimatedScale(
        scale: _pressed ? widget.scale : 1.0,
        duration: AppMotion.fast,
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}
