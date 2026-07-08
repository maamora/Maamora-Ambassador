import 'package:flutter/material.dart';

// TODO(Dev 3 - Dashboard): construire le dashboard ici.
// - Utiliser MockDataService.mockCurrentAmbassador (points, tier)
// - Utiliser MockDataService.mockOrders pour l'historique
// - Réutiliser shared/widgets/tier_badge.dart (ne pas dupliquer)
// - Afficher: points totaux, progression vers le prochain tier,
//   nb commandes confirmées, montant total des ventes
// - Voir brief feature #4 (points & tiers)

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('TODO: Dashboard Screen — Dev 3'),
      ),
    );
  }
}
