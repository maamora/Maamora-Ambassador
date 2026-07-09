import 'package:flutter/material.dart';

// TODO(Dev 2 - Share): construire l'écran de partage ici.
// - Utiliser MockDataService.mockCatalog (core/services/mock_data_service.dart)
// - Pour chaque produit: image, prix, points_per_sale, lien de parrainage
//   (basé sur MockDataService.mockCurrentAmbassador.referralCode)
// - Bouton copier le lien + bouton partager (package share_plus)
// - Voir brief feature #2 (share links & share-cards)

class ShareScreen extends StatelessWidget {
  const ShareScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('TODO: Share Screen — Dev 2'),
      ),
    );
  }
}
