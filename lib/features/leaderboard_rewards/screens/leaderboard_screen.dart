import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/services/mock_data_service.dart';
import '../../../models/models.dart';
import '../../../shared/widgets/tier_badge.dart';

// Dev 4 — Leaderboard (converti depuis le mockup Stitch "Ambassador
// Leaderboard").
//
// STRUCTURE : ce widget vit dans l'IndexedStack de MainNavigationScreen
// (shared/navigation/main_navigation_screen.dart), qui fournit déjà
// SharedAppBar (titre "LEADERBOARD") et SharedBottomNavBar. Contrairement
// au mockup Stitch — qui incluait son propre header "AMBASSADOR" et sa
// propre bottom nav — cet écran ne doit rendre QUE le contenu, sinon on se
// retrouve avec deux barres superposées. Header/bottom-nav du mockup ont
// donc été retirés, pas oubliés.
//
// DONNÉES : MockDataService.mockLeaderboard / mockCurrentAmbassador (déjà
// trié par points), même convention que le reste de l'app en attendant
// Supabase. TODO(Dev4): brancher sur une vue "leaderboard_view" + Supabase
// Realtime (brief feature #5).
//
// ── 4 points signalés plutôt que devinés (voir détail dans la réponse) ──
// 1) Couleurs/police : shared/theme/app_colors.dart + app_theme.dart
//    existent et sont documentés comme LA palette officielle, mais les
//    écrans réellement livrés (dashboard_screen.dart, shared_app_bar.dart,
//    bottom_nav_bar.dart) ne les utilisent pas : ils redéclarent des
//    Color(0xFF...) locales qui correspondent aux tokens Material 3 du
//    mockup Stitch (primary, primary-container, etc.), + google_fonts
//    (Plus Jakarta Sans / Inter, qui correspond au mockup — AppTheme, lui,
//    n'a pas de fontFamily et retombe sur la police système). J'ai suivi ce
//    2ᵉ pattern (celui réellement à l'écran, à côté duquel ce tab
//    s'affiche) pour rester cohérent visuellement avec Dashboard — mais les
//    deux systèmes ne sont PAS synchronisés (ex: primary = #9A4600 ici vs
//    #CB8A2E dans AppColors). Ça vaudrait le coup de trancher en équipe.
// 2) Badges de tier (rang 4+) : le mockup affiche "Gold Ambassador" /
//    "Silver Ambassador" / "Rising Star", un vocabulaire qui n'existe dans
//    aucun modèle. Le seul système de tier réel est l'enum Tier
//    (bronze/silver/gold/platinum) + shared/widgets/tier_badge.dart,
//    explicitement marqué "ne dupliquez pas, réutilisez-le". J'ai donc
//    réutilisé TierBadge (calculé depuis les points réels via
//    TierInfo.fromPoints) plutôt que d'inventer un 2ᵉ vocabulaire de tier
//    sans donnée derrière.
// 3) Avatars : Ambassador n'a pas de champ avatarUrl, et il n'existe pas de
//    composant Avatar réutilisable pour un item de liste (seul
//    SharedAppBar a un avatar, pour l'utilisateur courant dans le header).
//    Fallback "initiales" partout (même esprit que le fallback de
//    SharedAppBar quand avatarUrl est null). Pour de vraies photos il
//    faudra ajouter avatarUrl à Ambassador (fichier contrat — accord
//    d'équipe requis) + un bucket Supabase Storage.
// 4) Décor pur (non fonctionnel) volontairement laissé de côté : tilt 3D
//    du podium, glow/blur derrière l'avatar du 1er, effets hover/scale —
//    CSS-only, pas dans la liste de requirements, et fragiles à répliquer
//    en Flutter pour un gain visuel marginal.

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final leaderboard = MockDataService.mockLeaderboard;
    final currentId = MockDataService.mockCurrentAmbassador.id;
    final hasPodium = leaderboard.length >= 3;
    final podium = hasPodium ? leaderboard.take(3).toList() : <Ambassador>[];
    final rest = hasPodium ? leaderboard.sublist(3) : leaderboard;

    return Scaffold(
      backgroundColor: _surface,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            Center(
              child: Column(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.emoji_events, color: _primaryContainer, size: 22),
                      const SizedBox(width: 8),
                      Text(
                        'Leaderboard',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: _onBackground,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Top Performers this Month',
                    style: GoogleFonts.inter(fontSize: 14, color: _onSurfaceVariant.withOpacity(0.8)),
                  ),
                ],
              ),
            ),
            if (hasPodium) ...[
              const SizedBox(height: 28),
              _Podium(podium: podium, currentId: currentId),
            ],
            const SizedBox(height: 28),
            ...List.generate(rest.length, (index) {
              final rank = index + (hasPodium ? 4 : 1);
              final ambassador = rest[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _RankRow(
                  rank: rank,
                  ambassador: ambassador,
                  isCurrent: ambassador.id == currentId,
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _Podium extends StatelessWidget {
  const _Podium({required this.podium, required this.currentId});

  final List<Ambassador> podium;
  final String currentId;

  @override
  Widget build(BuildContext context) {
    final first = podium[0];
    final second = podium[1];
    final third = podium[2];
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _PodiumColumn(
          ambassador: second,
          rank: 2,
          medal: '🥈',
          avatarSize: 64,
          avatarBorder: const Color(0xFFC0C0C0),
          barHeight: 96,
          barColors: const [_surfaceContainerHigh, _surfaceContainer],
          isCurrent: second.id == currentId,
        ),
        const SizedBox(width: 10),
        _PodiumColumn(
          ambassador: first,
          rank: 1,
          medal: '🥇',
          avatarSize: 80,
          avatarBorder: const Color(0xFFFFD700),
          barHeight: 140,
          barColors: const [_primaryContainer, _primary],
          isCurrent: first.id == currentId,
        ),
        const SizedBox(width: 10),
        _PodiumColumn(
          ambassador: third,
          rank: 3,
          medal: '🥉',
          avatarSize: 64,
          avatarBorder: const Color(0xFFCD7F32),
          barHeight: 80,
          barColors: const [_surfaceContainer, _surfaceVariant],
          isCurrent: third.id == currentId,
        ),
      ],
    );
  }
}

class _PodiumColumn extends StatelessWidget {
  const _PodiumColumn({
    required this.ambassador,
    required this.rank,
    required this.medal,
    required this.avatarSize,
    required this.avatarBorder,
    required this.barHeight,
    required this.barColors,
    required this.isCurrent,
  });

  final Ambassador ambassador;
  final int rank;
  final String medal;
  final double avatarSize;
  final Color avatarBorder;
  final double barHeight;
  final List<Color> barColors;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isCurrent)
            Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: _primary, borderRadius: BorderRadius.circular(30)),
              child: Text(
                "C'est toi !",
                style: GoogleFonts.inter(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              _InitialsAvatar(name: ambassador.name, size: avatarSize, borderColor: avatarBorder),
              Positioned(
                bottom: -4,
                right: -2,
                child: Container(
                  width: rank == 1 ? 30 : 24,
                  height: rank == 1 ? 30 : 24,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 4, offset: const Offset(0, 2)),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(medal, style: TextStyle(fontSize: rank == 1 ? 18 : 14)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: 86,
            child: Text(
              ambassador.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w700,
                fontSize: rank == 1 ? 15 : 13,
                color: _onBackground,
              ),
            ),
          ),
          Text(
            '${ambassador.points} pts',
            style: GoogleFonts.inter(color: _primaryContainer, fontWeight: FontWeight.w700, fontSize: 12),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            height: barHeight,
            padding: const EdgeInsets.only(top: 10),
            alignment: Alignment.topCenter,
            decoration: BoxDecoration(
              gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: barColors),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Text(
              '$rank',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: Colors.white.withOpacity(0.35),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RankRow extends StatelessWidget {
  const _RankRow({required this.rank, required this.ambassador, required this.isCurrent});

  final int rank;
  final Ambassador ambassador;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    final tier = TierInfo.fromPoints(ambassador.points);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isCurrent ? _primaryContainer.withOpacity(0.06) : _surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isCurrent ? _primaryContainer : _outlineVariant.withOpacity(0.4),
          width: isCurrent ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 16, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            child: Text(
              '$rank',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16, color: _onSurfaceVariant.withOpacity(0.6)),
            ),
          ),
          const SizedBox(width: 12),
          _InitialsAvatar(name: ambassador.name, size: 56),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isCurrent ? '${ambassador.name} (toi)' : ambassador.name,
                  style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 15, color: _onBackground),
                ),
                const SizedBox(height: 4),
                TierBadge(tier: tier),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${ambassador.points}',
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 20, color: _primary),
              ),
              Text(
                'POINTS',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: _onSurfaceVariant.withOpacity(0.6),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InitialsAvatar extends StatelessWidget {
  const _InitialsAvatar({required this.name, required this.size, this.borderColor});

  final String name;
  final double size;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _secondaryContainer,
        border: borderColor != null ? Border.all(color: borderColor!, width: 3) : null,
      ),
      alignment: Alignment.center,
      child: Text(
        _initials(name),
        style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: size * 0.34, color: _secondary),
      ),
    );
  }
}

String _initials(String name) {
  final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
  if (parts.isEmpty) return '?';
  if (parts.length == 1) return parts[0].substring(0, 1).toUpperCase();
  return (parts[0].substring(0, 1) + parts[1].substring(0, 1)).toUpperCase();
}

// Tokens Material 3 du mockup Stitch — répliqués ici à l'identique de
// dashboard_screen.dart / shared_app_bar.dart (voir point signalé #1
// ci-dessus : app_colors.dart existe mais n'est pas ce que ces écrans
// utilisent réellement).
const Color _primary = Color(0xFF9A4600);
const Color _primaryContainer = Color(0xFFFB7701);
const Color _surface = Color(0xFFFFF8F5);
const Color _surfaceContainerLowest = Color(0xFFFFFFFF);
const Color _surfaceContainerHigh = Color(0xFFFBE3D8);
const Color _surfaceContainer = Color(0xFFFFEADF);
const Color _surfaceVariant = Color(0xFFF6DED2);
const Color _onBackground = Color(0xFF251912);
const Color _onSurfaceVariant = Color(0xFF584236);
const Color _outlineVariant = Color(0xFFE0C0B0);
const Color _secondary = Color(0xFF555F70);
const Color _secondaryContainer = Color(0xFFD6E0F5);
