import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

import '../maamora_tokens.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// MOTION — navigation transitions built on the official Material motion
/// package (`animations`). One vocabulary for the whole app:
///
/// • Pages pushed on top (profile, groups, admin detail…): shared axis
///   "scaled" — depth says "you went deeper", and it reads the same in
///   French and Arabic (no left/right slide to mirror).
/// • Switching between sibling tabs: fade through.
///
/// Every transition collapses to an instant swap when the OS asks to reduce
/// motion.
/// ─────────────────────────────────────────────────────────────────────────────

/// Theme-level page transition (see `MaamoraTheme.light`).
class MaamoraPageTransitionsBuilder extends PageTransitionsBuilder {
  const MaamoraPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (MaamoraMotion.reduced(context)) return child;
    return SharedAxisTransition(
      animation: animation,
      secondaryAnimation: secondaryAnimation,
      transitionType: SharedAxisTransitionType.scaled,
      fillColor: MaamoraColors.scaffold,
      child: child,
    );
  }
}

/// Tab body that keeps every tab alive (like [IndexedStack], so scroll
/// positions and loaded data survive) and fades the newly selected tab in
/// with the Material "fade through" curve.
class MaamoraFadeThroughIndexedStack extends StatefulWidget {
  const MaamoraFadeThroughIndexedStack({
    super.key,
    required this.index,
    required this.children,
  });

  final int index;
  final List<Widget> children;

  @override
  State<MaamoraFadeThroughIndexedStack> createState() =>
      _MaamoraFadeThroughIndexedStackState();
}

class _MaamoraFadeThroughIndexedStackState
    extends State<MaamoraFadeThroughIndexedStack>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
    value: 1,
  );

  // Fade-through incoming half: content appears after a short beat and
  // scales up from 92% — the outgoing tab simply disappears (it is kept
  // alive offstage by the IndexedStack).
  late final Animation<double> _opacity = CurvedAnimation(
    parent: _c,
    curve: const Interval(0.2, 1, curve: Curves.easeOut),
  );
  late final Animation<double> _scale = Tween<double>(
    begin: 0.92,
    end: 1,
  ).animate(CurvedAnimation(parent: _c, curve: Curves.easeOutCubic));

  @override
  void didUpdateWidget(covariant MaamoraFadeThroughIndexedStack oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.index != widget.index) {
      if (MaamoraMotion.reduced(context)) {
        _c.value = 1;
      } else {
        _c.forward(from: 0);
      }
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: MaamoraColors.scaffold,
      child: FadeTransition(
        opacity: _opacity,
        child: ScaleTransition(
          scale: _scale,
          child: IndexedStack(index: widget.index, children: widget.children),
        ),
      ),
    );
  }
}

/// Switches between pages that are rebuilt anyway (e.g. admin tabs) with
/// the Material fade-through. [pageKey] must change when the page changes.
class MaamoraFadeThroughSwitcher extends StatelessWidget {
  const MaamoraFadeThroughSwitcher({
    super.key,
    required this.pageKey,
    required this.child,
  });

  final Object pageKey;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return PageTransitionSwitcher(
      duration: MaamoraMotion.reduced(context)
          ? Duration.zero
          : const Duration(milliseconds: 300),
      transitionBuilder: (child, primary, secondary) => FadeThroughTransition(
        animation: primary,
        secondaryAnimation: secondary,
        fillColor: MaamoraColors.scaffold,
        child: child,
      ),
      child: KeyedSubtree(key: ValueKey(pageKey), child: child),
    );
  }
}
