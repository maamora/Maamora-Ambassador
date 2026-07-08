import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/navigation/app_routes.dart';

// TODO(Dev 1 - Onboarding): construire l'écran d'inscription ici.
// - Champs: nom, email
// - Bouton "Rejoindre le programme"
// - Style mobile-first, simple et rapide (voir brief feature #1)
// - Données: pas de backend pour l'instant, juste valider le formulaire
//   et naviguer avec: context.go(AppRoutes.dashboard);

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('TODO: Sign Up Screen — Dev 1'),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.dashboard),
              child: const Text('Aller au Dashboard (test navigation)'),
            ),
          ],
        ),
      ),
    );
  }
}
