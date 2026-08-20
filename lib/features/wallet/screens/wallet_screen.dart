import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/theme/app_colors.dart';
import '../providers/wallet_provider.dart';
import '../../../core/services/ambassador_state_provider.dart';
import '../../../models/models.dart';

class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletAsync = ref.watch(walletProvider);
    final ambassadorState = ref.watch(ambassadorStateProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: walletAsync.when(
        data: (data) => SingleChildScrollView(
          padding: const EdgeInsets.only(
            left: 20,
            right: 20,
            top: 24,
            bottom: 100, // For bottom nav bar padding
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildBalanceCard(data.balance),
              const SizedBox(height: 32),
              _buildEarningsBreakdown(data),
              const SizedBox(height: 32),
              if (ambassadorState.ambassador != null)
                _buildPayoutMethod(ambassadorState.ambassador!),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primaryContainer)),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildBalanceCard(double balance) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryContainer.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Decorative elements
          Positioned(
            right: -32,
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
          Positioned(
            left: -16,
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
            padding: const EdgeInsets.all(16),
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
                          'ARRIVING THIS FRIDAY',
                          style: GoogleFonts.workSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.0,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '${balance.toStringAsFixed(0)} ',
                              style: GoogleFonts.beVietnamPro(
                                fontSize: 36,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: -0.5,
                              ),
                            ),
                            Text(
                              'DH',
                              style: GoogleFonts.beVietnamPro(
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.payments_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.verified_user_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'ID Verification Complete',
                        style: GoogleFonts.workSans(
                          fontSize: 14,
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
    );
  }

  Widget _buildEarningsBreakdown(WalletData data) {
    // Combine commissions and payouts into a single list of transactions
    final List<dynamic> transactions = [...data.commissions, ...data.payouts];
    
    // Sort transactions by date descending
    transactions.sort((a, b) {
      final aDate = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bDate = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bDate.compareTo(aDate);
    });

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Earnings Breakdown',
              style: GoogleFonts.beVietnamPro(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Text(
                    'All Time',
                    style: GoogleFonts.workSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryContainer,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.expand_more_rounded,
                    color: AppColors.primaryContainer,
                    size: 16,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (transactions.isEmpty)
          const Padding(
            padding: EdgeInsets.all(24.0),
            child: Text('No transactions yet.'),
          )
        else
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
            ),
            child: Column(
              children: transactions.asMap().entries.map((entry) {
                final index = entry.key;
                final tx = entry.value;
                final isLast = index == transactions.length - 1;
                
                String title = '';
                String subtitle = '';
                String amountStr = '';
                IconData icon = Icons.attach_money;
                Color iconColor = const Color(0xFF596374);
                Color iconBgColor = const Color(0xFFd6e0f5);
                bool isExpired = false;
                String typeLabel = '';

                if (tx is Commission) {
                  title = 'Commission';
                  icon = Icons.shopping_bag_rounded;
                  if (tx.source == CommissionSource.groupCommission) {
                    title = tx.dealGroupName ?? 'Deal Group';
                    icon = Icons.group_rounded;
                  } else if (tx.source == CommissionSource.recruitBonus) {
                    title = 'Recruitment Bonus';
                    icon = Icons.person_add_rounded;
                  }
                  subtitle = tx.status.value.toUpperCase();
                  amountStr = '+${tx.amount.toStringAsFixed(0)} DH';
                  isExpired = tx.status == CommissionStatus.voided;
                  typeLabel = 'Commission';
                } else if (tx is Payout) {
                  final methodStr = tx.method == PayoutMethod.bank ? 'Virement Bancaire' : 'Espèces (Cash)';
                  title = tx.reference != null ? '$methodStr (${tx.reference})' : methodStr;
                  icon = Icons.account_balance_wallet_rounded;
                  iconColor = const Color(0xFFB3261E);
                  iconBgColor = const Color(0xFFF9DEDC);
                  subtitle = tx.status.value.toUpperCase();
                  amountStr = '-${tx.amount.toStringAsFixed(0)} DH';
                  typeLabel = 'Payout';
                }
                
                return Column(
                  children: [
                    _buildEarningRow(
                      icon: icon,
                      iconColor: iconColor,
                      iconBgColor: iconBgColor,
                      title: title,
                      subtitle: subtitle,
                      amount: amountStr,
                      isLast: isLast,
                      isExpired: isExpired,
                      typeLabel: typeLabel,
                    ),
                    if (!isLast)
                      const Divider(height: 1, color: AppColors.outlineVariant),
                  ],
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildEarningRow({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String subtitle,
    required String amount,
    required bool isLast,
    required String typeLabel,
    bool isExpired = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isExpired ? AppColors.surfaceContainerLow.withValues(alpha: 0.5) : Colors.transparent,
        borderRadius: isLast
            ? const BorderRadius.vertical(bottom: Radius.circular(15))
            : (title == 'Olive Oil Lovers - Casa'
                ? const BorderRadius.vertical(top: Radius.circular(15))
                : BorderRadius.zero),
      ),
      child: Opacity(
        opacity: isExpired ? 0.6 : 1.0,
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(12),
                border: isExpired
                    ? Border.all(color: Colors.grey.withValues(alpha: 0.3))
                    : null,
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.workSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.workSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
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
                  amount,
                  style: GoogleFonts.workSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isExpired ? AppColors.onSurfaceVariant : (typeLabel == 'Payout' ? const Color(0xFFB3261E) : AppColors.primaryContainer),
                  ),
                ),
                if (!isExpired) ...[
                  const SizedBox(height: 2),
                  Text(
                    typeLabel,
                    style: GoogleFonts.workSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ]
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPayoutMethod(Ambassador ambassador) {
    final hasMethod = ambassador.payoutMethod != null;
    final title = hasMethod ? (ambassador.payoutMethod == 'bank' ? 'Bank Transfer' : 'Cash Pickup') : 'Not Set';
    final subtitle = hasMethod ? (ambassador.payoutMethod == 'bank' ? (ambassador.payoutBankRib ?? 'RIB missing') : (ambassador.payoutCashPoint ?? 'Cash point missing')) : 'Tap to set up';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payout Method',
          style: GoogleFonts.beVietnamPro(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.account_balance_rounded,
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
                        title,
                        style: GoogleFonts.workSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: GoogleFonts.workSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.onSurfaceVariant,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
