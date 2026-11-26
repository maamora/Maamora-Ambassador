# PROMPT — Refonte UI/UX « Maamora Ambassador » (Claude Code)

> Colle tout ce qui suit dans Claude Code, à la racine du dépôt `Maamora-Ambassador`.

---

## 0. RÔLE ET MISSION

Tu es **ingénieur Flutter senior + designer produit** sur l'application mobile **Maamora Ambassador** (package `ambassadors`, Flutter 3.x / Dart SDK ^3.12.1, Riverpod 2, Supabase, go_router).

Ta mission : **élever la qualité perçue de l'interface (UI) et de l'expérience (UX) de toute l'application**, écran par écran, sans **jamais** modifier la logique métier, le schéma Supabase, les providers, les RPC ou la charte graphique.

Tu travailles comme dans une codebase de production :
- Tu **audites avant de toucher au code**.
- Tu modifies **par petits lots vérifiables**, un écran ou un composant à la fois.
- Tu **prouves** chaque affirmation par une sortie de commande, pas par une opinion.
- Si une amélioration UX exige un changement métier → **tu t'arrêtes**, tu le documentes, tu ne l'implémentes pas.

Ton livrable final est une application **plus belle, plus lisible, plus rapide, plus accessible**, mais **fonctionnellement identique** : mêmes appels réseau, mêmes règles, mêmes statuts, mêmes montants.

---

## 1. CONTEXTE PRODUIT (à respecter)

**Maamora Ambassador** est l'app des ambassadeurs du programme Maamora. Parcours métier :

1. **Invitation** : un admin génère un code d'invitation (usage unique, avec expiration).
2. **Activation** : le candidat s'inscrit avec Google + code + téléphone → statut `pending`.
3. **Validation** : un admin approuve ou rejette la candidature.
4. **Groupes** : l'ambassadeur crée des groupes d'achat, les membres rejoignent, les groupes sont validés par l'admin.
5. **Commissions** : calculées **côté serveur** à partir des groupes validés.
6. **Portefeuille** : solde, demandes de retrait, historique des paiements.
7. **Niveaux** : Neutral → Bronze → Argent → Gold → Platine, avec seuils serveur.
8. **Parrainage / classement** : filleuls, leaderboard, récompenses.
9. **Audit** : les actions admin sensibles sont journalisées côté base.

**Deux applications dans une** :
- **Espace ambassadeur** (rôle `ambassador`)
- **Espace admin** (rôle `admin`, détecté via la table `admins` par `id = auth.uid()`)

---

## 2. STACK ET ARborescence RÉELLE

```
lib/
  main.dart
  core/
    constants/api_constants.dart
    l10n/app_strings.dart          # FR + AR (source unique des textes)
    l10n/locale_provider.dart
    navigation/navigation_service.dart
    services/                      # Supabase, deep links, état ambassadeur
  design_system/                   # ⚠️ SEUL endroit autorisé pour les couleurs
    maamora_tokens.dart            # MaamoraColors, Shadows, Radius, Spacing, Durations
    maamora_theme.dart
    maamora_icons.dart
    components/                    # maamora_card, maamora_button, tier_badge, states,
                                   # skeletons, stagger, count_up, points_meter,
                                   # maamora_toast, celebrations...
  shared/
    theme/app_colors.dart          # ⚠️ palette de base (charte)
    theme/app_theme.dart
    design/app_tokens.dart, app_motion.dart
    widgets/                       # app_button, app_text_field, bottom_nav_bar,
                                   # shared_app_bar, app_loader, design_kit, responsive...
    navigation/app_router.dart, app_routes.dart
  models/                          # ambassador, commission, deal_group, payout
  features/
    onboarding/  (welcome, login, register, status_screens)
    dashboard/   (dashboard_screen + widgets)
    share/       (share_screen, native_share_service, edit_message_bottom_sheet)
    leaderboard_rewards/ (leaderboard_screen, redemption_confirmation_sheet)
    wallet/      (wallet_screen, payout_method_bottom_sheet)
    groups/      (my_groups_screen, create_group_screen)
    community/   (community_screen)
    pickup/      (pickup_screen)
    profile/     (profile_screen)
    rules/       (rules_screen)
    admin/       (navigation, dashboard, invite_ambassador, ambassadors_pending,
                  ambassadors_list, ambassador_details, groups_pending,
                  commissions, audit_log, profile)
```

Autres dossiers : `supabase/migrations/` (SQL, **interdit**), `assets/images/`, `.env` (**interdit**, gitignored).

---

## 3. NON-NÉGOCIABLES — CE QUE TU NE TOUCHES JAMAIS

### 3.1 Fichiers interdits à la modification
- `supabase/**` (migrations, RLS, RPC, triggers) — **aucune exception**
- `lib/features/**/providers/**` — sauf ajout d'un **getter en lecture seule** validé et justifié
- `lib/core/services/**` — appels Supabase, deep links, état ambassadeur
- `lib/models/**` — modèles métier
- `lib/shared/navigation/app_router.dart` et `app_routes.dart` — routes existantes
- `.env`, `pubspec.yaml` (dépendances), `android/`, `ios/`
- `lib/shared/theme/app_colors.dart` et `lib/design_system/maamora_tokens.dart` : **on ne change AUCUNE valeur de couleur existante**

### 3.2 Couleurs (règle absolue)
- Charte : **orange `#FB7701`**, **navy `#1A2433`**, **crème `#FAF5F0`**.
- **Zéro hex en dur** hors `lib/design_system/` et `lib/shared/theme/`.
  Vérification obligatoire :
  ```bash
  rg -n "0x[0-9A-Fa-f]{8}" lib --glob '!lib/design_system/**' --glob '!lib/shared/theme/**'
  ```
  → doit renvoyer **0 ligne**.
- Utilise **uniquement** les tokens : `MaamoraColors.*`, `MaamoraShadows.*`, `MaamoraRadius.*`, `MaamoraSpacing.*`, `MaamoraDurations.*`, `MaamoraGradients.*`, `MaamoraTierStyle.*`.
- Surfaces : fond écran = `MaamoraColors.scaffold` (crème), cartes = `MaamoraColors.surface` (blanc), bordures = `MaamoraColors.border`.
- **Contraste** : l'orange de marque (`#FB7701`) est à ~2,7:1 sur blanc → **jamais pour du texte < 18 px**. Pour du petit texte orange, utilise `AppColors.primaryText` (`#BD5901`). Idem pour le gris : `AppColors.textMuted`.
- Pas de nouvelle teinte, pas de dégradé inventé, pas de mode sombre (les tokens dark existent mais **aucun écran ne les utilise** — n'en ajoute pas).

### 3.3 Logique métier — invariants à préserver à la lettre
1. **Statut d'un code d'invitation** : calculé **à la lecture** (`used_at`, `expires_at`). Si `expires_at < now` → « Expiré », même si `used_at` est null. **Ne jamais réécrire en base pour "corriger" l'affichage.**
2. **Tri des codes** : les codes actifs d'abord, puis expirés/consommés.
3. **Téléphone** : exactement **10 chiffres** saisis, `06…`/`07…` normalisés en `+2126…`/`+2127…`. Ne pas élargir la validation, ne pas changer le format d'affichage serveur.
4. **Validation de candidature** : passe **exclusivement** par la RPC admin (garde `is_admin()` + audit). Aucune écriture directe dans les tables.
5. **Commissions et niveaux** : calculés **côté serveur**. L'UI **affiche**, elle ne recalcule pas, n'arrondit pas autrement, ne dérive pas de seuils.
6. **Admin** : détecté via `admins` (`id = auth.uid()`, `is_active`). Ne pas remplacer par un flag client.
7. **Filtres** : la logique existante est conservée (ex. filtre niveau basé sur `AmbassadorData.levelLabel`). Tu peux changer **l'apparence** du filtre, pas sa sémantique.
8. **Pull-to-refresh** : doit **invalider les providers concernés**. Existant validé :
   `ref.invalidate(pendingAmbassadorsCountProvider)` après rafraîchissement de la liste des candidatures → le badge « X en attente » doit se mettre à jour.
9. **Sécurité** : RLS activé, écritures `anon` bloquées, `EXECUTE` admin restreint à `authenticated`. **Ne jamais** ajouter une requête qui contourne RLS ou élargit un accès.
10. **Garde-fous Dart** : ne supprime aucun `mounted`, `try/catch`, timeout, `if (!context.mounted) return;`. Tu peux les **ajouter**.

### 3.4 i18n — FR/AR uniquement
- Source unique : `lib/core/l10n/app_strings.dart` (`AppStrings._values`, maps `'fr'` et `'ar'`), lue via `context.tr('clé')`.
- **Aucune chaîne UI en dur** dans un widget (hors données dynamiques : noms, montants, dates formatées).
- Toute nouvelle clé doit être ajoutée **dans les deux maps**, avec la **même clé**. Le fallback est `'fr'`.
- **Pas d'anglais**. Pas de texte « lorem ipsum ». Pas de clé manquante (sinon la clé s'affiche brute).
- **RTL** : l'arabe se lit de droite à gauche. Utilise `EdgeInsetsDirectional`, `AlignmentDirectional`, `TextAlign.start/end`, `Directionality` implicite — **jamais** `left/right` en dur pour du contenu.
- Les libellés métier déjà traduits (statuts, niveaux, onglets admin) doivent le rester.

### 3.5 Ce que tu ne fais pas
- Pas de nouvelle dépendance (`pubspec.yaml` interdit sans accord explicite).
- Pas de renommage de classes/providers/routes publiques.
- Pas de « nettoyage » opportuniste d'un fichier hors périmètre.
- Pas de réécriture complète d'un écran quand un patch ciblé suffit.
- Pas de suppression de fonctionnalité, de bouton, d'onglet ou de garde.
- Pas de `Colors.red`, `Colors.black`, `Colors.white` en dur dans les écrans (utilise les tokens).
- Pas de `print()` laissé dans le code.
- Pas de commit mélangeant plusieurs phases.

---

## 4. STANDARDS UI/UX À APPLIQUER

### 4.1 Design system
- **Espacement** : échelle `4 / 8 / 12 / 16 / 20 / 24` (`MaamoraSpacing.xs…screen`). Padding horizontal d'écran = `MaamoraSpacing.screen` (20).
- **Rayons** : cartes 18, petites cartes 16, sheets 24, inputs 14, chips 999 (`MaamoraRadius`).
- **Ombres** : 2 niveaux seulement (`soft`, `raised`) + `glow` réservé aux cartes héros.
- **Typographie** : hiérarchie claire (titre écran / titre section / corps / légende). Une seule police de marque. Poids cohérents (titres 700–800, corps 400–500). Jamais plus de 3 tailles de texte par bloc.
- **Composants** : réutilise `MaamoraCard`, `MaamoraButton`, `TierBadge`, `States`, `Skeletons`, `Stagger`, `CountUp`, `PointsMeter`, `MaamoraToast`. Si un composant manque, ajoute-le **dans `lib/design_system/components/`**, jamais en local dans un écran.

### 4.2 Rythme visuel et hiérarchie
- **Un seul CTA primaire par écran** (orange plein). Les actions secondaires sont outlined/ghost.
- Titre d'écran → sous-titre → contenu → action. L'œil doit savoir où regarder en < 1 s.
- Groupe les informations par carte ; max 3 niveaux d'imbrication visuelle.
- Aligne tout sur une grille de 4 px. Aucun `SizedBox(height: 13)`.
- États vides : illustration/icône + phrase explicative + action (« Aucun groupe pour l'instant » + bouton « Créer un groupe »).

### 4.3 États obligatoires pour chaque écran de données
Chaque écran qui charge des données doit gérer **4 états**, distincts et testables :
1. **Loading** : skeleton (préféré) ou loader centré, jamais un écran blanc.
2. **Empty** : message + action.
3. **Error** : message clair + bouton « Réessayer » (clé `common_retry`).
4. **Data** : contenu + **pull-to-refresh** (`RefreshIndicator`) avec invalidation des providers.

### 4.4 Accessibilité
- Cible tactile ≥ **48×48 dp**. Icônes seules → `IconButton` avec `tooltip` + `Semantics`.
- `textScaler` jusqu'à **1.3** sans overflow ni texte coupé.
- Contraste : texte normal ≥ 4,5:1 ; grand texte ≥ 3:1.
- Chaque image décorative → `excludeFromSemantics` ; chaque image porteuse de sens → `semanticLabel`.
- Pas d'information portée **uniquement** par la couleur (statut = couleur **+** libellé/icône).
- Champs : `labelText` visible, `keyboardType` correct, `textInputAction`, focus order logique, erreurs sous le champ.

### 4.5 Performance perçue
- `const` partout où c'est possible ; `ListView.builder`/`SliverList` pour les listes ; pas de `Column` scrollable pour 20+ items.
- Évite les `setState` sur des sous-arbres entiers ; préfère extraire des widgets.
- Animations ≤ 300 ms pour les micro-interactions, courbes douces, pas d'animation qui bloque l'action.
- Images : `cacheWidth`/`cacheHeight` raisonnables, pas d'image plein écran non contrainte.

### 4.6 Corrections déjà validées à NE PAS casser (modèles à reproduire)
| Problème | Correctif validé |
|---|---|
| Overflow horizontal de chips/badges (ex. 24 px sur « Groupes », 44 px sur l'activation) | `Wrap(spacing:, runSpacing:)` au lieu de `Row` |
| Texte long qui pousse la ligne | `Flexible` + `Text(..., maxLines: 1, overflow: TextOverflow.ellipsis)` |
| Liste admin qui ne se rafraîchit pas | `RefreshIndicator` + `ref.invalidate(<provider concerné>)` |
| Badge « 0 en attente » figé | invalidation explicite du compteur après action |
| Code expiré affiché comme actif | statut **effectif** calculé à la lecture |
| Téléphone acceptant 12 chiffres | `FilteringTextInputFormatter.digitsOnly` + `LengthLimitingTextInputFormatter(10)` |
| Numéro `06…` rejeté | normalisation `06/07` → `+2126/+2127` avant envoi |

Reproduis ces patterns ailleurs **sans** modifier leur sémantique.

---

## 5. INVENTAIRE DES ÉCRANS ET OBJECTIFS UX

> Pour chaque écran : conserve la logique, améliore hiérarchie, espacement, états, lisibilité FR **et** AR.

### Espace ambassadeur
| Écran | Objectif UX |
|---|---|
| `welcome_screen` | Première impression : logo net, promesse claire, un CTA « J'ai un code », secondaire « Se connecter ». |
| `login_screen` | Google en action principale, texte légal/secondaire discret, état de chargement sur le bouton. |
| `register_screen` | Formulaire en étapes lisibles ; code d'invitation + téléphone (10 chiffres) ; erreurs inline ; message explicite si code expiré/consommé ; jamais de perte de saisie. |
| `status_screens` (pending/rejected/paused/unregistered) | Statut compréhensible sans jargon, prochaine action, contact/support. |
| `dashboard_screen` | Carte héros (solde/gains) → progression niveau → mes groupes. Chiffres animés (`CountUp`) mais **valeurs serveur inchangées**. |
| `share_screen` | Partage WhatsApp en 2 taps ; aperçu du message ; code copiable ; feedback de copie. |
| `leaderboard_screen` | Classement lisible, ma position mise en évidence sans casser le tri serveur. |
| `wallet_screen` | Solde, historique, demande de retrait : montants lisibles, statuts explicites, sheet de payout claire, pas de double soumission. |
| `my_groups_screen` / `create_group_screen` | Liste + empty state actionnable ; formulaire court, validation inline, bouton désactivé pendant l'envoi. |
| `community_screen` | Contenu informatif, sections aérées. |
| `pickup_screen` | Étapes de retrait, adresse/QR lisibles, action principale évidente. |
| `profile_screen` | Identité, niveau, code, langue, déconnexion. |
| `rules_screen` | Long texte : titres de section, espacement, lisibilité AR (line-height généreux). |

### Espace admin
| Écran | Objectif UX |
|---|---|
| `admin_navigation_screen` | Onglets traduits, badge de file d'attente visible, sous-onglets cohérents, pas d'overflow. |
| `admin_dashboard_screen` | KPI scannables (cartes stat), actions rapides, ordre stable. |
| `admin_invite_ambassador_screen` | Génération de code, statut effectif (actif/expiré/consommé), tri, partage WhatsApp, copie. |
| `admin_ambassadors_pending_screen` | File de validation : pull-to-refresh + invalidation du badge, actions approuver/rejeter avec confirmation, pas de double tap. |
| `admin_ambassadors_list_screen` | Recherche + filtres (niveau, statut) en `Wrap`, résultat lisible, empty state « aucun résultat ». |
| `admin_ambassador_details_screen` | Fiche dense mais hiérarchisée : identité, groupes, commissions, historique. |
| `admin_groups_pending_screen` | Chips de métadonnées en `Wrap`, ligne de titre `Flexible` + ellipsis, actions claires. |
| `admin_commissions_screen` | Tableau/montants alignés, totaux lisibles, filtres conservés. |
| `admin_audit_log_screen` | Journal chronologique lisible, acteur/action/cible, densité maîtrisée. |
| `admin_profile_screen` | Infos compte, déconnexion, cohérence visuelle avec le profil ambassadeur. |

---

## 6. MÉTHODE DE TRAVAIL IMPOSÉE

### Phase 0 — Audit (obligatoire, avant toute modification)
1. Lis `lib/design_system/**`, `lib/shared/theme/**`, `lib/shared/widgets/**` et les 2 maps de `app_strings.dart`.
2. Parcours **tous** les écrans listés en §5.
3. Produis un **tableau d'audit** :
   `Écran | Problème observé | Gravité (P0/P1/P2) | Correctif prévu | Fichiers concernés | Risque métier (oui/non)`
4. Identifie explicitement les **zones interdites** que tu ne toucheras pas.
5. **Arrête-toi et présente ce tableau** avant d'implémenter.

### Phase 1 → 5 — Implémentation par lots
- **Lot 1** : cohérence design system (espacements, rayons, ombres, tokens, composants partagés). Aucun changement de comportement.
- **Lot 2** : espace ambassadeur (onboarding → dashboard → wallet → groupes → partage → profil → règles).
- **Lot 3** : espace admin (navigation → dashboard → invitation → candidatures → groupes → commissions → audit).
- **Lot 4** : i18n / RTL / AR (clés manquantes, alignements directionnels, overflow en arabe).
- **Lot 5** : accessibilité (cibles 48 dp, contrastes, `Semantics`, `textScaler` 1.3) + performance perçue.

Règles de lot :
- Un écran = un diff relisible. Pas de fichier hors périmètre.
- Ajoute les clés i18n **avant** de les utiliser.
- Après **chaque** écran : `flutter analyze` doit rester propre.
- Un commit par lot, en français, format `ui(<zone>): <action>`.
- Ne passe au lot suivant qu'une fois le précédent vérifié.

### Phase 6 — Analyse globale finale (obligatoire)
Avant de déclarer terminé, repasse **toutes** les fonctionnalités et réponds point par point :
1. Invitation → activation → validation : intact ?
2. Codes : statut effectif, tri, partage : intact ?
3. Téléphone 10 chiffres + normalisation : intact ?
4. Groupes (création, adhésion, validation) : intact ?
5. Commissions / wallet / retraits : montants et statuts identiques ?
6. Niveaux / parrainage / classement : seuils et libellés identiques ?
7. Admin : rôles, garde `is_admin`, audit : intact ?
8. RLS / RPC / migrations : **aucune** modification ?
9. i18n : 100 % des clés utilisées existent en FR **et** AR ?
10. Couleurs : 0 hex hors design system ?

Si une réponse est « je ne sais pas », **ce n'est pas terminé** : vérifie.

---

## 7. COMMANDES DE VÉRIFICATION (à exécuter et à coller en preuve)

```bash
# 1. Analyse statique — doit afficher "No issues found!"
flutter analyze

# 2. Aucune couleur en dur hors design system — doit renvoyer 0 ligne
rg -n "0x[0-9A-Fa-f]{8}" lib --glob '!lib/design_system/**' --glob '!lib/shared/theme/**'

# 3. Pas de couleurs Material en dur dans les écrans
rg -n "Colors\.(red|blue|green|black|white|grey|orange|amber)" lib --glob '!lib/design_system/**' --glob '!lib/shared/theme/**'

# 4. Pas de texte UI en dur (heuristique : chaînes longues dans un widget)
rg -n "Text\(\s*['\"][A-Za-zÀ-ÿ]{6,}" lib/features

# 5. Clés i18n utilisées vs définies
rg -o "tr\('([a-z0-9_]+)'\)" lib | sort -u

# 6. Tests (si présents)
flutter test

# 7. Build de contrôle
flutter build apk --release
```

**Critères d'acceptation (Definition of Done)** :
- `flutter analyze` → **No issues found!**
- Requêtes 2, 3, 5 → **0 résultat problématique** (toute exception doit être justifiée par écrit).
- Build release OK.
- Aucun fichier de `supabase/`, `providers/`, `models/`, `core/services/` modifié (vérifiable via `git diff --stat`).
- Test manuel sur appareil réel **Samsung SM-A536B** (1080×2400) :
  - FR puis AR, `textScaler` 1.0 **et** 1.3 ;
  - aucun overflow (bandeau jaune/noir) ;
  - tous les états (loading / empty / error / data) vus ;
  - pull-to-refresh fonctionnel + badge à jour ;
  - parcours admin complet sur les comptes de test.

---

## 8. FORMAT DE TES RÉPONSES

À chaque lot, réponds exactement dans cet ordre :

1. **Ce que j'ai changé** — écran par écran, en une ligne par changement.
2. **Ce que je n'ai pas touché** — providers, RPC, RLS, modèles, routes.
3. **Preuves** — sorties de commandes (analyze, rg, build).
4. **Risques / points à valider** — ce qui demande une décision humaine.
5. **Prochain lot** — ce que tu proposes d'enchaîner.

Jamais de « c'est fait » sans sortie de commande à l'appui.

---

## 9. CRITÈRES DE REFUS (STOP immédiat)

Tu t'arrêtes et tu demandes validation si :
- un correctif UX exige de changer une règle métier, un statut, un calcul ou un seuil ;
- il faut modifier une RPC, une policy RLS, un trigger ou une migration ;
- il faut ajouter une dépendance ;
- il faut changer une couleur de la charte ;
- une clé i18n n'existe pas et le texte métier n'est pas évident à traduire ;
- le correctif risque de modifier un montant, un statut ou un accès.

Dans ces cas : **documente précisément** le besoin, l'impact, et propose 2 options. Ne force pas.

---

## 10. TON PREMIER MESSAGE

Commence par :
1. Confirmer que tu as lu et compris les invariants (§3).
2. Lister les fichiers que tu vas lire pour l'audit.
3. Produire le **tableau d'audit complet** (§6, Phase 0).
4. Attendre le feu vert avant d'écrire la moindre ligne de code.

**Rappel final : l'objectif est la beauté et la clarté, jamais au prix d'un comportement. Une app magnifique qui casse un calcul de commission est un échec.**
