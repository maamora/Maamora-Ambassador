import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/services/mock_data_service.dart';
import '../../../shared/navigation/app_routes.dart';
import '../../../shared/widgets/bottom_nav_bar.dart';
import '../../../shared/widgets/shared_app_bar.dart';
import '../widgets/redemption_confirmation_sheet.dart';

// Dev 4 — Rewards & Redemption. Not in MainNavigationScreen's IndexedStack
// (standalone route), so it instantiates SharedAppBar/SharedBottomNavBar
// itself instead of getting them from a shell.

const int _mockPointsPerDh = 10; // TODO(Dev4): confirm real rate (brief #6).

class RewardsScreen extends StatelessWidget {
  const RewardsScreen({super.key, this.initialPoints});

  final int? initialPoints;

  @override
  Widget build(BuildContext context) {
    final points = initialPoints ?? MockDataService.mockCurrentAmbassador.points;

    return Scaffold(
      backgroundColor: _surface,
      appBar: const SharedAppBar(title: 'RÉCOMPENSES', hasNotification: true),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
          children: [
            _BalanceCard(points: points),
            const SizedBox(height: 24),
            Text(
              'Échanger des points',
              style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w700, color: _onBackground),
            ),
            const SizedBox(height: 16),
            _RedeemCard(
              icon: Icons.payments,
              title: 'Retrait en espèces',
              description: 'Convertissez vos points directement en argent versé sur votre compte lié.',
              buttonLabel: 'Échanger en espèces',
              filled: true,
              onPressed: () => _handleRedeemCash(context, points),
            ),
            const SizedBox(height: 16),
            _RedeemCard(
              icon: Icons.local_offer,
              title: 'Code promo',
              description: 'Obtenez des codes promo à forte valeur pour votre prochain achat en boutique.',
              buttonLabel: 'Obtenir le code',
              filled: false,
              onPressed: () => _handleGetPromoCode(context),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SharedBottomNavBar(
        currentIndex: -1,
        onTap: (_) => context.go(AppRoutes.dashboard),
      ),
    );
  }

  Future<void> _handleRedeemCash(BuildContext context, int points) async {
    final dhValue = points ~/ _mockPointsPerDh;
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => RedemptionConfirmationSheet(
        pointsLabel: '${_formatThousands(points)} pts',
        method: 'Virement bancaire',
        valueLabel: '$dhValue DH',
        destination: 'RIB •••4892',
        onConfirm: () => _submitRedemption(points),
      ),
    );
    if (confirmed == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Demande enregistrée (démo — rien n'est réellement déduit du solde pour l'instant).",
          ),
        ),
      );
    }
  }

  Future<void> _submitRedemption(int points) async {
    // TODO(Dev4): replace with real Supabase call + ambassador_state_provider.dart.
    await Future.delayed(const Duration(milliseconds: 900));
  }

  void _handleGetPromoCode(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Bientôt disponible')),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({required this.points});

  final int points;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _primaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SOLDE TOTAL',
            style: GoogleFonts.inter(
              color: Colors.white.withValues(alpha: 0.9),
              fontWeight: FontWeight.w600,
              fontSize: 13,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                _formatThousands(points),
                style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 34, fontWeight: FontWeight.w800),
              ),
              const SizedBox(width: 8),
              Text(
                'PTS',
                style: GoogleFonts.plusJakartaSans(color: Colors.white.withValues(alpha: 0.85), fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.trending_up, color: Colors.white.withValues(alpha: 0.9), size: 18),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Valeur en \$ — taux de conversion à confirmer',
                  style: GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.9), fontSize: 13),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RedeemCard extends StatelessWidget {
  const _RedeemCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.buttonLabel,
    required this.onPressed,
    this.filled = true,
  });

  final IconData icon;
  final String title;
  final String description;
  final String buttonLabel;
  final VoidCallback onPressed;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _outlineVariant.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 20, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(color: _surfaceVariant, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Icon(icon, color: _primary, size: 26),
          ),
          const SizedBox(height: 16),
          Text(title, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: _onBackground)),
          const SizedBox(height: 8),
          Text(description, style: GoogleFonts.inter(fontSize: 14, color: _onSurfaceVariant, height: 1.4)),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: filled
                ? ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryContainer,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    onPressed: onPressed,
                    child: Text(buttonLabel, style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 14)),
                  )
                : OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _primaryContainer,
                      side: const BorderSide(color: _primaryContainer, width: 2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    onPressed: onPressed,
                    child: Text(buttonLabel, style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 14)),
                  ),
          ),
        ],
      ),
    );
  }
}

String _formatThousands(int value) {
  final digits = value.toString();
  final buffer = StringBuffer();
  for (int i = 0; i < digits.length; i++) {
    if (i != 0 && (digits.length - i) % 3 == 0) buffer.write(',');
    buffer.write(digits[i]);
  }
  return buffer.toString();
}

const Color _primary = Color(0xFF9A4600);
const Color _primaryContainer = Color(0xFFFB7701);
const Color _surface = Color(0xFFFFF8F5);
const Color _surfaceContainerLowest = Color(0xFFFFFFFF);
const Color _surfaceVariant = Color(0xFFF6DED2);
const Color _onBackground = Color(0xFF251912);
const Color _onSurfaceVariant = Color(0xFF584236);
const Color _outlineVariant = Color(0xFFE0C0B0);
