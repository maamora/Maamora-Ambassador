import 'package:flutter/material.dart';

// Dev 4 — Feuille de confirmation "Échanger en espèces" (mockup Stitch
// "Confirm Redemption Sheet"), ouverte depuis rewards_screen.dart via
// showModalBottomSheet — pas de Stack/scrim/"fixed" manuels comme dans
// l'export HTML brut : showModalBottomSheet gère déjà le fond assombri et
// l'animation d'entrée/sortie, donc pas besoin de les reconstruire.
//
// Ce widget est volontairement "bête" (pure présentation) : les 4 lignes
// de détail (montant, méthode, valeur, destination) ET la logique de
// soumission (onConfirm) lui sont passées par l'appelant, qui est le seul
// à connaître le vrai solde de l'ambassadeur — voir rewards_screen.dart.
//
// ── Points signalés plutôt que devinés ──
// 1) onConfirm ne fait RIEN de réel aujourd'hui. Il n'existe ni table/RPC
//    Supabase pour un "cash-out", ni état ambassadeur partagé et mutable
//    (core/services/ambassador_state_provider.dart, prévu par le brief
//    mais pas encore construit, bloqué sur l'Attribution de Yassine). Le
//    bouton "Confirmer" simule donc une soumission (spinner + délai) sans
//    rien déduire ni persister — voir _submitRedemption dans
//    rewards_screen.dart pour le détail. À ne pas présenter comme
//    fonctionnel en démo sans le préciser.
// 2) "Destination" (RIB) est un texte fixe inventé — le modèle Ambassador
//    n'a aucun champ pour un compte bancaire. Afficher un faux numéro de
//    compte dans un flux qui parle d'argent réel dépasse le simple détail
//    technique : il faudra un vrai champ profil (+ un vrai écran de
//    saisie/vérification) avant d'exposer ça à de vrais ambassadeurs.
// 3) "Méthode" (Virement bancaire) est fixe aussi, faute d'un champ "mode
//    de paiement préféré" sur Ambassador — même limitation que #2, mais
//    sans donnée financière inventée donc moins critique.

class RedemptionConfirmationSheet extends StatefulWidget {
  const RedemptionConfirmationSheet({
    super.key,
    required this.pointsLabel,
    required this.method,
    required this.valueLabel,
    required this.destination,
    required this.onConfirm,
  });

  final String pointsLabel;
  final String method;
  final String valueLabel;
  final String destination;

  /// Appelé quand l'utilisateur confirme. Lève une exception en cas
  /// d'échec (affichée via SnackBar) ; sinon la feuille se ferme d'elle
  /// même et renvoie `true` à l'appelant (voir showModalBottomSheet<bool>
  /// dans rewards_screen.dart).
  final Future<void> Function() onConfirm;

  @override
  State<RedemptionConfirmationSheet> createState() => _RedemptionConfirmationSheetState();
}

class _RedemptionConfirmationSheetState extends State<RedemptionConfirmationSheet> {
  bool _isSubmitting = false;

  Future<void> _handleConfirm() async {
    setState(() => _isSubmitting = true);
    try {
      await widget.onConfirm();
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Une erreur est survenue : $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        decoration: const BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.fromLTRB(20, 12, 20, 20 + MediaQuery.of(context).viewInsets.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 5,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: _outlineVariant,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const Text(
              "Confirmer l'échange en espèces",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700, color: _onSurface),
            ),
            const SizedBox(height: 4),
            const Text(
              'Veuillez vérifier les détails ci-dessous.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: _onSurfaceVariant),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: _surfaceContainerLow,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: _outlineVariant.withOpacity(0.6)),
              ),
              child: Column(
                children: [
                  _DetailRow(icon: Icons.star_outline, label: 'Montant', value: widget.pointsLabel),
                  _DetailRow(icon: Icons.account_balance_outlined, label: 'Méthode', value: widget.method),
                  _DetailRow(
                    icon: Icons.payments_outlined,
                    label: 'Valeur',
                    value: widget.valueLabel,
                    valueColor: _primaryContainer,
                    valueBold: true,
                  ),
                  _DetailRow(
                    icon: Icons.account_circle_outlined,
                    label: 'Destination',
                    value: widget.destination,
                    isLast: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: _primaryContainer,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: _isSubmitting ? null : _handleConfirm,
                child: _isSubmitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                      )
                    : const Text(
                        'Confirmer',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                      ),
              ),
            ),
            TextButton(
              onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(false),
              child: const Text(
                'Modifier',
                style: TextStyle(color: _onSurfaceVariant, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
    this.valueBold = false,
    this.isLast = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  final bool valueBold;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(bottom: BorderSide(color: _outlineVariant.withOpacity(0.4))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: _onSurfaceVariant),
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(fontSize: 14, color: _onSurface)),
            ],
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: valueBold ? FontWeight.w800 : FontWeight.w600,
              fontSize: valueBold ? 17 : 14,
              color: valueColor ?? _onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

// Tokens Material 3 du mockup Stitch — mêmes valeurs que rewards_screen.dart
// / leaderboard_screen.dart (même flag déjà posé ailleurs : app_colors.dart
// existe mais n'est pas ce que les écrans réellement livrés utilisent).
const Color _surface = Color(0xFFFFF8F5);
const Color _surfaceContainerLow = Color(0xFFFFF1EA);
const Color _onSurface = Color(0xFF251912);
const Color _onSurfaceVariant = Color(0xFF584236);
const Color _outlineVariant = Color(0xFFE0C0B0);
const Color _primaryContainer = Color(0xFFFB7701);
