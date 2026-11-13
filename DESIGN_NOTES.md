# DESIGN NOTES — Maamora Ambassador App Refonte DS

> Refonte complète du Design System **sans toucher à la logique métier**
> (attribution des points, appels Supabase/Firebase, providers, attribution des commissions = intacts).
> Charte : orange `#FB7701` · navy `#1A2433` · crème `#FAF5F0`. Aucune autre couleur : tout est dérivé (teintes/opacités/dégradés) ou token centralisé.

---

## 1. Architecture — `lib/design_system/`

Barrel unique : `import '.../design_system/design_system.dart';`

| Fichier | Contenu |
|---|---|
| `maamora_tokens.dart` | `MaamoraColors` (charte), `MaamoraDarkColors` (prêts, non activés), `MaamoraShadows` (2 niveaux + glow), `MaamoraRadius`, `MaamoraDurations` (stagger 90ms), `MaamoraGradients` (hero + métaux Bronze/Silver/Gold/Platinum dérivés des couleurs de tier), `MaamoraTierStyle.ofLevel(index)` |
| `maamora_theme.dart` | `MaamoraTheme.light()` — construit sur `AppTheme.lightTheme` (CTA 54px, Cairo, radius intacts) + scaffold crème, focus input unifié, `screenTitle/support/heroMetric/eyebrow/sectionHeader` |
| `maamora_icons.dart` | Une seule famille : **Lucide** (`lucide_icons_flutter` v4) — poids 200 (outline, repos) / 500 (accent) ; pictos filled maison `MaamoraFilledIcon` (house/trophy/share/wallet) pour la nav ; `MaamoraBolt` |
| `components/` | `maamora_button` (6 variants, press-scale 0.96 + haptic + loader morph), `maamora_card` (+ GlassCard blur), `tier_badge` (métallique, shine sweep 4s), `points_meter` (jauge liquide + shimmer drift), `count_up` (CountUpText/Percent/Points, easeOutExpo 1.2s), `maamora_toast` (overlay top, auto-dismiss 2.4s), `stagger` (cascade 90ms, transform/opacity), `celebrations` (particules hero + confetti burst), `celebration_overlay` (moment cinématique tier-up), `states` (Empty/Error), `skeletons` (ShimmerBox/Row/List/Hero) |

**Règle d'or écran** : jamais de hex en dur ; les tokens existants locaux (`_primary`, `_cardBorder`…) sont réalignés sur `MaamoraColors.*`. Vérification finale : **0 hex en dur en dehors de `design_system/` et `shared/theme/`** (scan regex sur tous les `Color(0x…)`).

### Tokens dérivés ajoutés (tous documentés comme lerp/opacité de la charte)
- Statuts : `successEdge` `#88C4A0` · `dangerEdge` `#E8A8A4` · `warningEdge` `#E8C070` · `dangerDeep` `#8B1E1A` · `warningDeep` `#7A4800` — bordures/foreground des badges admin.
- Disabled : `disabledBg #EEEEEE` · `disabledBorder #BBBBBB` · `disabledFg #555555` (navy × white 94/78/70%).
- Tiers : `tierGold/Silver/Bronze/Platinum` (palette officielle des niveaux).
- Accents : `infoBlue #1A5FAD` + `infoBlueSoft #D6E8FF` (navy lerpé) · `peach #FFD4A8` · `whatsapp #25D366` / `whatsappLight #3EDC81` (marque tierce conservée) · `primaryHalo #2EFB7701` + `primaryHaloEnd #00FB7701` (halo wallet, alpha 18%→0).

---

## 2. Par écran

### Splash (nouveau) — `shared/widgets/maamora_splash_screen.dart`
- Logo disque blanc + glow orange respirant, pivot `easeOutBack`, barre orange.
- Route `/splash` (visuelle uniquement — la logique d'auth du router est intacte, redirect vers `/login`).

### Nav bottom — `shared/widgets/bottom_nav_bar.dart`
- Crossfade outline Lucide 200 → picto filled (CustomPaint) + spring scale 1.15×.
- Bouton Share central : cercle orange, haptic, glow amplifié à l'actif.
- Haptics : `lightImpact` sur tap, `selectionClick` sur changement d'onglet.

### Dashboard (Home)
- Fond crème, stagger 90ms sur toutes les sections, skeleton shimmer pendant loading, `MaamoraErrorState` + retry.
- **Ticker équipe** : marquee des derniers gains réels (walletProvider → commissions), transform-only 60fps.
- Stats : jauge `PointsMeter` liquide + `CountUpPercent`.
- `_TotalEarnedCard` : GradientHeroCard `countUp: true` (50px CountUp) + particules dérivées charte.
- Confetti overlay quand un membre rejoint le groupe.

### Share
- Titre « Partage ton lien », carte **flip 3D** : face navy (photo/style ambassadeur) ↔ dos orange (code ambassadeur + QR + copie).
- Copie → `MaamoraToast.success` (plus de SnackBar système).
- Bouton WhatsApp → `MaamoraButton(variant: whatsapp)`. Le partage natif (`NativeShareService`) est conservé.

### Wallet
- Hero solde : halo radial animé, particules, **CountUp 50px** « ARRIVE CE VENDREDI + X DH », badge ID vérifié.
- Loading → skeleton shimmer `_WalletSkeleton` ; erreur → `MaamoraErrorState` + retry (invalidate `walletProvider`).
- **Timing des gains** : carte timeline, rows stagger par `Interval` (0.10 → 0.85), icônes Lucide (shoppingBag / users / userPlus / landmark / banknote), montants CountUp (+/−), statut VOIDED = opacity 0.6 + fond surfaceLow (règle dérivée).
- **Méthode de paiement** : pulse 1.0→1.07 en boucle sur le disque quand aucune méthode configurée (« À faire ») + bordure orange glow ; badge « Configuré » vert charte quand OK. Ouverture `PayoutMethodBottomSheet` inchangée.

### Leaderboard
- **Podium top 3** : Or (centre, 88px) / Argent (gauche, 64px) / Bronze (droite, 52px) — hauteurs différentes + flottement sinusoïdal 3px déphasé (0 / 0.3 / 0.6s), pédestaux dégradés dérivés des couleurs de tier.
- Liste : rows stagger avec CountUp des membres, chip rang colorée médaille, badge de niveau métallique (`LevelBadge` hérite de TierBadge DS).
- « Toi » épinglé : slide-in `easeOutCubic` + **halo doré rotatif** (SweepGradient 4s) autour de l'avatar, nudge « X de plus pour dépasser Prénom ».
- Loading → `_LeaderboardSkeleton` (podium + rows shimmer) ; erreur → `MaamoraErrorState` ; vide → `MaamoraEmptyState`.
- Toggle Ma ville / National conservé (+ haptic).

### Welcome (activation)
- **MaamoraConfetti** one-shot à l'arrivée + haptic medium.
- Icône de succès remplacée par : disque gradient orange + check Lucide 500, sortie `easeOutBack`.
- Stagger sur tous les blocs ; MaamoraCard / MaamoraButton (whatsapp / outlined / ghost).

### Login & Register
- `AppTextField` : **focus glow** — bordure orange 1.6px + halo orange doux via AnimatedContainer, icône qui vire au brand au focus.
- `AppButton` : press-scale 0.96 + haptic, le reste API identique (variants filled/outlined/dark).

### Profile
- Badge métallique hérité via `LevelBadge → TierBadge`.
- Tag « Verified » : chip `successSoft`/`successOn` (plus de hex 0xFFDCFCE7/0xFF166534).
- Icône WhatsApp codepoint fantôme `\u{F0002}` **supprimée** → Lucide `messageCircle` (famille unique).

### Rules (Niveaux & Règles)
- Harmonisé sur le **modèle réel** : Neutral 3% (inscription + NDA) · Bronze 6% (6 commandes) · Silver 9% (27 commandes/mois) · Gold 10% (6 groupes 60+ membres). *Les seuils/métier n'ont pas été modifiés — affichage uniquement.*
- Cartes : disque dégradé métallique par tier (`MaamoraTierStyle`), `TierBadge` compact pour chaque nom, « Bon à savoir » en `primarySoft`.

### Groups / Pickup / Community
- Tokens réalignés (ex-`#251912`/`#584236`/`#E0C0B0` → navy/secondary/border de la charte ; `#198754` → `success`…).
- `my_groups` : EmptyState → `MaamoraEmptyState` français, danger charte, thumbnail → `creamIntense`.

### Admin
- Re-style **léger** (décision validée) : mapping exhaustif des hex → tokens charte dans `features/admin/**` (12 fichiers : 14 écrans/widgets de navigation, dashboard, listes, invite, détails, audit, commissions, `admin_stat_card`, `admin_status_badge` ×44 substituées), imports DS insérés, zéro animation dédiée, zéro logique touchée.

### Widgets partagés réalignés (passe de complétion)
- `design_kit.dart` : dégradés hero → `MaamoraGradients.heroOrange` / `heroNavy` (supprime les listes de couleurs dupliquées) ; fond d'icône `_IconTile` → `primarySoft`.
- `app_loader.dart` : base du painter shimmer → `surfaceLow` (ex `#ECE8E3`).
- `google_button.dart` : catalogue → `textPrimary` (ex `#1A2433`).
- `shared_app_bar.dart` : bordures du header → `disabledBg` / `borderStrong` (ex `#EDEDED` / `#E3E3E3`).
- `wallet/widgets/payout_method_bottom_sheet.dart` : fill `surfaceLow`, bordure `borderStrong`, hints `textFaint` (ex `#AAAAAA`).
- `share/widgets/edit_message_bottom_sheet.dart` : accent → `primary` (ex `#E65100`).
- Scenes onboarding restylées : `register_screen` (+9), `login_screen`, `status_screens`, `redemption_confirmation_sheet`, `leaderboard_screen`.

---

## 3. Moment cinématique — passage de tier

`TierCelebrationWatcher` (`shared/widgets/`), branché dans `MainNavigationScreen` :
1. Écoute le changement d'`AmbassadorLevel` via riverpod (`ref.listen` → select level.index).
2. Compare à `maamora_last_seen_level` (SharedPreferences) — no re-trigger bis.
3. Overlay full-screen : voile crème/glow radial orange, **médaille métallique** (dégradé du tier + glow), «bienvenue au niveau» + **nom du tier lettre par lettre** (stagger glyph), confetti burst.
4. Auto-dismiss ~3.6–4.2s. Aucune écriture de logique métier.

---

## 4. Règles 60 FPS
- Toutes les animations = transform (translate/scale/rotate) + opacity uniquement.
- Shimmer : bibliothèque `shimmer` (couleur de surface, pas de redraw coûteux).
- Marquee/pulse/float : `AnimationController.repeat`endants sur `FractionalTranslation` / `Transform`.
- Stagger : `TweenAnimationBuilder` + `Interval` (zéro controller par row pour les listes dynamiques).

## 5. Gates de validation (état final)
- `flutter analyze --no-fatal-infos` : **No issues found!** (après chaque passe de substitution — incl. re-run `fix_const.py` pour purger les `const MaamoraColors.x;` orphelins générés par les scripts).
- Scan encodage UTF-8 sur tout `lib/` : **0 fichier corrompu**.
- Scan hex `Color(0x…)` (tous alphas) hors `design_system/` et `shared/theme/` : **0 hit**.
- Logique métier intacts : providers, appels API Supabase/Firebase, attribution des points/commissions — restyle appliqué uniquement sur couche visuelle.

## 6. Vague i18n FR/AR complète (chantier « traduction »)
- `app_strings.dart` : **FR + AR uniquement** (l'anglais a disparu, fallback → `fr`). ~230 clés préfixées par écran (nav/login/dash/share/edit/wallet/payout/reg/welcome/status/rules/profile/groups/cg/pickup/community/lb + common_error…), placeholders `{n}`/`{name}`/`{city}`/`{when}` remplacés par `args`.
- Passe script (~190 remplacements sur 13 écrans) + câblage manuel des littéraux dynamiques : montants `' DH'` → `درهم`, erreurs de code d'invitation, `lb_pass_hint`, `payout_rib_len`, groupes `{a}/{b}`, pickup, community (prototype FR/AR), profile (langue affichée = langue réelle via `localeProvider`), tier names + `rules_intro`.
- Banques & opérateurs cash (CIH, Attijari, Wafacash…) = noms propres NON traduits ; données stockées non traduites (`kMoroccanBanks`), affichage traduit uniquement (« Autre banque » à l'écran, code `999`).
- Message par défaut de partage + template « Standard » du sheet d'édition passés en français (tutoiement ; les templates Darija/Français restent des contenus choisi au choix de l'utilisateur).

## 7. Navbar dynamique
- Lumière orange **coulissante** derrière l'onglet actif : `AnimatedAlign` (easeOutCubic, duration ×3) dans un `LayoutBuilder` ; x = `(index+0.5)×(w/4)−band/2`, band = `w/4×0.66`, **miroir RTL** pour l'arabe.
- Labels : `TweenAnimationBuilder` sur la couleur (textSecondary → primary) + weight 600→800.
- Le cercle orange flottant de Share est conservé au-dessus de la bande.

## 8. Payout sheet — robustesse layout
- Hauteur cappée dynamiquement à `size.height − viewInsets.bottom − 32` : le header reste visible même clavier ouvert.
- Champ CIN : `TextInputFormatter` alphanumérique + uppercase forcé (affichage seul, la donnée envoyée est inchangée).
- Structure vérifiée : `mainAxisSize.min` + `Flexible(SingleChildScrollView)`, dropdowns `isExpanded`, `Expanded` sur tous les rows à texte long — pas d'overflow possible à petit écran.

## 9. Optimisations globales (passe ④)
- `flutter analyze` (warnings + infos) : **No issues found!** sur tout le repo.
- Scan des fichiers morts : 3 candidats non référencés (`admin_stat_card.dart`, `redemption_confirmation_sheet.dart`, `app_text_field.dart`) — conservés (à valider avant suppression, `redemption_…` restylé récemment).
- Micro-rebuilds observés (acceptables) : `setState` par frappe RIB dans le payout sheet (rebuild du sheet entier, pas d'impact mesurable) ; voir suggestions futures pour la suite.

---

## 10. Suggestions futures (mises à jour)
1. Activer `MaamoraDarkColors` (thème sombre prêt, tokens déjà dérivés).
2. Ajouter `assets/animations/celebration.json` (Lottie) — `MaamoraLottie` a déjà un `errorBuilder` fallback painter-only.
3. Rangs National/City perso dans les stats du profile (data dispo via leaderboardProvider).
4. Haptics intensifs optionnels sous setting (l'économie de batterie).
5. Vague 2 i18n : écrans **admin** (badges Paid/Failed/Open/Closed/unused/used/expired/revoked/pending/active/rejected/suspended + tous les écrans admin restent à traduire FR/AR).
6. Fonts locales (Cairo + JetBrainsMono en assets) pour supprimer la dépendance réseau `google_fonts` au premier lancement.
