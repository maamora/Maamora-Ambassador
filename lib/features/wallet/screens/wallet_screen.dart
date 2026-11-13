import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/wallet_provider.dart';
import '../widgets/payout_method_bottom_sheet.dart';
import '../../profile/providers/profile_provider.dart';
import '../../../core/services/ambassador_state_provider.dart';
import '../../../models/models.dart';
import '../../../design_system/design_system.dart';
import '../../../core/l10n/app_strings.dart';

class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletAsync = ref.watch(walletProvider);
    final ambassadorState = ref.watch(ambassadorStateProvider);
    final profileAsync = ref.watch(profileProvider);
    final currentAmbassador = profileAsync.value ?? ambassadorState.ambassador;

    return Scaffold(
      backgroundColor: MaamoraColors.scaffold,
      body: walletAsync.when(
        data: (data) => SingleChildScrollView(
          padding: const EdgeInsetsDirectional.only(
            start: 20,
            end: 20,
            top: 24,
            bottom: 100, // For bottom nav bar padding
          ),
          child: MaamoraStagger(
            crossSlide: false,
            children: [
              _balanceHero(context, data.balance),
              const SizedBox(height: 24),
              _EarningsBreakdown(data),
              const SizedBox(height: 28),
              if (currentAmbassador != null)
                _PayoutMethodSection(ambassador: currentAmbassador),
            ],
          ),
        ),
        loading: () => const _WalletSkeleton(),
        error: (err, _) => Padding(
          padding: const EdgeInsets.all(20),
          child: MaamoraErrorState(
            subtitle: err.toString(),
            onRetry: () => ref.invalidate(walletProvider),
          ),
        ),
      ),
    );
  }

  // ── Balance hero: premium card, animated glow, balance as CountUp ─────────

  Widget _balanceHero(BuildContext context, double balance) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.96, end: 1.0),
      duration: MaamoraDurations.slow,
      curve: Curves.easeOutBack,
      builder: (context, scale, child) =>
          Transform.scale(scale: scale, child: child),
      child: Stack(
        children: [
          // Animated halo behind the card
          const Positioned.fill(
            child: IgnorePointer(
              child: Padding(
                padding: EdgeInsets.only(top: 12),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [MaamoraColors.primaryHalo, MaamoraColors.primaryHaloEnd],
                      radius: 0.9,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [MaamoraGradients.heroOrangeTo, MaamoraColors.primary],
              ),
              borderRadius: BorderRadius.circular(22),
              boxShadow: MaamoraShadows.glow(MaamoraColors.primary),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                // Decorative elements + brand particles
                const Positioned.fill(
                  child: IgnorePointer(child: MaamoraParticles(count: 10)),
                ),
                PositionedDirectional(
                  end: -32,
                  top: -32,
                  child: Container(
                    width: 128,
                    height: 128,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                PositionedDirectional(
                  start: -16,
                  bottom: -16,
                  child: Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                context.tr('wallet_vendredi'),
                                style: MaamoraTheme.eyebrow().copyWith(
                                  color: Colors.white.withValues(alpha: 0.85),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  CountUpText(
                                    value: balance,
                                    style: GoogleFonts.cairo(
                                      fontSize: 50,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                      height: 1.02,
                                    ),
                                  ),
                                  Text(
                                    context.tr('dash_unit_dh'),
                                    style: GoogleFonts.cairo(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w600,
                                      color:
                                          Colors.white.withValues(alpha: 0.9),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              MaamoraIcons.wallet,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              MaamoraIcons.verifiedUser,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              context.tr('wallet_id_verified'),
                              style: GoogleFonts.cairo(
                                fontSize: 13,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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

// ── Wallet skeleton (shimmer — never raw empty while loading) ────────────────

class _WalletSkeleton extends StatelessWidget {
  const _WalletSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(
        start: 20,
        end: 20,
        top: 24,
        bottom: 24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MaamoraShimmerBox(height: 190, radius: 22),
          const SizedBox(height: 32),
          Row(
            children: [
              MaamoraShimmerBox(height: 22, width: 160, radius: 8),
              const Spacer(),
              MaamoraShimmerBox(height: 28, width: 110, radius: 14),
            ],
          ),
          const SizedBox(height: 16),
          const MaamoraSkeletonList(count: 4),
        ],
      ),
    );
  }
}

// ── Earnings breakdown — timeline of gains, drawn row by row ────────────────

class _EarningsBreakdown extends StatelessWidget {
  const _EarningsBreakdown(this.data);

  final WalletData data;

  @override
  Widget build(BuildContext context) {
    // Combine commissions and payouts into a single list of transactions.
    final List<dynamic> transactions = [...data.commissions, ...data.payouts];

    // Sort transactions by date descending (preserved business order).
    transactions.sort((a, b) {
      final aDate = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bDate = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bDate.compareTo(aDate);
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(context.tr('wallet_detail'), style: MaamoraTheme.sectionHeader()),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: MaamoraColors.primarySoft,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: MaamoraColors.primaryHairline),
              ),
              child: Row(
                children: [
                  Text(
                    context.tr('wallet_history'),
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: MaamoraColors.primary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    MaamoraIcons.chevronRight,
                    color: MaamoraColors.primary,
                    size: 14,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (transactions.isEmpty)
          MaamoraEmptyState(
            icon: MaamoraIcons.receipt,
            title: context.tr('wallet_empty'),
            subtitle: context.tr('wallet_empty_sub'),
          )
        else
          MaamoraCard(
            padding: EdgeInsets.zero,
            child: Builder(
              builder: (context) {
                final rows = <Widget>[];
                for (var i = 0; i < transactions.length; i++) {
                  final tx = transactions[i];
                  final isLast = i == transactions.length - 1;

                  // ── Identity of the row (mapping preserved) ──
                  String title = '';
                  String subtitle = '';
                  String amountStr = '';
                  IconData icon = MaamoraIcons.receipt;
                  Color iconColor = MaamoraColors.textSecondary;
                  Color iconBgColor = MaamoraColors.navySoft;
                  bool isExpired = false;
                  String typeLabel = '';
                  Color amountColor = MaamoraColors.primary;

                  if (tx is Commission) {
                    title = context.tr('wallet_tx_commission');
                    icon = MaamoraIcons.shoppingBag;
                    iconColor = MaamoraColors.primary;
                    iconBgColor = MaamoraColors.primarySoft;
                    if (tx.source == CommissionSource.groupCommission) {
                      title = tx.dealGroupName ?? context.tr('wallet_tx_deal');
                      icon = MaamoraIcons.users;
                    } else if (tx.source == CommissionSource.recruitBonus) {
                      title = context.tr('wallet_tx_bonus');
                      icon = MaamoraIcons.referral;
                    }
                    subtitle = tx.status.value.toUpperCase();
                    amountStr = "'+${tx.amount.toStringAsFixed(0)} ${context.tr('dash_unit_dh')}";
                    isExpired = tx.status == CommissionStatus.voided;
                    typeLabel = context.tr('wallet_tx_commission');
                    amountColor = MaamoraColors.primary;
                  } else if (tx is Payout) {
                    final methodStr = tx.method == PayoutMethod.bank
                        ? context.tr('wallet_tx_bank')
                        : context.tr('wallet_tx_cash');
                    title = tx.reference != null
                        ? '$methodStr (${tx.reference})'
                        : methodStr;
                    icon = tx.method == PayoutMethod.bank
                        ? MaamoraIcons.bank
                        : MaamoraIcons.cash;
                    iconColor = MaamoraColors.danger;
                    iconBgColor = MaamoraColors.dangerSoft;
                    subtitle = tx.status.value.toUpperCase();
                    amountStr = "'-${tx.amount.toStringAsFixed(0)} ${context.tr('dash_unit_dh')}";
                    typeLabel = context.tr('wallet_tx_payout');
                    amountColor = MaamoraColors.danger;
                  }

                  rows.add(
                    _WalletTxRow(
                      icon: icon,
                      iconColor: iconColor,
                      iconBgColor: iconBgColor,
                      title: title,
                      subtitle: subtitle,
                      amount: amountStr,
                      amountColor: amountColor,
                      typeLabel: typeLabel,
                      isExpired: isExpired,
                      isLast: isLast,
                      index: i,
                      totalCount: transactions.length,
                    ),
                  );
                  if (!isLast) {
                    rows.add(
                      const Divider(
                        height: 1,
                        thickness: 1,
                        color: MaamoraColors.onCreamDivider,
                        indent: 16,
                        endIndent: 16,
                      ),
                    );
                  }
                }
                return Column(children: rows);
              },
            ),
          ),
      ],
    );
  }
}

/// One transaction row. Enters with a staggered reveal (later rows wait a
/// little longer, using an Interval curve — transform/opacity only).
class _WalletTxRow extends StatelessWidget {
  const _WalletTxRow({
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.amountColor,
    required this.typeLabel,
    required this.isLast,
    required this.index,
    required this.totalCount,
    this.isExpired = false,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String title;
  final String subtitle;
  final String amount;
  final Color amountColor;
  final String typeLabel;
  final bool isLast;
  final bool isExpired;
  final int index;
  final int totalCount;

  @override
  Widget build(BuildContext context) {
    // Stagger slot: first rows arrive fast, later ones trail off (capped).
    final start = (0.10 + index * 0.12).clamp(0.0, 0.85);

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: MaamoraDurations.countUp,
      curve: Interval(start, 1.0, curve: Curves.easeOutCubic),
      builder: (context, t, child) {
        final tc = t.clamp(0.0, 1.0);
        return Opacity(
          opacity: tc,
          child: FractionalTranslation(
            translation: Offset((1 - tc) * 0.06, 0),
            child: child,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isExpired
              ? MaamoraColors.surfaceLow.withValues(alpha: 0.5)
              : Colors.transparent,
        ),
        child: Opacity(
          opacity: isExpired ? 0.6 : 1.0,
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(MaamoraRadius.input),
                  border: isExpired
                      ? Border.all(color: MaamoraColors.border)
                      : null,
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.cairo(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: MaamoraColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: MaamoraColors.textFaint,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  CountUpText(
                    value: double.tryParse(
                          amount.replaceAll(RegExp(r'[^0-9.]'), ''),
                        ) ??
                        0,
                    prefix: amount.startsWith('+') ? '+' : '-',
                    suffix: context.tr('dash_unit_dh'),
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: isExpired
                          ? MaamoraColors.textSecondary
                          : amountColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  if (!isExpired)
                    Text(
                      typeLabel,
                      style: GoogleFonts.cairo(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: MaamoraColors.textFaint,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Payout method — pulsing call-to-action when not configured yet ───────────

class _PayoutMethodSection extends StatefulWidget {
  const _PayoutMethodSection({required this.ambassador});

  final Ambassador ambassador;

  @override
  State<_PayoutMethodSection> createState() => _PayoutMethodSectionState();
}

class _PayoutMethodSectionState extends State<_PayoutMethodSection>
    with SingleTickerProviderStateMixin {
  AnimationController? _pulse;

  @override
  void initState() {
    super.initState();
    if (widget.ambassador.payoutMethod == null) {
      _pulse = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1400),
      )..repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulse?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ambassador = widget.ambassador;
    final hasMethod = ambassador.payoutMethod != null;
    final isBank = ambassador.payoutMethod == 'bank';
    final isCash = ambassador.payoutMethod == 'cash_pickup';

    String title;
    String subtitle;
    IconData icon;
    Color iconBgColor;
    Color iconColor;

    if (isBank) {
      title = context.tr('wallet_bank_rib');
      final rawRib = ambassador.payoutBankRib ?? '';
      // Format masked or clean.
      subtitle = rawRib.isNotEmpty ? rawRib : context.tr('wallet_rib_ok');
      icon = MaamoraIcons.bank;
      iconBgColor = MaamoraColors.navySoft;
      iconColor = MaamoraColors.navyOnSoft;
    } else if (isCash) {
      title = context.tr('wallet_cash');
      final rawCash = ambassador.payoutCashPoint ?? '';
      subtitle = rawCash.isNotEmpty ? rawCash : context.tr('wallet_cash_ok');
      icon = MaamoraIcons.cash;
      iconBgColor = MaamoraColors.successSoft;
      iconColor = MaamoraColors.successOn;
    } else {
      title = context.tr('wallet_not_configured');
      subtitle = context.tr('wallet_configure_hint');
      icon = MaamoraIcons.bank;
      iconBgColor = MaamoraColors.primarySoft;
      iconColor = MaamoraColors.primary;
    }

    final content = Row(
      children: [
        AnimatedBuilder(
          animation: _pulse ?? kAlwaysCompleteAnimation,
          builder: (context, child) {
            // 1.0 → 1.07 breathing scale on the icon disc when unconfigured.
            final scale = _pulse == null ? 1.0 : 1.0 + 0.07 * _pulse!.value;
            return Transform.scale(scale: scale, child: child);
          },
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.cairo(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: MaamoraColors.textPrimary,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: GoogleFonts.cairo(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  color: hasMethod
                      ? MaamoraColors.textSecondary
                      : MaamoraColors.primary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const Icon(
          MaamoraIcons.chevronRight,
          color: MaamoraColors.textFaint,
          size: 20,
        ),
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(context.tr('wallet_method_title'), style: MaamoraTheme.sectionHeader()),
            if (hasMethod)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: MaamoraColors.successSoft,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      MaamoraIcons.checkFilled,
                      size: 12,
                      color: MaamoraColors.successOn,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      context.tr('wallet_configured'),
                      style: GoogleFonts.cairo(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: MaamoraColors.successOn,
                      ),
                    ),
                  ],
                ),
              )
            else
              Text(
                context.tr('wallet_todo'),
                style: GoogleFonts.cairo(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: MaamoraColors.primary,
                ),
              ),
          ],
        ),
        const SizedBox(height: 14),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            HapticFeedback.selectionClick();
            PayoutMethodBottomSheet.show(
              context: context,
              ambassador: ambassador,
            );
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: MaamoraColors.surface,
              borderRadius: BorderRadius.circular(MaamoraRadius.cardSm),
              border: Border.all(
                color: hasMethod
                    ? MaamoraColors.primaryHairline
                    : MaamoraColors.primary.withValues(alpha: 0.45),
                width: hasMethod ? 1 : 1.4,
              ),
              boxShadow: hasMethod
                  ? MaamoraShadows.soft
                  : MaamoraShadows.glow(MaamoraColors.primary, 0.22),
            ),
            child: content,
          ),
        ),
      ],
    );
  }
}
