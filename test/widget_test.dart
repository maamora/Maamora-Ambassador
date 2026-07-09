// Test de fumée basique — vérifie juste que l'app démarre sans planter.
// À enrichir plus tard avec de vrais tests par écran.

import 'package:flutter_test/flutter_test.dart';
import 'package:ambassadors/main.dart';

void main() {
  testWidgets('App starts and shows the Sign Up screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const AmbassadorsApp());
    await tester.pumpAndSettle();

    // L'écran d'inscription (placeholder) doit s'afficher au démarrage.
    expect(find.textContaining('Sign Up Screen'), findsOneWidget);
  });
}
