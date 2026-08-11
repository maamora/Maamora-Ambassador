import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/admin_status_badge.dart';

// ── Design tokens ──────────────────────────────────────────────────────────
const Color _primary = Color(0xFFFB7701);
const Color _background = Color(0xFFFAF5F0);
const Color _surface = Color(0xFFFFFFFF);
const Color _onBackground = Color(0xFF1A2433);
const Color _onSurfaceVariant = Color(0xFF8A8078);
const Color _cardBorder = Color(0xFFE8DDD3);

// ── données factices, à remplacer ─────────────────────────────────────────
class _MockCommission {
  final String ambassadorName;
  final String initials;
  final String productName;
  final double amount;
  final String status; // paid | pending | failed
  final String date;

  const _MockCommission({
    required this.ambassadorName,
    required this.initials,
    required this.productName,
    required this.amount,
    required this.status,
    required this.date,
  });
}

final _mockCommissions = <_MockCommission>[
  const _MockCommission(
    ambassadorName: 'Youssef Tahiri',
    initials: 'YT',
    productName: 'Premium Dates Box',
    amount: 562.50,
    status: 'paid',
    date: 'Aujourd\'hui',
  ),
  const _MockCommission(
    ambassadorName: 'Amine Benhammou',
    initials: 'AB',
    productName: 'Olive Oil Lovers Pack',
    amount: 712.50,
    status: 'paid',
    date: 'Oct 26',
  ),
  const _MockCommission(
    ambassadorName: 'Fatima Zahra',
    initials: 'FZ',
    productName: 'Artisan Tea Set Bundle',
    amount: 900.00,
    status: 'pending',
    date: 'Oct 28',
  ),
  const _MockCommission(
    ambassadorName: 'Sara Benali',
    initials: 'SB',
    productName: 'Moroccan Honey Jar',
    amount: 450.00,
    status: 'pending',
    date: 'Oct 30',
  ),
  const _MockCommission(
    ambassadorName: 'Hassan Moussaoui',
    initials: 'HM',
    productName: 'Argan Oil Gift Set',
    amount: 337.50,
    status: 'failed',
    date: 'Nov 1',
  ),
];

class AdminCommissionsScreen extends StatelessWidget {
  const AdminCommissionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // données factices, à remplacer
    final totalPaid = _mockCommissions
        .where((c) => c.status == 'paid')
        .fold<double>(0, (sum, c) => sum + c.amount);
    final totalPending = _mockCommissions
        .where((c) => c.status == 'pending')
        .fold<double>(0, (sum, c) => sum + c.amount);

    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(totalPaid, totalPending),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                itemCount: _mockCommissions.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) =>
                    _CommissionRow(commission: _mockCommissions[i]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(double totalPaid, double totalPending) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Commissions & Paiements',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: _onBackground,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _SummaryChip(
                  label: 'Payées',
                  value: '${totalPaid.toStringAsFixed(0)} DH',
                  color: const Color(0xFF2E7D32),
                  bgColor: const Color(0xFFDCEEE3),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SummaryChip(
                  label: 'En attente',
                  value: '${totalPending.toStringAsFixed(0)} DH',
                  color: const Color(0xFF7A4800),
                  bgColor: const Color(0xFFFCEBC9),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'données factices, à remplacer',
            style: GoogleFonts.inter(
                fontSize: 11,
                color: _onSurfaceVariant,
                fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final Color bgColor;

  const _SummaryChip({
    required this.label,
    required this.value,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
                fontSize: 11, fontWeight: FontWeight.w600, color: color),
          ),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
                fontSize: 17, fontWeight: FontWeight.w800, color: color),
          ),
        ],
      ),
    );
  }
}

// ── Commission Row ────────────────────────────────────────────────────────

class _CommissionRow extends StatelessWidget {
  final _MockCommission commission;
  const _CommissionRow({required this.commission});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 20,
            backgroundColor: const Color(0xFFE8DDD3),
            child: Text(
              commission.initials,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: _onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  commission.ambassadorName,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _onBackground,
                  ),
                ),
                Text(
                  commission.productName,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: _onSurfaceVariant,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  commission.date,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: _onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Amount + status
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${commission.amount.toStringAsFixed(0)} DH',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: _primary,
                ),
              ),
              const SizedBox(height: 4),
              AdminStatusBadge(status: commission.status),
            ],
          ),
        ],
      ),
    );
  }
}
