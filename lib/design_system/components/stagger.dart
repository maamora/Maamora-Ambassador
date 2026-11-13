import 'package:flutter/material.dart';

import '../maamora_tokens.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// STAGGER — cascade entrance for lists & screen sections (80–120ms steps).
/// Fade + slide (transform/opacity only → 60fps safe).
///
///   MaamoraStagger(children: [...])
///   MaamoraStagger(children: [...], crossSlide: true)
/// ─────────────────────────────────────────────────────────────────────────────

class MaamoraStagger extends StatelessWidget {
  const MaamoraStagger({
    super.key,
    required this.children,
    this.step = MaamoraDurations.staggerStep,
    this.firstDelay = Duration.zero,
    this.crossSlide = false,
    this.slideDistance = 18.0,
    this.scrollable = true,
    this.padding,
  });

  final List<Widget> children;
  final Duration step;
  final Duration firstDelay;
  final bool crossSlide;
  final double slideDistance;
  final bool scrollable;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final widgets = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      final delay = firstDelay + step * i;
      widgets.add(_StaggerItem(
        delay: delay,
        index: i,
        crossSlide: crossSlide,
        slideDistance: slideDistance,
        child: children[i],
      ));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: widgets,
    );
  }
}

class _StaggerItem extends StatefulWidget {
  const _StaggerItem({
    required this.delay,
    required this.index,
    required this.crossSlide,
    required this.slideDistance,
    required this.child,
  });

  final Duration delay;
  final int index;
  final bool crossSlide;
  final double slideDistance;
  final Widget child;

  @override
  State<_StaggerItem> createState() => _StaggerItemState();
}

class _StaggerItemState extends State<_StaggerItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
    value: 0,
  );

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(widget.delay).then((_) {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, child) {
        final t = Curves.easeOutCubic.transform(_c.value);
        return Opacity(
          opacity: t,
          child: FractionalTranslation(
            translation: Offset(
              widget.crossSlide ? (1 - t) * widget.slideDistance / 100 : 0,
              (1 - t) * widget.slideDistance / 100,
            ),
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}
