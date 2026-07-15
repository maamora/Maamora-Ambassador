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
    const Color surfaceContainerLowest = Color(0xFFFFFFFF);
    const Color primaryContainer = Color(0xFFFB7701);
    const Color onSurfaceVariant = Color(0xFF584236);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(
              icon: Icons.home_filled,
              label: 'Home',
              isActive: currentIndex == 0,
              onTap: () => onTap(0),
              primaryContainer: primaryContainer,
              surfaceContainerLowest: surfaceContainerLowest,
              onSurfaceVariant: onSurfaceVariant,
            ),
            _buildNavItem(
              icon: Icons.people_outline,
              label: 'Groups',
              isActive: currentIndex == 1,
              onTap: () => onTap(1),
              primaryContainer: primaryContainer,
              surfaceContainerLowest: surfaceContainerLowest,
              onSurfaceVariant: onSurfaceVariant,
            ),
            _buildNavItem(
              icon: Icons.emoji_events_outlined,
              label: 'Leaderboard',
              isActive: currentIndex == 2,
              onTap: () => onTap(2),
              primaryContainer: primaryContainer,
              surfaceContainerLowest: surfaceContainerLowest,
              onSurfaceVariant: onSurfaceVariant,
            ),
            _buildNavItem(
              icon: Icons.shopping_bag_outlined,
              label: 'Products',
              isActive: currentIndex == 3,
              onTap: () => onTap(3),
              primaryContainer: primaryContainer,
              surfaceContainerLowest: surfaceContainerLowest,
              onSurfaceVariant: onSurfaceVariant,
            ),
            _buildNavItem(
              icon: Icons.person_outline,
              label: 'Profile',
              isActive: currentIndex == 4,
              onTap: () => onTap(4),
              primaryContainer: primaryContainer,
              surfaceContainerLowest: surfaceContainerLowest,
              onSurfaceVariant: onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
    required Color primaryContainer,
    required Color surfaceContainerLowest,
    required Color onSurfaceVariant,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: isActive
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: primaryContainer,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: surfaceContainerLowest, size: 24),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: GoogleFonts.inter(
                      color: surfaceContainerLowest,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: onSurfaceVariant, size: 24),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: GoogleFonts.inter(
                      color: onSurfaceVariant,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
