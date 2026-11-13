import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../design_system/design_system.dart';

/// Bottom bar, Maamora style — icon-only, like the approved reference:
/// • 4 equal tabs (Accueil · Leaders · Partage · Portefeuille), no labels —
///   the page title lives in the SharedAppBar above.
/// • Active tab: a soft orange squircle (`primarySoft`) with the custom
///   filled glyph in full `primary`, with a 1.0 → 1.15 spring + haptics.
/// • Inactive tabs: quiet slate outline icons, no background.
/// Profile is reached from the avatar in the top bar, not from here.
class SharedBottomNavBar extends StatefulWidget {
  const SharedBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final Function(int) onTap;

  @override
  State<SharedBottomNavBar> createState() => _SharedBottomNavBarState();
}

class _SharedBottomNavBarState extends State<SharedBottomNavBar> {
  @override
  void didUpdateWidget(covariant SharedBottomNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentIndex != oldWidget.currentIndex) {
      HapticFeedback.selectionClick();
    }
  }

  void _onTap(int index) {
    if (index == widget.currentIndex) return;
    HapticFeedback.lightImpact();
    widget.onTap(index);
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;

    return SizedBox(
      height: 84 + bottom,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: MaamoraColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: MaamoraColors.shadowInk.withValues(alpha: 0.10),
              blurRadius: 24,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.only(bottom: bottom),
          child: Row(
            children: [
              _tab(0, MaamoraIcons.home, MaamoraFilledGlyph.house),
              _tab(1, MaamoraIcons.board, MaamoraFilledGlyph.trophy),
              _tab(2, MaamoraIcons.share, MaamoraFilledGlyph.share),
              _tab(3, MaamoraIcons.wallet, MaamoraFilledGlyph.wallet),
            ],
          ),
        ),
      ),
    );
  }

  /// Icon-only tab. Active: soft orange squircle + filled orange glyph.
  /// Inactive: quiet slate outline icon on transparent background.
  Widget _tab(int index, IconData icon, MaamoraFilledGlyph glyph) {
    final active = widget.currentIndex == index;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _onTap(index),
        child: Center(
          child: Container(
            width: 58,
            height: 58,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: active ? MaamoraColors.primarySoft : Colors.transparent,
              borderRadius: BorderRadius.circular(18),
            ),
            child: _AnimatedNavIcon(
              outline: icon,
              glyph: glyph,
              active: active,
            ),
          ),
        ),
      ),
    );
  }
}

/// Crossfades Lucide 200 outline → filled custom glyph and springs up
/// on active, so the selected tab morphs instead of abruptly switching.
class _AnimatedNavIcon extends StatelessWidget {
  const _AnimatedNavIcon({
    required this.outline,
    required this.glyph,
    required this.active,
  });

  final IconData outline;
  final MaamoraFilledGlyph glyph;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: active ? 1 : 0),
      duration: MaamoraDurations.normal * 2,
      curve: Curves.easeOutBack,
      builder: (context, t, child) {
        final tc = t.clamp(0.0, 1.0);
        return Transform.scale(
          scale: 1.0 + 0.15 * tc,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                outline,
                size: 26,
                color: Color.lerp(
                  MaamoraColors.textSecondary,
                  MaamoraColors.primary,
                  tc,
                ),
              ),
              Opacity(
                opacity: tc,
                child: child,
              ),
            ],
          ),
        );
      },
      child: MaamoraFilledIcon(
        glyph: glyph,
        color: MaamoraColors.primary,
        size: 26,
      ),
    );
  }
}
