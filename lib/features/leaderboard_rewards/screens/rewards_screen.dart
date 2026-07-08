import 'package:flutter/material.dart';

// TODO(Dev 4 - Rewards): construire l'écran récompenses/gains ici.
// - Utiliser MockDataService.mockCurrentAmbassador et mockOrders
// - IMPORTANT (voir brief feature #6): les montants de récompense par
//   commande doivent être CONFIRMÉS avec le fondateur avant d'afficher
//   de vrais chiffres. Utiliser un placeholder clair en attendant
//   (ex: "X MAD par commande — à confirmer") plutôt qu'un montant inventé.

class RewardsScreen extends StatelessWidget {
  const RewardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('TODO: Rewards Screen — Dev 4'),
      ),
    );
  }
}
