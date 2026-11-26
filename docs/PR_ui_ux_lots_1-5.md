## Refonte UI/UX — lots 1 à 5 (présentation uniquement)

Cinq commits, un par lot, sans aucune modification de la logique métier :
le diff ne touche ni `supabase/`, ni les `providers/`, ni `core/services`,
ni les `models`, ni les routes, ni `pubspec.yaml`, ni `android/` / `ios/`.

| Commit | Lot |
|---|---|
| `ac2cfc6` | Design system : tokens (alias, pas de nouvelle teinte), états i18n, accessibilité des composants, respect du « mouvement réduit » |
| `24d9963` | Espace ambassadeur : 4 états par écran, pull-to-refresh, i18n, tokens |
| `7735002` | Espace admin : confirmations, garde double tap, i18n, états |
| `628c467` | RTL : alignements directionnels + test de rendu AR/FR à 1.3 |
| `cabee21` | Accessibilité : navigation nommée, cibles 48dp, grille 4px, tests |

### Corrections de bugs à vérifier en revue
- **Portefeuille** : une apostrophe parasite affichait toutes les commissions avec un signe « − ». Seul le signe affiché change ; les montants sont identiques.
- **Sheets** (retrait, partage, édition) : les SnackBars s'affichaient derrière la bottom sheet (« RIB incomplet », « CIN requise » invisibles) → `MaamoraToast`.
- **Candidatures admin** : pas de confirmation et double tap possible sur « Valider » (RPC envoyée deux fois) → confirmation + boutons désactivés pendant l'appel ; gardes `mounted` ajoutées après `await`.
- **Groupes admin** : garde contre la double assignation de commission.
- **Textes anglais visibles** remplacés par des clés FR/AR : écrans de statut, « Accept / Reject / Phone », « filled », statuts du portefeuille (`PAYABLE`…), niveau (« Silver » affiché en arabe).
- **Barre de navigation principale** : icônes seules sans nom pour TalkBack → libellés + état sélectionné.
- **RTL** : les dégradés directionnels dans un `ShaderMask` plantaient sans `textDirection` — corrigé et couvert par un test (vérifié en retirant le correctif : le test échoue).

### Invariants vérifiés (`git diff -w 9c9c0b8..HEAD`)
- RPC `verify_invite_code_status`, `admin_set_ambassador_status`, `admin_create_invite_code`, `admin_create_payout` : paramètres identiques (seul le retour à la ligne change).
- Téléphone : formatters 10 chiffres et normalisation `+212` intacts (seul l'indice affiché devient « 06 XX… »).
- Statut effectif et tri des codes, filtres de la liste admin, `toStringAsFixed` des montants, `commissionRate` : inchangés.
- Les `ref.invalidate` ajoutés sont tous dans des rafraîchissements volontaires (pull-to-refresh / Réessayer).

### Preuves
- `flutter analyze` → **No issues found!**
- `test/design_system_rtl_test.dart` → **7/7** (AR/FR, textScaler 1.3, 360dp, mouvement réduit, cible 48dp, sémantique).
- `flutter build apk --release` → OK (60,9 Mo).
- 0 couleur hex hors design system ; `Colors.*` en dur 227 → 5 (écrans communauté/retrait, gelés — voir D2).
- i18n : FR 511 / AR 511, 0 doublon, 0 clé utilisée manquante.

### Points connus
- `test/widget_test.dart` échoue **déjà sur master** (cherche « Sign Up Screen », placeholder disparu) — non modifié ici.
- Test manuel sur Samsung SM-A536B (FR/AR, textScaler 1.0 et 1.3, parcours admin) **non encore effectué**.
- Décisions produit en attente, volontairement non traitées :
  D1 valeurs factices du dashboard admin · D2 écrans communauté/retrait en données factices ·
  D3 niveau Platine absent des règles · D4 recherche dans la liste ambassadeurs ·
  D5 gris accessible (`textMuted`) · D6 texte du bouton WhatsApp ·
  D7 texte « Starter 4 % » de l'écran de bienvenue · D8 boutons de partage sans action.

🤖 Generated with [Claude Code](https://claude.com/claude-code)
