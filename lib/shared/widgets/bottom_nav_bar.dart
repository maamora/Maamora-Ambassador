import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/l10n/app_strings.dart';
import '../theme/app_colors.dart';

/// Bottom bar in the Maamora design: rounded top, outline icons, orange active
/// state and a raised orange circle in the middle (Share).
/// 4 tabs, matching the wireframe exactly: Home · Board · Share · Wallet.
/// Profile is reached from the avatar in the top bar, not from here.
/// Indexes: 0 Home, 1 Board, 2 Share (center), 3 Wallet.
class SharedBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const SharedBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;

    return SizedBox(
      height: 86 + bottom,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 68 + bottom,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.07),
                    blurRadius: 20,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: bottom,
            height: 86,
            child: Row(
              children: [
                _tab(context, 0, Icons.home_outlined, 'nav_home'),
                _tab(context, 1, Icons.emoji_events_outlined, 'nav_board'),
                _centerTab(context, 2, Icons.share_outlined, 'nav_share'),
                _tab(context, 3, Icons.account_balance_wallet_outlined,
                    'nav_wallet'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(BuildContext context, String key, bool active) => Text(
        context.tr(key),
        style: GoogleFonts.cairo(
          fontSize: 11,
          fontWeight: active ? FontWeight.w800 : FontWeight.w600,
          color: active ? AppColors.primary : AppColors.onSurfaceVariant,
        ),
      );

  Widget _tab(BuildContext context, int index, IconData icon, String key) {
    final active = currentIndex == index;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onTap(index),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 24,
                  color: active ? AppColors.primary : AppColors.onSurfaceVariant,
                ),
                const SizedBox(height: 4),
                _label(context, key, active),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _centerTab(
      BuildContext context, int index, IconData icon, String key) {
    final active = currentIndex == index;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onTap(index),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.4),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Icon(icon, color: Colors.white, size: 26),
                ),
                const SizedBox(height: 4),
                _label(context, key, active),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
