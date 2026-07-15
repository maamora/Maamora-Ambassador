import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/services/mock_data_service.dart';
import '../../../models/models.dart';

// Dev 4 — Ambassador League Leaderboard. Embedded in MainNavigationScreen's
// IndexedStack, so no own AppBar/BottomNav.

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({
    super.key,
    this.promotionZoneSize = 5,
    this.demotionZoneSize = 5,
  });

  final int promotionZoneSize;
  final int demotionZoneSize;

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  // null = "All" tab
  League? _selectedLeague;
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _selectedLeague = MockDataService.mockCurrentAmbassador.league;
    _searchController.addListener(() {
      setState(() => _query = _searchController.text.trim());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentId = MockDataService.mockCurrentAmbassador.id;
    final allAmbassadors = MockDataService.mockLeaderboard;

    final leagueList = _selectedLeague == null
        ? allAmbassadors
        : allAmbassadors.where((a) => a.league == _selectedLeague).toList();

    final query = _query.toLowerCase();
    final isSearching = query.isNotEmpty;
    final displayList = isSearching
        ? leagueList.where((a) => a.name.toLowerCase().contains(query)).toList()
        : leagueList;

    final showLeagueChrome = _selectedLeague != null && !isSearching;
    final selectedLeague = _selectedLeague;

    final total = displayList.length;
    final hasPodium = showLeagueChrome && total >= 3;
    final podium = hasPodium ? displayList.take(3).toList() : const <Ambassador>[];
    final podiumCount = hasPodium ? 3 : 0;

    final showPromotion = showLeagueChrome && selectedLeague!.next != null;
    final showDemotion = showLeagueChrome && selectedLeague!.previous != null;
    final promoCount = showPromotion
        ? (widget.promotionZoneSize < total ? widget.promotionZoneSize : total)
        : 0;
    final remainingAfterPromo = total - promoCount;
    final demoCount = showDemotion
        ? (widget.demotionZoneSize < remainingAfterPromo
            ? widget.demotionZoneSize
            : remainingAfterPromo)
        : 0;

    final rest = displayList.sublist(podiumCount);
    final rows = <Widget>[];
    var promotionHeaderShown = false;
    var demotionHeaderShown = false;

    for (var i = 0; i < rest.length; i++) {
      final rank = podiumCount + i + 1;
      final ambassador = rest[i];
      final isPromotionRow = showLeagueChrome && rank <= promoCount;
      final isDemotionRow =
          showLeagueChrome && demoCount > 0 && rank > (total - demoCount);

      if (isPromotionRow && !promotionHeaderShown) {
        rows.add(const _ZoneHeader(
          icon: Icons.trending_up,
          label: 'PROMOTION ZONE',
          color: _promotionColor,
        ));
        promotionHeaderShown = true;
      }
      if (isDemotionRow && !demotionHeaderShown) {
        rows.add(const _ZoneHeader(
          icon: Icons.trending_down,
          label: 'DEMOTION ZONE',
          color: _demotionColor,
        ));
        demotionHeaderShown = true;
      }

      rows.add(Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: _RankRow(
          rank: rank,
          ambassador: ambassador,
          isCurrent: ambassador.id == currentId,
          zone: isPromotionRow
              ? _RowZone.promotion
              : (isDemotionRow ? _RowZone.demotion : _RowZone.normal),
        ),
      ));
    }

    return Scaffold(
      backgroundColor: _surface,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            if (showLeagueChrome)
              _LeagueHeader(
                league: selectedLeague!,
                promotionZoneSize: widget.promotionZoneSize,
              )
            else
              const _AllLeaguesHeader(),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                children: [
                  _LeagueSwitcher(
                    selected: _selectedLeague,
                    onSelect: (league) => setState(() => _selectedLeague = league),
                  ),
                  const SizedBox(height: 14),
                  _SearchField(controller: _searchController),
                ],
              ),
            ),
            if (hasPodium) ...[
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _Podium(top3: podium, currentId: currentId),
              ),
            ],
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: displayList.isEmpty
                  ? _EmptyState(query: _query)
                  : Column(children: rows),
            ),
          ],
        ),
      ),
    );
  }
}

enum _RowZone { normal, promotion, demotion }

class _AllLeaguesHeader extends StatelessWidget {
  const _AllLeaguesHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 20),
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.emoji_events, color: _primaryContainer, size: 22),
              const SizedBox(width: 8),
              Text(
                'All Ambassadors',
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
            'Every league, ranked by points',
            style: GoogleFonts.inter(fontSize: 13, color: _onSurfaceVariant.withOpacity(0.8)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _LeagueTheme {
  const _LeagueTheme({required this.gradient, required this.iconColor, required this.icon});

  final List<Color> gradient;
  final Color iconColor;
  final IconData icon;
}

const Map<League, _LeagueTheme> _leagueThemes = {
  League.bronze: _LeagueTheme(
    gradient: [Color(0xFFF3E1D2), Color(0xFFE7C9A9)],
    iconColor: Color(0xFFCD7F32),
    icon: Icons.shield,
  ),
  League.silver: _LeagueTheme(
    gradient: [Color(0xFFF2F2F4), Color(0xFFD9D9DE)],
    iconColor: Color(0xFFA6A6AE),
    icon: Icons.military_tech,
  ),
  League.gold: _LeagueTheme(
    gradient: [Color(0xFFFFF0D6), Color(0xFFFFD9A8)],
    iconColor: _primaryContainer,
    icon: Icons.workspace_premium,
  ),
  League.platinum: _LeagueTheme(
    gradient: [Color(0xFFE0F4FF), Color(0xFFC2E8FF)],
    iconColor: Color(0xFF00A4FC),
    icon: Icons.diamond,
  ),
};

class _LeagueHeader extends StatelessWidget {
  const _LeagueHeader({required this.league, required this.promotionZoneSize});

  final League league;
  final int promotionZoneSize;

  @override
  Widget build(BuildContext context) {
    final theme = _leagueThemes[league]!;
    final next = league.next;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: theme.gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: theme.iconColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: theme.iconColor.withOpacity(0.35), blurRadius: 20, offset: const Offset(0, 8)),
              ],
            ),
            alignment: Alignment.center,
            child: Icon(theme.icon, color: Colors.white, size: 34),
          ),
          const SizedBox(height: 12),
          Text(
            '${league.label} League',
            style: GoogleFonts.plusJakartaSans(fontSize: 24, fontWeight: FontWeight.w800, color: _onBackground),
          ),
          const SizedBox(height: 4),
          Text(
            next != null
                ? 'Top $promotionZoneSize ambassadors advance to ${next.label} League'
                : "You've reached the top league — defend your spot!",
            style: GoogleFonts.inter(fontSize: 13, color: _onSurfaceVariant.withOpacity(0.85)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _LeagueSwitcher extends StatelessWidget {
  const _LeagueSwitcher({required this.selected, required this.onSelect});

  final League? selected;
  final ValueChanged<League?> onSelect;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _chip(label: 'All', value: null),
          for (final league in League.values) ...[
            const SizedBox(width: 8),
            _chip(label: league.label, value: league),
          ],
        ],
      ),
    );
  }

  Widget _chip({required String label, required League? value}) {
    final isSelected = selected == value;
    return GestureDetector(
      onTap: () => onSelect(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? _primary : Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: isSelected ? _primary : _outlineVariant.withOpacity(0.6)),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: isSelected ? Colors.white : _onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: _outlineVariant.withOpacity(0.5)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: TextField(
        controller: controller,
        style: GoogleFonts.inter(fontSize: 14, color: _onBackground),
        decoration: InputDecoration(
          isDense: true,
          hintText: 'Search ambassadors',
          hintStyle: GoogleFonts.inter(fontSize: 14, color: _onSurfaceVariant.withOpacity(0.55)),
          prefixIcon: Icon(Icons.search, color: _onSurfaceVariant.withOpacity(0.8)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}

class _Podium extends StatelessWidget {
  const _Podium({required this.top3, required this.currentId});

  final List<Ambassador> top3;
  final String currentId;

  @override
  Widget build(BuildContext context) {
    final first = top3[0];
    final second = top3[1];
    final third = top3[2];
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _PodiumColumn(
          ambassador: second,
          rank: 2,
          avatarSize: 62,
          avatarBorder: const Color(0xFFC0C0C0),
          barHeight: 92,
          barColors: const [_surfaceContainerHigh, _surfaceContainer],
          isCurrent: second.id == currentId,
        ),
        const SizedBox(width: 10),
        _PodiumColumn(
          ambassador: first,
          rank: 1,
          avatarSize: 78,
          avatarBorder: const Color(0xFFFFD700),
          barHeight: 132,
          barColors: const [_primaryContainer, _primary],
          isCurrent: first.id == currentId,
          isMvp: true,
        ),
        const SizedBox(width: 10),
        _PodiumColumn(
          ambassador: third,
          rank: 3,
          avatarSize: 62,
          avatarBorder: const Color(0xFFCD7F32),
          barHeight: 76,
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
    required this.avatarSize,
    required this.avatarBorder,
    required this.barHeight,
    required this.barColors,
    required this.isCurrent,
    this.isMvp = false,
  });

  final Ambassador ambassador;
  final int rank;
  final double avatarSize;
  final Color avatarBorder;
  final double barHeight;
  final List<Color> barColors;
  final bool isCurrent;
  final bool isMvp;

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
                'YOU',
                style: GoogleFonts.inter(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            )
          else if (isMvp)
            Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: _primaryContainer, borderRadius: BorderRadius.circular(30)),
              child: Text(
                'MVP',
                style: GoogleFonts.inter(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
          _InitialsAvatar(name: ambassador.name, size: avatarSize, borderColor: avatarBorder),
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

class _ZoneHeader extends StatelessWidget {
  const _ZoneHeader({required this.icon, required this.label, required this.color});

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 14, 4, 8),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 11, color: color, letterSpacing: 1.1),
          ),
        ],
      ),
    );
  }
}

class _RankRow extends StatelessWidget {
  const _RankRow({
    required this.rank,
    required this.ambassador,
    required this.isCurrent,
    required this.zone,
  });

  final int rank;
  final Ambassador ambassador;
  final bool isCurrent;
  final _RowZone zone;

  @override
  Widget build(BuildContext context) {
    Color background;
    Color border;
    if (isCurrent) {
      background = _primaryContainer.withOpacity(0.08);
      border = _primary;
    } else if (zone == _RowZone.promotion) {
      background = const Color(0xFFF0FBF3);
      border = const Color(0xFFC9EFD4);
    } else if (zone == _RowZone.demotion) {
      background = const Color(0xFFFDF3F2);
      border = const Color(0xFFF6D9D6);
    } else {
      background = _surfaceContainerLowest;
      border = _outlineVariant.withOpacity(0.4);
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border, width: isCurrent ? 1.5 : 1),
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
              style: GoogleFonts.inter(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: isCurrent ? _primary : _onSurfaceVariant.withOpacity(0.6),
              ),
            ),
          ),
          const SizedBox(width: 12),
          _InitialsAvatar(
            name: ambassador.name,
            size: 52,
            borderColor: isCurrent ? _primary : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isCurrent ? 'You (${ambassador.name.split(' ').first})' : ambassador.name,
                  style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 15, color: _onBackground),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: isCurrent ? _primary : _leagueThemes[ambassador.league]!.iconColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${ambassador.league.label.toUpperCase()} AMBASSADOR',
                    style: GoogleFonts.inter(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: isCurrent ? Colors.white : _leagueThemes[ambassador.league]!.iconColor,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
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

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Icon(Icons.search_off, color: _onSurfaceVariant.withOpacity(0.5), size: 40),
          const SizedBox(height: 12),
          Text(
            query.isEmpty ? 'No ambassadors in this league yet.' : 'No results for "$query".',
            style: GoogleFonts.inter(color: _onSurfaceVariant, fontSize: 14),
            textAlign: TextAlign.center,
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
const Color _promotionColor = Color(0xFF1E9E4B);
const Color _demotionColor = Color(0xFFD3382F);
