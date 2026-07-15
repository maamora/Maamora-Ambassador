import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/services/mock_data_service.dart';
import '../../../shared/navigation/app_routes.dart';
import '../../../shared/widgets/bottom_nav_bar.dart';
import '../../../shared/widgets/shared_app_bar.dart';
import '../widgets/redemption_confirmation_sheet.dart';

// Dev 4 — Rewards & Redemption (converti depuis le mockup Stitch "Rewards
// & Redemption Screen"), même approche que leaderboard_screen.dart.
//
// STRUCTURE : contrairement à Leaderboard, cet écran n'est PAS dans
// l'IndexedStack de MainNavigationScreen (voir main_navigation_screen.dart
// — seuls Dashboard/Groups/Leaderboard/Products/Profile y sont). Il n'est
// aujourd'hui accessible que via la route standalone AppRoutes.rewards
// ('/rewards', voir app_router.dart), poussée par-dessus le shell
// principal — donc pas de Scaffold parent qui fournit SharedAppBar /
// SharedBottomNavBar ici. C'est pour ça que CET écran les instancie
// lui-même (Leaderboard ne le fait pas, puisqu'il est déjà dans le shell).
// C'est bien la réutilisation demandée ("reuse... rather than
// recreating") : mêmes composants, pas une copie.
//
// DONNÉES : MockDataService.mockCurrentAmbassador (points réels), même
// convention que Leaderboard. TODO(Dev4): brancher sur Supabase une fois
// disponible.
//
// LANGUE : cet écran a été traduit en français (initialement livré en
// anglais, calqué sur le mockup Stitch) pour matcher Profile, qui est en
// français, suite à la décision d'Anas — ne pas repasser en anglais sans
// vérifier. Note : Dashboard (l'onglet Home) est encore en anglais lui
// aussi ("Current Balance", "My Active Groups"...) donc l'app reste
// mélangée au-delà de ce seul écran ; hors scope ici.
//
// ── 4 points signalés plutôt que devinés ──
// 1) "+$45.00 Value" du mockup est un montant en dur — exactement ce que
//    le brief interdit (feature #6 : aucun montant tant que le fondateur
//    n'a pas confirmé). Remplacé par un libellé neutre ("taux de
//    conversion à confirmer") plutôt qu'un chiffre inventé.
// 2) Bouton "Échanger en espèces" : ouvre désormais la vraie feuille de
//    confirmation (widgets/redemption_confirmation_sheet.dart), avec le
//    montant/valeur calculés à partir du solde réel de cet écran — voir
//    les points signalés dans ce fichier pour ce qui reste factice
//    (méthode, destination, soumission). "Get Promo Code" reste un
//    SnackBar temporaire : le prompt ne précisait pas de destination pour
//    ce bouton-là.
// 3) Section "Your Tier Perks" du mockup : PAS reprise. Elle n'est pas
//    dans la liste de requirements de ce screen, et son contenu n'est
//    backé par aucune donnée réelle (pas de modèle "perks"). Pire : le
//    mockup affiche "Unlock at Platinum Status (20,000 pts)" alors que
//    Tier.platinum.minPoints = 4000 dans notre modèle actuel — un vrai
//    conflit de données, pas juste un détail manquant. À reprendre une
//    fois le contenu/les seuils confirmés avec l'équipe.
// 4) SharedBottomNavBar attend un currentIndex correspondant à un onglet
//    du shell (0..4), mais "Rewards" n'en est pas un. currentIndex est mis
//    à -1 (aucun onglet actif) et chaque tap renvoie vers
//    AppRoutes.dashboard (Home) : MainNavigationScreen ne permet pas
//    aujourd'hui d'ouvrir directement sur un onglet précis (son
//    _currentIndex est un State local, pas piloté de l'extérieur), donc
//    on ne peut pas re-router précisément vers "Groups"/"Products"/
//    "Profile" depuis ici sans un mécanisme partagé en plus (state
//    provider, ou paramètre d'index initial sur la route).
// 5) initialPoints (ajouté pour le bouton "Échanger" du Profile) :
//    Profile lit son solde de points depuis Supabase en direct
//    (ProfileProvider → table "ambassadors"), alors que cet écran lit
//    MockDataService (donnée factice). Ce ne sont PAS la même source. En
//    attendant le vrai state partagé (core/services/
//    ambassador_state_provider.dart, prévu par le brief mais pas encore
//    construit — bloqué sur l'Attribution de Yassine), on fait transiter
//    la valeur réelle déjà chargée par Profile via l'argument de route
//    (state.extra dans app_router.dart), pour ne pas afficher un 2ᵉ solde
//    différent juste après que l'utilisateur a vu le vrai. Si l'écran est
//    ouvert autrement (navigation directe, pas encore de point d'entrée
//    aujourd'hui), on retombe sur MockDataService comme avant.
// 6) Feuille de confirmation (widgets/redemption_confirmation_sheet.dart) :
//    le "Montant" qu'elle affiche vient du solde réel de cet écran (pas
//    un 2ᵉ chiffre inventé), mais "Méthode" et "Destination" restent des
//    textes fixes — Ambassador n'a ni mode de paiement ni RIB en base.
//    Et surtout : "Confirmer" ne fait qu'un délai simulé (_submitRedemption
//    ci-dessous), rien n'est réellement soumis ni déduit du solde — voir
//    ce fichier + le fichier de la feuille pour le détail complet.

const int _mockPointsPerDh = 10; // TODO(Dev4): confirmer le vrai taux (brief #6).

class RewardsScreen extends StatelessWidget {
  const RewardsScreen({super.key, this.initialPoints});

  /// Solde réel transmis par l'écran appelant (voir point signalé #5).
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
    // TODO(Dev4): remplacer par un vrai appel Supabase (ex: RPC
    // "redeem_points" ou une future table de redemptions) + déduire le
    // solde via le futur core/services/ambassador_state_provider.dart
    // (état partagé, pas encore construit, bloqué sur l'Attribution de
    // Yassine — voir point signalé #5/#6 en haut de ce fichier). Pour
    // l'instant : aucun des deux n'existe, donc ceci ne fait que simuler
    // une latence réseau sans rien persister ni déduire.
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
              color: Colors.white.withOpacity(0.9),
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
                style: GoogleFonts.plusJakartaSans(color: Colors.white.withOpacity(0.85), fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.trending_up, color: Colors.white.withOpacity(0.9), size: 18),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Valeur en \$ — taux de conversion à confirmer',
                  style: GoogleFonts.inter(color: Colors.white.withOpacity(0.9), fontSize: 13),
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
        border: Border.all(color: _outlineVariant.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 4)),
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

// Tokens Material 3 du mockup Stitch — mêmes valeurs que dans
// leaderboard_screen.dart / dashboard_screen.dart (voir le flag #1 posé
// sur Leaderboard : app_colors.dart existe mais n'est pas ce que les
// écrans réellement livrés utilisent).
const Color _primary = Color(0xFF9A4600);
const Color _primaryContainer = Color(0xFFFB7701);
const Color _surface = Color(0xFFFFF8F5);
const Color _surfaceContainerLowest = Color(0xFFFFFFFF);
const Color _surfaceVariant = Color(0xFFF6DED2);
const Color _onBackground = Color(0xFF251912);
const Color _onSurfaceVariant = Color(0xFF584236);
const Color _outlineVariant = Color(0xFFE0C0B0);
