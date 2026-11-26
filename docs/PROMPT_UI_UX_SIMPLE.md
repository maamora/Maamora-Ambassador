# PROMPT SIMPLE — Amélioration UI/UX « Maamora Ambassador »

> À coller dans Claude Code, à la racine du projet.

---

Tu es développeur Flutter senior et designer produit. Améliore l'UI et l'UX de l'application **Maamora Ambassador** (Flutter + Riverpod + Supabase) **sans casser la logique métier ni changer la charte graphique**.

## Règles absolues

**Couleurs** — charte uniquement : orange `#FB7701`, navy `#1A2433`, crème `#FAF5F0`. Aucun hex en dur : utilise les tokens `MaamoraColors`, `MaamoraSpacing`, `MaamoraRadius`, `MaamoraShadows`, `MaamoraDurations` de `lib/design_system/`. Le petit texte orange utilise `AppColors.primaryText` (contraste), jamais l'orange de marque.

**Ne touche jamais** : `supabase/`, `lib/features/**/providers/`, `lib/core/services/`, `lib/models/`, `pubspec.yaml`, `app_router.dart`, `app_colors.dart`, `maamora_tokens.dart`, `.env`. Aucune RPC, RLS, migration ni dépendance ajoutée.

**Logique métier intacte** : statut effectif des codes (expiré calculé à la lecture), téléphone 10 chiffres + normalisation `06…` → `+212…`, commissions et niveaux calculés côté serveur (l'UI affiche seulement), validation admin via RPC, `admins` par `auth.uid()`, filtres existants conservés, pull-to-refresh qui invalide les providers (ex. `pendingAmbassadorsCountProvider`).

**Textes** : FR et AR uniquement, via `context.tr('clé')`. Toute nouvelle clé ajoutée dans les **deux** maps de `lib/core/l10n/app_strings.dart`. Zéro texte en dur, zéro anglais. RTL : `EdgeInsetsDirectional` / `AlignmentDirectional`, jamais `left/right`.

## Ce qu'il faut améliorer

- **Hiérarchie** : un seul CTA primaire par écran, titre → contenu → action, espacements sur la grille 4/8/12/16/20/24.
- **États** : chaque écran de données gère loading (skeleton), empty (message + action), error (message + « Réessayer »), data (+ pull-to-refresh).
- **Lisibilité** : `Wrap` au lieu de `Row` pour les chips, `Flexible` + `maxLines`/`ellipsis` pour les textes longs, aucun overflow en FR comme en AR.
- **Accessibilité** : cibles ≥ 48 dp, `tooltip`/`Semantics` sur les icônes seules, pas d'info portée uniquement par la couleur, `textScaler` 1.3 sans casse.
- **Cohérence** : réutilise les composants de `lib/design_system/components/` ; si un composant manque, crée-le là, pas dans un écran.

Écrans concernés : onboarding (welcome, login, register, statuts), dashboard, partage, classement, portefeuille, groupes, communauté, retrait, profil, règles ; admin (navigation, dashboard, invitation, candidatures, liste ambassadeurs, détails, groupes, commissions, audit, profil).

## Méthode

1. **Audit d'abord** : liste les écrans et les problèmes (gravité P0/P1/P2), puis attends le feu vert.
2. Corrige **un écran à la fois**, sans refonte inutile, sans fichier hors périmètre.
3. Après chaque écran : `flutter analyze` doit afficher **No issues found!**
4. Commit par lot : `ui(<zone>): <action>`.

## Vérifications finales

```bash
flutter analyze
rg -n "0x[0-9A-Fa-f]{8}" lib --glob '!lib/design_system/**' --glob '!lib/shared/theme/**'
flutter build apk --release
```

Test sur téléphone réel : FR puis AR, taille de police 1.0 et 1.3, aucun overflow, tous les états vus, pull-to-refresh OK, parcours admin complet.

**Si une amélioration exige de changer une règle métier, une RPC, une RLS ou une couleur : arrête-toi et demande.**
