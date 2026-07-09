import 'package:flutter/material.dart';

// TODO(Dev 4 - Leaderboard): construire le classement ici.
// - Utiliser MockDataService.mockLeaderboard (déjà trié par points)
// - Mettre en évidence MockDataService.mockCurrentAmbassador dans la liste
// - Réutiliser shared/widgets/tier_badge.dart (ne pas dupliquer)
// - Voir brief feature #5 (leaderboard - "coeur compétitif" de l'app)

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('TODO: Leaderboard Screen — Dev 4'),
      ),
    );
  }
}
