import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ── Design tokens ──────────────────────────────────────────────────────────
const Color _primary = Color(0xFFFB7701);
const Color _background = Color(0xFFFAF5F0);
const Color _surface = Color(0xFFFFFFFF);
const Color _onBackground = Color(0xFF1A2433);
const Color _onSurfaceVariant = Color(0xFF8A8078);
const Color _cardBorder = Color(0xFFE8DDD3);
const Color _orangeLight = Color(0xFFFCEBC9);

// ── données factices, à remplacer ─────────────────────────────────────────
class _MockGroup {
  final String productName;
  final double pricePerPerson;
  final int membersCount;
  final int seatsTotal;
  final String ambassadorName;
  final String completedAt;
  final bool commissionPaid; // true = already assigned

  const _MockGroup({
    required this.productName,
    required this.pricePerPerson,
    required this.membersCount,
    required this.seatsTotal,
    required this.ambassadorName,
    required this.completedAt,
    this.commissionPaid = false,
  });
}

final _mockGroups = <_MockGroup>[
  const _MockGroup(
    productName: 'Premium Dates Box (5kg)',
    pricePerPerson: 75.0,
    membersCount: 15,
    seatsTotal: 15,
    ambassadorName: 'Youssef T.',
    completedAt: 'Aujourd\'hui, 14:20',
    commissionPaid: false,
  ),
  const _MockGroup(
    productName: 'Artisan Tea Set Bundle',
    pricePerPerson: 120.0,
    membersCount: 15,
    seatsTotal: 15,
    ambassadorName: 'Fatima Z.',
    completedAt: 'Hier',
    commissionPaid: false,
  ),
  const _MockGroup(
    productName: 'Olive Oil Lovers — 5L Pack',
    pricePerPerson: 95.0,
    membersCount: 15,
    seatsTotal: 15,
    ambassadorName: 'Amine B.',
    completedAt: 'Oct 26',
    commissionPaid: true,
  ),
  const _MockGroup(
    productName: 'Moroccan Honey Jar (500g)',
    pricePerPerson: 60.0,
    membersCount: 15,
    seatsTotal: 15,
    ambassadorName: 'Sara B.',
    completedAt: 'Oct 24',
    commissionPaid: false,
  ),
];

class AdminGroupsPendingScreen extends StatelessWidget {
  const AdminGroupsPendingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // données factices, à remplacer
    final pendingCount =
        _mockGroups.where((g) => !g.commissionPaid).length;

    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(pendingCount),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                itemCount: _mockGroups.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (ctx, i) =>
                    _GroupCard(group: _mockGroups[i], context: ctx),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(int pendingCount) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Groupes complets',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: _onBackground,
            ),
          ),
          Text(
            'Groupes avec ${15}/15 membres prêts pour la commission.',
            style: GoogleFonts.inter(fontSize: 13, color: _onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

// ── Group Card ────────────────────────────────────────────────────────────

class _GroupCard extends StatelessWidget {
  final _MockGroup group;
  final BuildContext context;

  const _GroupCard({required this.group, required this.context});

  void _assignCommission(BuildContext ctx) {
    // TODO: brancher sur assign_commission(p_group_id)
    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(
        content: Text(
            'Commission assignée pour "${group.productName}" — (mock)'),
        backgroundColor: const Color(0xFF2E7D32),
      ),
    );
  }

  @override
  Widget build(BuildContext ctx) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: name + full badge
          Row(
            children: [
              Expanded(
                child: Text(
                  group.productName,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: _onBackground,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _orangeLight,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: const Color(0xFFE8C070), width: 1),
                ),
                child: Text(
                  '${group.membersCount}/${group.seatsTotal} Full',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF7A4800),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Ambassador
          Row(
            children: [
              const Icon(Icons.person_outline_rounded,
                  size: 14, color: _onSurfaceVariant),
              const SizedBox(width: 4),
              Text(
                'Ambassador: ${group.ambassadorName}',
                style: GoogleFonts.inter(
                    fontSize: 13, color: _onSurfaceVariant),
              ),
              const SizedBox(width: 12),
              const Icon(Icons.access_time_rounded,
                  size: 14, color: _onSurfaceVariant),
              const SizedBox(width: 4),
              Text(
                group.completedAt,
                style: GoogleFonts.inter(
                    fontSize: 13, color: _onSurfaceVariant),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${group.pricePerPerson.toStringAsFixed(0)} DH/personne',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _primary,
            ),
          ),
          const SizedBox(height: 12),

          // Assign or Paid button
          Align(
            alignment: Alignment.centerRight,
            child: group.commissionPaid
                ? Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F0F0),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_circle_rounded,
                            size: 16,
                            color: Color(0xFF888888)),
                        const SizedBox(width: 6),
                        Text(
                          'Commission Paid',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF888888),
                          ),
                        ),
                      ],
                    ),
                  )
                : ElevatedButton(
                    onPressed: () => _assignCommission(ctx),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7A3A00),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Assign Commission',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
