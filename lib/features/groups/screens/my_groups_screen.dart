import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/navigation/app_routes.dart';

// Colors matched with dashboard
const Color _primaryContainer = Color(0xFFFB7701);
const Color _surface = Color(0xFFFFF8F5);
const Color _surfaceContainerLowest = Color(0xFFFFFFFF);
const Color _onBackground = Color(0xFF251912);
const Color _onSurfaceVariant = Color(0xFF584236);
const Color _outlineVariant = Color(0xFFE0C0B0);

class MyGroupsScreen extends StatelessWidget {
  const MyGroupsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Text(
                'My Groups',
                style: GoogleFonts.plusJakartaSans(
                  color: _onBackground,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView(
                  children: [
                    _GroupOrderCard(
                      imageUrl: 'https://images.unsplash.com/photo-1546868871-7041f2a55e12?auto=format&fit=crop&w=400&q=80', // placeholder watch
                      title: 'Pro Runner Watch',
                      orderNumber: '#89204',
                      membersCount: 5,
                      membersTotal: 5,
                      pointsEarned: 2500,
                      status: 'CONFIRMED',
                      onTap: () => context.push(AppRoutes.orderDetails),
                    ),
                    const SizedBox(height: 16),
                    _GroupOrderCard(
                      imageUrl: 'https://images.unsplash.com/photo-1602143407151-7111542de6e8?auto=format&fit=crop&w=400&q=80', // placeholder bottle
                      title: 'Hydration Flex Bottle',
                      orderNumber: '#89215',
                      membersCount: 4,
                      membersTotal: 5,
                      pointsEarned: 0,
                      status: 'PENDING',
                      needsMore: 1,
                      onTap: () => context.push(AppRoutes.orderDetails),
                    ),
                    const SizedBox(height: 16),
                    _GroupOrderCard(
                      imageUrl: 'https://images.unsplash.com/photo-1590658268037-6bf12165a8df?auto=format&fit=crop&w=400&q=80', // placeholder earbuds
                      title: 'Aero Buds Elite',
                      orderNumber: '#89198',
                      membersCount: 10,
                      membersTotal: 10,
                      pointsEarned: 5000,
                      status: 'CONFIRMED',
                      onTap: () => context.push(AppRoutes.orderDetails),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GroupOrderCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String orderNumber;
  final int membersCount;
  final int membersTotal;
  final int pointsEarned;
  final String status;
  final int? needsMore;
  final VoidCallback onTap;

  const _GroupOrderCard({
    required this.imageUrl,
    required this.title,
    required this.orderNumber,
    required this.membersCount,
    required this.membersTotal,
    required this.pointsEarned,
    required this.status,
    this.needsMore,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isConfirmed = status == 'CONFIRMED';

    return GestureDetector(
      onTap: onTap,
      child: Container(
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
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                height: 140,
                width: double.infinity,
                color: const Color(0xFFF6DED2), // fallback
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    color: _onBackground,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isConfirmed ? _primaryContainer : const Color(0xFFFBE3D8),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isConfirmed ? Icons.check_circle : Icons.circle,
                        color: isConfirmed ? Colors.white : _primaryContainer,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        status,
                        style: GoogleFonts.inter(
                          color: isConfirmed ? Colors.white : _onBackground,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  'Group Order $orderNumber',
                  style: GoogleFonts.inter(
                    color: _onSurfaceVariant,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: _outlineVariant, height: 1),
            const SizedBox(height: 16),
            if (isConfirmed)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.people_outline, color: _onSurfaceVariant, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        '$membersCount/$membersTotal members',
                        style: GoogleFonts.inter(
                          color: _onSurfaceVariant,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'POINTS EARNED',
                        style: GoogleFonts.inter(
                          color: _onSurfaceVariant,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '+${pointsEarned.toString().replaceAll(RegExp(r'\B(?=(\d{3})+(?!\d))'), ',')}',
                        style: GoogleFonts.plusJakartaSans(
                          color: _primaryContainer,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ],
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: membersCount / membersTotal,
                            backgroundColor: const Color(0xFFFBE3D8),
                            color: _primaryContainer,
                            minHeight: 8,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.people_outline, color: _onSurfaceVariant, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            '$membersCount/$membersTotal members',
                            style: GoogleFonts.inter(
                              color: _onSurfaceVariant,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'Needs $needsMore more',
                        style: GoogleFonts.inter(
                          color: _onSurfaceVariant,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
