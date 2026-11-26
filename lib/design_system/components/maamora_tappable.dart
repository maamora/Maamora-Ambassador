import 'package:flutter/material.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// TAPPABLES — accessible tap targets.
///
/// • [MaamoraIconAction] : icon-only action (copy, refresh, info, close…).
///   Gives it a name for screen readers, a tooltip on long-press and a
///   48×48dp minimum touch area, without changing the icon's look.
/// • [MaamoraTappable] : a card / chip / row that reacts to a tap. Announced
///   as a button whose label is the text it contains (merged), with an
///   optional selected state.
/// ─────────────────────────────────────────────────────────────────────────────

/// Minimum touch target (Material / WCAG 2.5.5).
const double kMaamoraMinTapTarget = 48;

class MaamoraIconAction extends StatelessWidget {
  const MaamoraIconAction({
    super.key,
    required this.label,
    required this.onPressed,
    required this.child,
    this.showTooltip = true,
  });

  /// Spoken by screen readers; also the long-press tooltip.
  final String label;
  final VoidCallback? onPressed;

  /// The visual (icon, or icon inside its decorated pill).
  final Widget child;

  /// Set to false when [child] already carries its own [Tooltip].
  final bool showTooltip;

  @override
  Widget build(BuildContext context) {
    Widget visual = child;
    if (showTooltip) visual = Tooltip(message: label, child: visual);
    return Semantics(
      button: true,
      enabled: onPressed != null,
      label: label,
      excludeSemantics: true,
      onTap: onPressed,
      child: InkResponse(
        onTap: onPressed,
        radius: kMaamoraMinTapTarget / 2,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minWidth: kMaamoraMinTapTarget,
            minHeight: kMaamoraMinTapTarget,
          ),
          child: Center(widthFactor: 1, heightFactor: 1, child: visual),
        ),
      ),
    );
  }
}

class MaamoraTappable extends StatelessWidget {
  const MaamoraTappable({
    super.key,
    required this.onTap,
    required this.child,
    this.selected,
    this.label,
    this.behavior = HitTestBehavior.opaque,
  });

  final VoidCallback? onTap;
  final Widget child;

  /// For segmented chips / filters: announced as selected or not.
  final bool? selected;

  /// Extra label, merged with the text found in [child].
  final String? label;
  final HitTestBehavior behavior;

  @override
  Widget build(BuildContext context) {
    return MergeSemantics(
      child: Semantics(
        button: true,
        enabled: onTap != null,
        selected: selected,
        label: label,
        child: GestureDetector(behavior: behavior, onTap: onTap, child: child),
      ),
    );
  }
}
