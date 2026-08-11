import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
    const Color surface = Color(0xFFFFF8F5);
    const Color primaryContainer = Color(0xFFFB7701);
    const Color onSurfaceVariant = Color(0xFF584236);

    return Container(
      decoration: BoxDecoration(
        color: surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 16,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _NavItem(
                icon: Icons.home_rounded,
                label: 'Home',
                isActive: currentIndex == 0,
                activeColor: primaryContainer,
                inactiveColor: onSurfaceVariant,
                onTap: () => onTap(0),
              ),
              _NavItem(
                icon: Icons.bar_chart_rounded,
                label: 'Board',
                isActive: currentIndex == 1,
                activeColor: primaryContainer,
                inactiveColor: onSurfaceVariant,
                onTap: () => onTap(1),
              ),
              _NavItem(
                icon: Icons.share_rounded,
                label: 'Share',
                isActive: currentIndex == 2,
                activeColor: primaryContainer,
                inactiveColor: onSurfaceVariant,
                onTap: () => onTap(2),
              ),
              _NavItem(
                icon: Icons.account_balance_wallet_outlined,
                label: 'Wallet',
                isActive: currentIndex == 3,
                activeColor: primaryContainer,
                inactiveColor: onSurfaceVariant,
                onTap: () => onTap(3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final Color activeColor;
  final Color inactiveColor;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.activeColor,
    required this.inactiveColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 72,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? activeColor : inactiveColor,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                color: isActive ? activeColor : inactiveColor,
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
