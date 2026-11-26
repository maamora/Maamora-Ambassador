import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/l10n/app_strings.dart';
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

    // Material 3 navigation bar, Maamora style: icon + label for every
    // destination (icon-only tabs were hard to read), the selected one sits
    // on a soft orange pill that grows in when tapped.
    return DecoratedBox(
      decoration: BoxDecoration(
        color: MaamoraColors.surface,
        border: const Border(top: BorderSide(color: MaamoraColors.border)),
        boxShadow: [
          BoxShadow(
            color: MaamoraColors.shadowInk.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.only(bottom: bottom),
        child: SizedBox(
          height: 68,
          child: Row(
            children: [
              _tab(
                0,
                MaamoraIcons.home,
                MaamoraFilledGlyph.house,
                context.tr('nav_home'),
              ),
              _tab(
                1,
                MaamoraIcons.board,
                MaamoraFilledGlyph.trophy,
                context.tr('nav_board'),
              ),
              _tab(
                2,
                MaamoraIcons.share,
                MaamoraFilledGlyph.share,
                context.tr('nav_share'),
              ),
              _tab(
                3,
                MaamoraIcons.wallet,
                MaamoraFilledGlyph.wallet,
                context.tr('nav_wallet'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tab(
    int index,
    IconData icon,
    MaamoraFilledGlyph glyph,
    String label,
  ) {
    final active = widget.currentIndex == index;
    final reduced = MaamoraMotion.reduced(context);
    final duration = reduced ? Duration.zero : MaamoraDurations.normal;
    return Expanded(
      child: Semantics(
        button: true,
        selected: active,
        label: label,
        excludeSemantics: true,
        onTap: () => _onTap(index),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _onTap(index),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Pill indicator: grows from the icon's width when selected.
              AnimatedContainer(
                duration: duration,
                curve: MaamoraMotion.standard,
                width: active ? 60 : 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: active
                      ? MaamoraColors.primarySoft
                      : MaamoraColors.primarySoft.withValues(alpha: 0),
                  borderRadius: BorderRadius.circular(MaamoraRadius.chip),
                ),
                child: _AnimatedNavIcon(
                  outline: icon,
                  glyph: glyph,
                  active: active,
                ),
              ),
              const SizedBox(height: MaamoraSpacing.xs),
              AnimatedDefaultTextStyle(
                duration: duration,
                style: GoogleFonts.cairo(
                  fontSize: 12,
                  height: 1.2,
                  fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                  color: active
                      ? MaamoraColors.primaryText
                      : MaamoraColors.textSecondary,
                ),
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
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
      duration: MaamoraMotion.reduced(context)
          ? Duration.zero
          : MaamoraDurations.normal * 2,
      curve: Curves.easeOutBack,
      builder: (context, t, child) {
        final tc = t.clamp(0.0, 1.0);
        return Transform.scale(
          scale: 1.0 + 0.08 * tc,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                outline,
                size: 22,
                color: Color.lerp(
                  MaamoraColors.textSecondary,
                  MaamoraColors.primary,
                  tc,
                ),
              ),
              Opacity(opacity: tc, child: child),
            ],
          ),
        );
      },
      child: MaamoraFilledIcon(
        glyph: glyph,
        color: MaamoraColors.primary,
        size: 22,
      ),
    );
  }
}
