import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../shared/widgets/points_card.dart';

// ==========================================
// Colors based on the user's design system
// ==========================================
const Color _primary = Color(0xFF9A4600);
const Color _primaryContainer = Color(0xFFFB7701);
const Color _onPrimaryContainer = Color(0xFF592600);
const Color _surface = Color(0xFFFFF8F5);
const Color _surfaceContainerLowest = Color(0xFFFFFFFF);
const Color _surfaceContainerHigh = Color(0xFFFBE3D8);
const Color _surfaceVariant = Color(0xFFF6DED2);
const Color _onBackground = Color(0xFF251912);
const Color _onSurfaceVariant = Color(0xFF584236);
const Color _outlineVariant = Color(0xFFE0C0B0);
const Color _tertiaryContainer = Color(0xFF00A4FC);

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _surface,
      body: const SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PointsCard(),
              SizedBox(height: 32),
              _ActiveGroupsSection(),
              SizedBox(height: 32),
              _RecentActivitySection(),
              SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

}



class _ActiveGroupsSection extends StatelessWidget {
  const _ActiveGroupsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'My Active Groups',
          style: GoogleFonts.plusJakartaSans(
            color: _onBackground,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 135, // Increased from 120 to provide more breathing room and avoid overflow
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: 2, // Dummy count for UI showcase
            separatorBuilder: (context, index) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              return const _GroupCard();
            },
          ),
        ),
      ],
    );
  }
}

class _GroupCard extends StatelessWidget {
  const _GroupCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: 80,
              height: 80,
              color: _surfaceVariant,
              // Utilisation d'un conteneur coloré avec icône pour simuler l'image du produit
              child: const Icon(Icons.image_outlined, color: _outlineVariant, size: 32),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min, // Added to prevent overflow
              children: [
                Text(
                  'Summer Hydration\nCampaign',
                  style: GoogleFonts.inter(
                    color: _onBackground,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  'Ends in 3 days',
                  style: GoogleFonts.inter(
                    color: _onSurfaceVariant,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _primaryContainer,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'CONFIRMED',
                    style: GoogleFonts.inter(
                      color: _surfaceContainerLowest,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentActivitySection extends StatelessWidget {
  const _RecentActivitySection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Activity',
              style: GoogleFonts.plusJakartaSans(
                color: _onBackground,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                foregroundColor: _primaryContainer,
              ),
              child: Text(
                'View All',
                style: GoogleFonts.inter(
                  color: _primaryContainer,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const _ActivityTile(
          title: 'Order #4892',
          subtitle: '2 items • Today, 10:42 AM',
          points: '+450 pts',
          icon: Icons.shopping_bag_outlined,
          iconColor: _primaryContainer,
          iconBackgroundColor: _surface,
        ),
        const SizedBox(height: 12),
        const _ActivityTile(
          title: 'Joined Group',
          subtitle: 'Fitness Essentials • Yesterday',
          icon: Icons.people_outline,
          iconColor: _onBackground,
          iconBackgroundColor: _surfaceVariant,
        ),
      ],
    );
  }
}

class _ActivityTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? points;
  final IconData icon;
  final Color iconColor;
  final Color iconBackgroundColor;

  const _ActivityTile({
    required this.title,
    required this.subtitle,
    this.points,
    required this.icon,
    required this.iconColor,
    required this.iconBackgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconBackgroundColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    color: _onBackground,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    color: _onSurfaceVariant,
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          if (points != null) ...[
            const SizedBox(width: 8),
            Text(
              points!,
              style: GoogleFonts.inter(
                color: _primaryContainer,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ]
        ],
      ),
    );
  }
}
