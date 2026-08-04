import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/theme/app_colors.dart';

class RulesScreen extends StatelessWidget {
  const RulesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── Header ─────────────────────────────────────────────────────────
          SliverAppBar(
            pinned: true,
            backgroundColor: const Color(0xFFFFF8F5).withValues(alpha: 0.95),
            elevation: 0,
            surfaceTintColor: Colors.transparent,
            shadowColor: Colors.black.withValues(alpha: 0.06),
            forceElevated: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
              color: AppColors.onSurface,
              onPressed: () => context.pop(),
            ),
            title: Text(
              'Rules',
              style: GoogleFonts.beVietnamPro(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.outlineVariant,
                  child: const Icon(Icons.person_rounded, size: 18, color: AppColors.onSurfaceVariant),
                ),
              ),
            ],
          ),

          // ── Body ───────────────────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 32, 20, 40),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // ── Intro ────────────────────────────────────────────────────
                Text(
                  'Ambassador Tiers',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.beVietnamPro(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Climb the ranks to unlock higher commissions and exclusive perks.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.workSans(
                    fontSize: 15,
                    color: AppColors.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 28),

                // ── Starter tier ─────────────────────────────────────────────
                _buildTierCard(
                  icon: Icons.check_circle_outline_rounded,
                  iconColor: AppColors.onSurfaceVariant,
                  iconBg: const Color(0xFFf6ded2),
                  name: 'Starter',
                  range: '0 - 5 orders/mo',
                  commission: '4%',
                  isActive: false,
                  isLocked: false,
                ),
                const SizedBox(height: 12),

                // ── Bronze tier (CURRENT) ─────────────────────────────────────
                _buildCurrentTierCard(),
                const SizedBox(height: 12),

                // ── Silver tier (locked) ──────────────────────────────────────
                _buildTierCard(
                  icon: Icons.diamond_rounded,
                  iconColor: const Color(0xFF596374),
                  iconBg: const Color(0xFFd6e0f5),
                  name: 'Silver',
                  range: '21 - 50 orders/mo',
                  commission: '8%',
                  isActive: false,
                  isLocked: true,
                ),
                const SizedBox(height: 12),

                // ── Gold tier (locked) ────────────────────────────────────────
                _buildTierCard(
                  icon: Icons.stars_rounded,
                  iconColor: const Color(0xFFB8860B),
                  iconBg: const Color(0xFFFFD700).withValues(alpha: 0.2),
                  name: 'Gold',
                  range: '50+ orders/mo',
                  commission: '10%',
                  isActive: false,
                  isLocked: true,
                ),
                const SizedBox(height: 28),

                // ── Good to know ──────────────────────────────────────────────
                _buildGoodToKnow(),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTierCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String name,
    required String range,
    required String commission,
    required bool isActive,
    required bool isLocked,
  }) {
    return Opacity(
      opacity: isLocked ? 0.75 : 1.0,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFf0ede4)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF555F70).withValues(alpha: 0.04),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(shape: BoxShape.circle, color: iconBg),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.beVietnamPro(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface,
                    ),
                  ),
                  Text(
                    range,
                    style: GoogleFonts.workSans(
                      fontSize: 14,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  commission,
                  style: GoogleFonts.beVietnamPro(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: AppColors.onSurface,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  'COMMISSION',
                  style: GoogleFonts.workSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentTierCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryContainer, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryContainer.withValues(alpha: 0.08),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Decorative circle in top-right
          Positioned(
            right: -24,
            top: -24,
            child: Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: AppColors.primaryContainer.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),
          // "Current Level" ribbon
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: const BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(12)),
              ),
              child: Text(
                'Current Level',
                style: GoogleFonts.workSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 36, 16, 16),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primaryContainer,
                      ),
                      child: const Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Bronze',
                            style: GoogleFonts.beVietnamPro(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryContainer,
                            ),
                          ),
                          Text(
                            '6 - 20 orders/mo',
                            style: GoogleFonts.workSans(fontSize: 14, color: AppColors.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '6%',
                          style: GoogleFonts.beVietnamPro(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryContainer,
                            letterSpacing: -0.5,
                          ),
                        ),
                        Text(
                          'COMMISSION',
                          style: GoogleFonts.workSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.8,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Progress to next tier
                Divider(height: 1, color: AppColors.outlineVariant.withValues(alpha: 0.3)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Next tier: Silver',
                      style: GoogleFonts.workSans(fontSize: 13, color: AppColors.onSurfaceVariant),
                    ),
                    Text(
                      '14 orders to go',
                      style: GoogleFonts.workSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryContainer,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: 0.30,
                    minHeight: 8,
                    backgroundColor: const Color(0xFFf6ded2),
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryContainer),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoodToKnow() {
    final rules = [
      'Commissions are calculated and paid out on the 1st of every month.',
      'Levels are based on successful, delivered orders only.',
      'If you miss the order threshold for your current tier, you\'ll be given a one-month grace period before dropping down.',
      'Returns and cancellations are deducted from your monthly total.',
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEADF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.outlineVariant,
          style: BorderStyle.solid,
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_rounded, color: AppColors.primaryContainer, size: 22),
              const SizedBox(width: 8),
              Text(
                'Good to know',
                style: GoogleFonts.beVietnamPro(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...rules.map((rule) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 6, right: 10),
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: AppColors.onSurfaceVariant,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        rule,
                        style: GoogleFonts.workSans(
                          fontSize: 14,
                          color: AppColors.onSurfaceVariant,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
