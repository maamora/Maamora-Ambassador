import 'package:flutter/material.dart';
import '../../../shared/widgets/shared_app_bar.dart';
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
import '../../../shared/widgets/design_kit.dart';
import '../../../design_system/design_system.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../core/l10n/locale_provider.dart';

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
      backgroundColor: MaamoraColors.scaffold,
      appBar: SharedAppBar(
        pageTitle: context.tr('profile_title'),
        profileEnabled: false,
      ),
      body: profileAsync.when(
        loading: () => const SingleChildScrollView(
          padding: EdgeInsets.all(MaamoraSpacing.screen),
          child: Column(
            children: [
              MaamoraSkeletonHero(height: 160),
              SizedBox(height: MaamoraSpacing.lg),
              MaamoraSkeletonList(count: 3),
            ],
          ),
        ),
        error: (err, _) => Padding(
          padding: const EdgeInsets.all(MaamoraSpacing.screen),
          child: Center(
            child: MaamoraErrorState(
              subtitle: context.tr('common_error_sub'),
              onRetry: () => ref.invalidate(profileProvider),
            ),
          ),
        ),
        data: (ambassador) {
          if (ambassador == null) {
            return Center(child: Text(context.tr('profile_not_found')));
          }
          final link = 'maamora.ma/join/${ambassador.referralSlug}';

          // Pull-to-refresh: profile + wallet (the stats row uses both).
          return RefreshIndicator(
            color: MaamoraColors.primary,
            onRefresh: () async {
              ref.invalidate(walletProvider);
              ref.invalidate(profileProvider);
              await ref.read(profileProvider.future);
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // ── Header ────────────────────────────────────────────────────────

                // ── Body ──────────────────────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 40),
                    child: Column(
                      children: [
                        // ── Avatar + name + location ─────────────────────────────
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                            20,
                            24,
                            20,
                            24,
                          ),
                          child: Column(
                            children: [
                              Stack(
                                children: [
                                  Container(
                                    width: 96,
                                    height: 96,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: MaamoraColors.surface,
                                        width: 4,
                                      ),
                                      boxShadow: MaamoraShadows.raised,
                                      color: AppColors.outlineVariant,
                                    ),
                                    child: const CircleAvatar(
                                      radius: 44,
                                      backgroundColor: AppColors.outlineVariant,
                                      child: Icon(
                                        Icons.person_outline,
                                        size: 48,
                                        color: AppColors.onSurfaceVariant,
                                      ),
                                    ),
                                  ),
                                  PositionedDirectional(
                                    bottom: 0,
                                    end: 0,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: LevelBadge.colorFor(
                                          ambassador.level,
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: MaamoraColors.surface,
                                          width: 2,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            LevelBadge.iconFor(
                                              ambassador.level,
                                            ),
                                            color: MaamoraColors.onPrimary,
                                            size: 14,
                                          ),
                                          const SizedBox(width: 3),
                                          Text(
                                            ambassador.level.trLabel(context),
                                            style: GoogleFonts.cairo(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                              color: MaamoraColors.onPrimary,
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
                                style: GoogleFonts.cairo(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.onSurface,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.location_on_outlined,
                                    size: 16,
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    ambassador.city.isEmpty
                                        ? context.tr('profile_unknown_city')
                                        : ambassador.city,
                                    style: GoogleFonts.cairo(
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
                              color: MaamoraColors.surface,
                              borderRadius: MaamoraRadius.cardSmR,
                              border: Border.all(color: MaamoraColors.border),
                              boxShadow: MaamoraShadows.soft,
                            ),
                            child: IntrinsicHeight(
                              child: Row(
                                children: [
                                  Expanded(
                                    child: _buildStatItem(
                                      '${ambassador.totalValidatedMembers}',
                                      context.tr('profile_orders'),
                                    ),
                                  ),
                                  VerticalDivider(
                                    width: 1,
                                    thickness: 1,
                                    color: AppColors.outlineVariant.withValues(
                                      alpha: 0.6,
                                    ),
                                  ),
                                  Expanded(
                                    child: _buildStatItem(
                                      '-',
                                      context.tr('profile_city_rank'),
                                    ),
                                  ),
                                  VerticalDivider(
                                    width: 1,
                                    thickness: 1,
                                    color: AppColors.outlineVariant.withValues(
                                      alpha: 0.6,
                                    ),
                                  ),
                                  Expanded(
                                    child: walletAsync.maybeWhen(
                                      data: (w) => _buildStatItem(
                                        w.balance.toStringAsFixed(0),
                                        context.tr('profile_dh_total'),
                                      ),
                                      orElse: () => _buildStatItem(
                                        '-',
                                        context.tr('profile_dh_total'),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // ── Account Settings ───────────────────────────────────────
                        _buildSectionHeader(context.tr('profile_settings')),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Container(
                            decoration: BoxDecoration(
                              color: MaamoraColors.surface,
                              borderRadius: MaamoraRadius.cardSmR,
                              border: Border.all(color: MaamoraColors.border),
                              boxShadow: MaamoraShadows.soft,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: Column(
                                children: [
                                  // My Link
                                  _buildMyLinkRow(link),
                                  const Divider(
                                    height: 1,
                                    color: AppColors.outlineVariant,
                                  ),
                                  // Payout Method
                                  _buildSettingRow(
                                    icon: Icons.account_balance_wallet_outlined,
                                    iconBg: AppColors.outlineVariant.withValues(
                                      alpha: 0.6,
                                    ),
                                    iconColor: AppColors.onSurface,
                                    title: context.tr('profile_payout'),
                                    onTap: () => PayoutMethodBottomSheet.show(
                                      context: context,
                                      ambassador: ambassador,
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        ConstrainedBox(
                                          constraints: const BoxConstraints(
                                            maxWidth: 140,
                                          ),
                                          child: Text(
                                            ambassador.payoutMethod == 'bank'
                                                ? (ambassador.payoutBankRib
                                                          ?.split(' - ')
                                                          .first ??
                                                      context.tr(
                                                        'profile_payout_bank',
                                                      ))
                                                : (ambassador.payoutMethod ==
                                                          'cash_pickup'
                                                      ? (ambassador
                                                                .payoutCashPoint
                                                                ?.split(' - ')
                                                                .first ??
                                                            context.tr(
                                                              'profile_payout_cash',
                                                            ))
                                                      : context.tr(
                                                          'profile_configure',
                                                        )),
                                            style: GoogleFonts.cairo(
                                              fontSize: 13,
                                              fontWeight:
                                                  ambassador.payoutMethod !=
                                                      null
                                                  ? FontWeight.w600
                                                  : FontWeight.w400,
                                              color:
                                                  ambassador.payoutMethod !=
                                                      null
                                                  ? AppColors.primary
                                                  : AppColors.onSurfaceVariant,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        const Icon(
                                          Icons.chevron_right_rounded,
                                          color: AppColors.onSurfaceVariant,
                                          size: 20,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Divider(
                                    height: 1,
                                    color: AppColors.outlineVariant,
                                  ),
                                  // ID Status
                                  _buildSettingRow(
                                    icon: Icons.badge_rounded,
                                    iconBg: AppColors.outlineVariant.withValues(
                                      alpha: 0.6,
                                    ),
                                    iconColor: AppColors.onSurface,
                                    title: context.tr('profile_id_status'),
                                    trailing: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: MaamoraColors.successSoft,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            MaamoraIcons.checkFilled,
                                            size: 14,
                                            color: MaamoraColors.successOn,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            context.tr('profile_verified'),
                                            style: GoogleFonts.cairo(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: MaamoraColors.successOn,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const Divider(
                                    height: 1,
                                    color: AppColors.outlineVariant,
                                  ),
                                  // Language
                                  _buildSettingRow(
                                    icon: Icons.language_rounded,
                                    iconBg: AppColors.outlineVariant.withValues(
                                      alpha: 0.6,
                                    ),
                                    iconColor: AppColors.onSurface,
                                    title: context.tr('profile_language'),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          ref
                                                      .watch(localeProvider)
                                                      .languageCode ==
                                                  'ar'
                                              ? 'العربية'
                                              : 'Français',
                                          style: GoogleFonts.cairo(
                                            fontSize: 13,
                                            color: AppColors.onSurfaceVariant,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        const Icon(
                                          Icons.chevron_right_rounded,
                                          color: AppColors.onSurfaceVariant,
                                          size: 20,
                                        ),
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
                        _buildSectionHeader(
                          context.tr('profile_section_program'),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Container(
                            decoration: BoxDecoration(
                              color: MaamoraColors.surface,
                              borderRadius: MaamoraRadius.cardSmR,
                              border: Border.all(color: MaamoraColors.border),
                              boxShadow: MaamoraShadows.soft,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: _buildSettingRow(
                                icon: Icons.workspace_premium_outlined,
                                iconBg: AppColors.primaryContainer.withValues(
                                  alpha: 0.12,
                                ),
                                iconColor: AppColors.primaryContainer,
                                title: context.tr('profile_rules'),
                                trailing: const Icon(
                                  Icons.chevron_right_rounded,
                                  color: AppColors.onSurfaceVariant,
                                  size: 20,
                                ),
                                onTap: () => context.push(AppRoutes.rules),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // ── Support ────────────────────────────────────────────────
                        _buildSectionHeader(
                          context.tr('profile_section_support'),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Container(
                            decoration: BoxDecoration(
                              color: MaamoraColors.surface,
                              borderRadius: MaamoraRadius.cardSmR,
                              border: Border.all(color: MaamoraColors.border),
                              boxShadow: MaamoraShadows.soft,
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
                          child: InkWell(
                            borderRadius: MaamoraRadius.inputR,
                            onTap: () async {
                              final confirmed = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: Text(ctx.tr('profile_logout')),
                                  content: Text(
                                    ctx.tr('profile_logout_confirm'),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(ctx).pop(false),
                                      child: Text(ctx.tr('common_cancel')),
                                    ),
                                    TextButton(
                                      style: TextButton.styleFrom(
                                        foregroundColor: MaamoraColors.danger,
                                      ),
                                      onPressed: () =>
                                          Navigator.of(ctx).pop(true),
                                      child: Text(ctx.tr('profile_logout')),
                                    ),
                                  ],
                                ),
                              );
                              if (confirmed != true || !context.mounted) return;
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
                                if (context.mounted) {
                                  MaamoraToast.error(
                                    context,
                                    context.tr('profile_logout_failed'),
                                  );
                                }
                              }
                            },
                            child: Container(
                              constraints: const BoxConstraints(minHeight: 48),
                              padding: const EdgeInsets.symmetric(
                                vertical: MaamoraSpacing.md,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.logout_rounded,
                                    color: AppColors.error,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    context.tr('profile_logout'),
                                    style: GoogleFonts.cairo(
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
            ),
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
            style: GoogleFonts.cairo(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryContainer,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.cairo(
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
        alignment: AlignmentDirectional.centerStart,
        child: Text(
          title.toUpperCase(),
          style: GoogleFonts.cairo(
            fontSize: 12,
            fontWeight: FontWeight.w700,
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
                  child: Icon(
                    Icons.link,
                    color: AppColors.primaryContainer,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr('profile_my_link'),
                        style: GoogleFonts.cairo(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onSurface,
                        ),
                      ),
                      Text(
                        link,
                        style: GoogleFonts.cairo(
                          fontSize: 13,
                          color: AppColors.onSurfaceVariant,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                AnimatedOpacity(
                  opacity: _copied ? 0.0 : 0.5,
                  duration: const Duration(milliseconds: 200),
                  child: const Icon(
                    Icons.content_copy_rounded,
                    color: AppColors.onSurfaceVariant,
                    size: 20,
                  ),
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
                    const Icon(
                      Icons.check_circle_rounded,
                      color: MaamoraColors.onPrimary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      context.tr('profile_copied'),
                      style: GoogleFonts.cairo(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: MaamoraColors.onPrimary,
                      ),
                    ),
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
              child: Text(
                title,
                style: GoogleFonts.cairo(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
              ),
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
                color: MaamoraColors.successSoft,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  MaamoraIcons.whatsapp,
                  color: MaamoraColors.success,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.tr('profile_whatsapp'),
                    style: GoogleFonts.cairo(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: MaamoraColors.textPrimary,
                    ),
                  ),
                  Text(
                    context.tr('profile_fast'),
                    style: GoogleFonts.cairo(
                      fontSize: 13,
                      color: MaamoraColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              MaamoraIcons.arrowForward,
              color: MaamoraColors.textFaint,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
