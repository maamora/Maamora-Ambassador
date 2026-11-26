// Garde-fous UI (Lots 4-5) : les composants du design system doivent
// s'afficher en arabe (RTL) et en français, avec une taille de texte à 1.3,
// sans exception de rendu (dégradés directionnels dans les ShaderMask) ni
// débordement.

import 'package:ambassadors/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

Widget _harness(
  Locale locale,
  Widget child, {
  double scale = 1.3,
  bool reduceMotion = false,
}) {
  return MaterialApp(
    locale: locale,
    supportedLocales: const [Locale('fr'), Locale('ar')],
    localizationsDelegates: const [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    home: MediaQuery(
      // 360dp ≈ largeur logique d'un Samsung A53 (1080px @ 3x).
      data: MediaQueryData(
        size: const Size(360, 780),
        textScaler: TextScaler.linear(scale),
        disableAnimations: reduceMotion,
      ),
      child: Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(MaamoraSpacing.screen),
          child: child,
        ),
      ),
    ),
  );
}

void main() {
  // Pas de réseau en test : les polices Cairo ne sont pas téléchargées, le
  // rendu retombe sur la police par défaut (les métriques restent proches).
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  for (final locale in const [Locale('ar'), Locale('fr')]) {
    testWidgets('TierBadge (shine ShaderMask) — ${locale.languageCode}', (
      tester,
    ) async {
      await tester.pumpWidget(
        _harness(
          locale,
          const Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              TierBadge(levelIndex: 0, label: 'الأساسي'),
              TierBadge(levelIndex: 1, label: 'Bronze', commissionRate: 0.06),
              TierBadge(
                levelIndex: 2,
                label: 'الفضي',
                size: TierBadgeSize.large,
              ),
              TierBadge(levelIndex: 3, label: 'Gold', compact: true),
            ],
          ),
        ),
      );
      // Laisse tourner l'animation de reflet (shader recalculé à chaque frame).
      await tester.pump(const Duration(milliseconds: 1500));
      expect(tester.takeException(), isNull);
      expect(find.byType(TierBadge), findsNWidgets(4));
    });

    testWidgets('États vide / erreur + jauge — ${locale.languageCode}', (
      tester,
    ) async {
      await tester.pumpWidget(
        _harness(
          locale,
          const Column(
            children: [
              MaamoraEmptyState(
                icon: Icons.inbox_outlined,
                title: 'Aucun groupe pour le moment — لا توجد مجموعات حتى الآن',
                subtitle: 'Partage un produit pour créer ton premier groupe !',
              ),
              SizedBox(height: 16),
              MaamoraErrorState(),
              SizedBox(height: 16),
              PointsMeter(value: 0.42),
            ],
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 1500));
      expect(tester.takeException(), isNull);
      // Titre par défaut traduit (plus de français en dur en arabe).
      expect(
        find.text(
          locale.languageCode == 'ar'
              ? 'تعذّر التحميل'
              : 'Le chargement a échoué',
        ),
        findsOneWidget,
      );
    });
  }

  testWidgets('Mouvement réduit : la jauge affiche sa valeur finale', (
    tester,
  ) async {
    await tester.pumpWidget(
      _harness(
        const Locale('fr'),
        const PointsMeter(value: 0.5),
        reduceMotion: true,
      ),
    );
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.text('50 %'), findsOneWidget);
  });
  testWidgets('MaamoraIconAction : nom lisible + cible 48dp (AR)', (
    tester,
  ) async {
    var taps = 0;
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      _harness(
        const Locale('ar'),
        Row(
          children: [
            MaamoraIconAction(
              label: 'نسخ',
              onPressed: () => taps++,
              child: const Icon(Icons.copy, size: 16),
            ),
          ],
        ),
      ),
    );
    final size = tester.getSize(find.byType(MaamoraIconAction));
    expect(size.width, greaterThanOrEqualTo(kMaamoraMinTapTarget));
    expect(size.height, greaterThanOrEqualTo(kMaamoraMinTapTarget));
    expect(find.bySemanticsLabel('نسخ'), findsOneWidget);
    await tester.tap(find.byType(MaamoraIconAction));
    expect(taps, 1);
    handle.dispose();
  });

  testWidgets('MaamoraTappable : bouton sélectionné, libellé = texte', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      _harness(
        const Locale('fr'),
        MaamoraTappable(
          selected: true,
          onTap: () {},
          child: const Text('En cours'),
        ),
      ),
    );
    expect(
      tester.getSemantics(find.byType(MaamoraTappable)),
      isSemantics(label: 'En cours', isButton: true, isSelected: true),
    );
    handle.dispose();
  });
  testWidgets('Onglets : fade through sans perdre leur état', (tester) async {
    Widget tabs(int index) => _harness(
      const Locale('fr'),
      SizedBox(
        height: 200,
        child: MaamoraFadeThroughIndexedStack(
          index: index,
          children: const [
            TextField(key: Key('tab0-field')),
            Text('Onglet 2'),
          ],
        ),
      ),
    );
    await tester.pumpWidget(tabs(0));
    await tester.enterText(find.byKey(const Key('tab0-field')), 'saisie');
    await tester.pumpWidget(tabs(1));
    await tester.pump(const Duration(milliseconds: 150)); // mi-transition
    expect(tester.takeException(), isNull);
    await tester.pumpAndSettle();
    expect(find.text('Onglet 2'), findsOneWidget);
    await tester.pumpWidget(tabs(0));
    await tester.pumpAndSettle();
    // Le texte saisi dans l'onglet 1 est toujours là (IndexedStack conservé).
    expect(find.text('saisie'), findsOneWidget);
  });
  for (final locale in const [Locale('fr'), Locale('ar')]) {
    testWidgets('Jauge en arc : valeur lue + rendu ${locale.languageCode}', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        _harness(
          locale,
          const MaamoraArcGauge(
            value: 0.7,
            width: 120,
            semanticLabel: 'Places prises',
            center: Text('7/10'),
          ),
        ),
      );
      await tester.pump(const Duration(seconds: 1));
      expect(tester.takeException(), isNull);
      expect(find.text('7/10'), findsOneWidget);
      expect(find.bySemanticsLabel(RegExp('^Places prises')), findsOneWidget);
      handle.dispose();
    });
  }
}
