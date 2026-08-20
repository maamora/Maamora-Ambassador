import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/theme/app_colors.dart';
import '../../../shared/navigation/app_routes.dart';
import '../providers/profile_provider.dart';
import '../../wallet/providers/wallet_provider.dart';
import '../../wallet/widgets/payout_method_bottom_sheet.dart';
import '../../../models/models.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _copied = false;

  void _copyLink(String link) {
    Clipboard.setData(ClipboardData(text: link));
    setState(() => _copied = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(profileProvider);
    final walletAsync = ref.watch(walletProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primaryContainer)),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (ambassador) {
          if (ambassador == null) return const Center(child: Text('Profile not found'));
          final link = 'maamora.ma/join/${ambassador.referralSlug}';
          
          return CustomScrollView(
            slivers: [
          // ── Header ────────────────────────────────────────────────────────
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
              'Profile',
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

          // ── Body ──────────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: Column(
                children: [
                  // ── Avatar + name + location ─────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            Container(
                              width: 96,
                              height: 96,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 4),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 16,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                                color: AppColors.outlineVariant,
                              ),
                              child: const CircleAvatar(
                                radius: 44,
                                backgroundColor: AppColors.outlineVariant,
                                child: Icon(Icons.person_rounded, size: 48, color: AppColors.onSurfaceVariant),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryContainer,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.star_rounded, color: Colors.white, size: 14),
                                    const SizedBox(width: 3),
                                    Text(
                                      ambassador.level.label,
                                      style: GoogleFonts.workSans(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          ambassador.fullName,
                          style: GoogleFonts.beVietnamPro(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: AppColors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.location_on_rounded, size: 16, color: AppColors.onSurfaceVariant),
                            const SizedBox(width: 4),
                            Text(
                              ambassador.city.isEmpty ? 'Unknown City' : ambassador.city,
                              style: GoogleFonts.workSans(
                                fontSize: 14,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // ── Stats card ─────────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.6)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 12,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                        child: IntrinsicHeight(
                          child: Row(
                            children: [
                              Expanded(child: _buildStatItem('${ambassador.totalValidatedMembers}', 'Orders')),
                              VerticalDivider(
                                width: 1,
                                thickness: 1,
                                color: AppColors.outlineVariant.withValues(alpha: 0.6),
                              ),
                              Expanded(child: _buildStatItem('-', 'City Rank')),
                              VerticalDivider(
                                width: 1,
                                thickness: 1,
                                color: AppColors.outlineVariant.withValues(alpha: 0.6),
                              ),
                              Expanded(child: walletAsync.maybeWhen(
                                data: (w) => _buildStatItem(w.balance.toStringAsFixed(0), 'DH Total'),
                                orElse: () => _buildStatItem('-', 'DH Total'),
                              )),
                            ],
                          ),
                        ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ── Account Settings ───────────────────────────────────────
                  _buildSectionHeader('Account Settings'),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.6)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 12,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Column(
                          children: [
                            // My Link
                            _buildMyLinkRow(link),
                            const Divider(height: 1, color: AppColors.outlineVariant),
                            // Payout Method
                            _buildSettingRow(
                              icon: Icons.account_balance_wallet_rounded,
                              iconBg: AppColors.outlineVariant.withValues(alpha: 0.6),
                              iconColor: AppColors.onSurface,
                              title: 'Payout Method',
                              onTap: () => PayoutMethodBottomSheet.show(
                                context: context,
                                ambassador: ambassador,
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ConstrainedBox(
                                    constraints: const BoxConstraints(maxWidth: 140),
                                    child: Text(
                                      ambassador.payoutMethod == 'bank'
                                          ? (ambassador.payoutBankRib?.split(' - ').first ?? 'Virement bancaire')
                                          : (ambassador.payoutMethod == 'cash_pickup'
                                              ? (ambassador.payoutCashPoint?.split(' - ').first ?? 'Mise à dispo')
                                              : 'Configurer'),
                                      style: GoogleFonts.workSans(
                                        fontSize: 13,
                                        fontWeight: ambassador.payoutMethod != null ? FontWeight.w600 : FontWeight.w400,
                                        color: ambassador.payoutMethod != null ? AppColors.primary : AppColors.onSurfaceVariant,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(Icons.chevron_right_rounded, color: AppColors.onSurfaceVariant, size: 20),
                                ],
                              ),
                            ),
                            const Divider(height: 1, color: AppColors.outlineVariant),
                            // ID Status
                            _buildSettingRow(
                              icon: Icons.badge_rounded,
                              iconBg: AppColors.outlineVariant.withValues(alpha: 0.6),
                              iconColor: AppColors.onSurface,
                              title: 'ID Status',
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFDCFCE7),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.verified_rounded, size: 14, color: Color(0xFF166534)),
                                    const SizedBox(width: 4),
                                    Text('Verified', style: GoogleFonts.workSans(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF166534))),
                                  ],
                                ),
                              ),
                            ),
                            const Divider(height: 1, color: AppColors.outlineVariant),
                            // Language
                            _buildSettingRow(
                              icon: Icons.language_rounded,
                              iconBg: AppColors.outlineVariant.withValues(alpha: 0.6),
                              iconColor: AppColors.onSurface,
                              title: 'Language',
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('Français', style: GoogleFonts.workSans(fontSize: 13, color: AppColors.onSurfaceVariant)),
                                  const SizedBox(width: 4),
                                  const Icon(Icons.chevron_right_rounded, color: AppColors.onSurfaceVariant, size: 20),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ── Support ────────────────────────────────────────────────
                  _buildSectionHeader('Programme'),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.6)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 12,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: _buildSettingRow(
                          icon: Icons.workspace_premium_rounded,
                          iconBg: AppColors.primaryContainer.withValues(alpha: 0.12),
                          iconColor: AppColors.primaryContainer,
                          title: 'Ambassador Rules',
                          trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.onSurfaceVariant, size: 20),
                          onTap: () => context.push(AppRoutes.rules),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ── Support ────────────────────────────────────────────────
                  _buildSectionHeader('Support'),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.6)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 12,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: _buildWhatsAppRow(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ── Log Out ────────────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: GestureDetector(
                      onTap: () async {
                        try {
                          if (!kIsWeb) {
                            final googleSignIn = GoogleSignIn();
                            if (await googleSignIn.isSignedIn()) {
                              await googleSignIn.signOut();
                            }
                          }
                          await Supabase.instance.client.auth.signOut();
                          if (context.mounted) {
                            context.go(AppRoutes.login);
                          }
                        } catch (e) {
                          debugPrint('Logout error: $e');
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.logout_rounded, color: AppColors.error, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Log Out',
                              style: GoogleFonts.workSans(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColors.error,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    },
  ),
);
  }

  Widget _buildStatItem(String value, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.beVietnamPro(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryContainer,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.workSans(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title.toUpperCase(),
          style: GoogleFonts.workSans(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  Widget _buildMyLinkRow(String link) {
    return Stack(
      children: [
        InkWell(
          onTap: () => _copyLink(link),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.link_rounded, color: AppColors.primaryContainer, size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('My Link', style: GoogleFonts.workSans(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.onSurface)),
                      Text(link, style: GoogleFonts.workSans(fontSize: 13, color: AppColors.onSurfaceVariant), overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                AnimatedOpacity(
                  opacity: _copied ? 0.0 : 0.5,
                  duration: const Duration(milliseconds: 200),
                  child: const Icon(Icons.content_copy_rounded, color: AppColors.onSurfaceVariant, size: 20),
                ),
              ],
            ),
          ),
        ),
        // "Copied!" overlay
        AnimatedOpacity(
          opacity: _copied ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 200),
          child: IgnorePointer(
            ignoring: !_copied,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(1),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Text('Copied!', style: GoogleFonts.workSans(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingRow({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required Widget trailing,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap ?? () {},
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(title, style: GoogleFonts.workSans(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.onSurface)),
            ),
            trailing,
          ],
        ),
      ),
    );
  }

  Widget _buildWhatsAppRow() {
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF25D366).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: _WhatsAppIcon(),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Help via WhatsApp', style: GoogleFonts.workSans(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.onSurface)),
                  Text('Fastest response', style: GoogleFonts.workSans(fontSize: 13, color: AppColors.onSurfaceVariant)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_rounded, color: AppColors.onSurfaceVariant, size: 20),
          ],
        ),
      ),
    );
  }
}

class _WhatsAppIcon extends StatelessWidget {
  const _WhatsAppIcon();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(20, 20),
      painter: _WhatsAppPainter(),
    );
  }
}

class _WhatsAppPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF25D366)
      ..style = PaintingStyle.fill;

    // Simple WA circle icon
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), size.width / 2, paint);
    final textPainter = TextPainter(
      text: const TextSpan(
        text: '\u{F0002}',
        style: TextStyle(fontSize: 14, color: Colors.white, fontFamily: 'MaterialIcons'),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset((size.width - textPainter.width) / 2, (size.height - textPainter.height) / 2));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
