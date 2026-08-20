import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/admin_status_badge.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ── Design tokens ──────────────────────────────────────────────────────────
const Color _primary = Color(0xFFFB7701);
const Color _background = Color(0xFFFAF5F0);
const Color _surface = Color(0xFFFFFFFF);
const Color _onBackground = Color(0xFF1A2433);
const Color _onSurfaceVariant = Color(0xFF8A8078);
const Color _cardBorder = Color(0xFFE8DDD3);

class AdminCommissionsScreen extends StatefulWidget {
  const AdminCommissionsScreen({super.key});

  @override
  State<AdminCommissionsScreen> createState() => _AdminCommissionsScreenState();
}

class _AdminCommissionsScreenState extends State<AdminCommissionsScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  List<Map<String, dynamic>> _payouts = [];
  double _totalPaid = 0.0;
  double _totalPending = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final client = Supabase.instance.client;

      // Fetch payouts for the list
      final payoutsResponse = await client
          .from('payouts')
          .select('*, ambassadors(full_name)')
          .order('created_at', ascending: false);
          
      // Fetch commissions for the totals
      final commissionsResponse = await client
          .from('commissions')
          .select('amount, status');

      double totalPaid = 0;
      double totalPending = 0;

      for (var c in (commissionsResponse as List)) {
        final amount = (c['amount'] as num?)?.toDouble() ?? 0.0;
        final status = c['status'] as String?;
        if (status == 'paid') {
          totalPaid += amount;
        } else if (status == 'payable' || status == 'pending') {
          totalPending += amount;
        }
      }

      setState(() {
        _payouts = List<Map<String, dynamic>>.from(payoutsResponse);
        _totalPaid = totalPaid;
        _totalPending = totalPending;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Impossible de charger les données: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(_totalPaid, _totalPending),
            Expanded(
              child: _buildBody(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: _primary));
    }
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(_errorMessage!, style: GoogleFonts.inter()),
            TextButton(onPressed: _fetchData, child: const Text('Réessayer'))
          ],
        ),
      );
    }

    if (_payouts.isEmpty) {
      return const Center(child: Text('Aucun paiement trouvé.'));
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: _payouts.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final p = _payouts[i];
        return _PayoutRow(payoutData: p);
      },
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

// ── Payout Row ────────────────────────────────────────────────────────

class _PayoutRow extends StatelessWidget {
  final Map<String, dynamic> payoutData;
  const _PayoutRow({required this.payoutData});

  @override
  Widget build(BuildContext context) {
    final ambassadorName = payoutData['ambassadors'] != null ? payoutData['ambassadors']['full_name'] ?? 'Inconnu' : 'Inconnu';
    final parts = ambassadorName.split(' ');
    String initials = '';
    if (parts.isNotEmpty && parts[0].isNotEmpty) initials += parts[0][0].toUpperCase();
    if (parts.length > 1 && parts[1].isNotEmpty) initials += parts[1][0].toUpperCase();

    final method = payoutData['method'] == 'bank' ? 'Virement Bancaire' : 'Espèces (Cash)';
    final ref = payoutData['reference'] != null ? ' - ${payoutData['reference']}' : '';
    final details = '$method$ref';
    
    final amount = (payoutData['amount'] as num?)?.toDouble() ?? 0.0;
    final status = payoutData['status'] as String? ?? 'pending';
    
    String formattedDate = '';
    if (payoutData['created_at'] != null) {
      final date = DateTime.tryParse(payoutData['created_at']);
      if (date != null) {
         formattedDate = "${date.day}/${date.month}/${date.year}";
      }
    }

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
              initials,
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
                  ambassadorName,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _onBackground,
                  ),
                ),
                Text(
                  details,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: _onSurfaceVariant,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  formattedDate,
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
                '${amount.toStringAsFixed(0)} DH',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: _primary,
                ),
              ),
              const SizedBox(height: 4),
              AdminStatusBadge(status: status),
            ],
          ),
        ],
      ),
    );
  }
}
