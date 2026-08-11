import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ── Design tokens ──────────────────────────────────────────────────────────
const Color _primary = Color(0xFFFB7701); // orange
const Color _background = Color(0xFFFAF5F0);
const Color _surface = Color(0xFFFFFFFF);
const Color _onBackground = Color(0xFF1A2433);
const Color _onSurfaceVariant = Color(0xFF8A8078);
const Color _cardBorder = Color(0xFFE8DDD3);
const Color _brownDark = _primary;

// ── Dummy Data ────────────────────────────────────────────────────────────

class _LeaderEntry {
  final int rank;
  final String name;
  final String city;
  final int level;
  final int orders;
  final String? avatarInitial;
  final Color? avatarColor;

  const _LeaderEntry({
    required this.rank,
    required this.name,
    required this.city,
    required this.level,
    required this.orders,
    this.avatarInitial,
    this.avatarColor,
  });
}

const _myCity = 'Salé';

final _cityData = <_LeaderEntry>[
  _LeaderEntry(rank: 1, name: 'Fatima Z.', city: 'Salé', level: 5, orders: 1240),
  _LeaderEntry(rank: 2, name: 'Khalid B.', city: 'Salé', level: 4, orders: 985, avatarInitial: 'K', avatarColor: Color(0xFFB0C4DE)),
  _LeaderEntry(rank: 3, name: 'Youssef M.', city: 'Salé', level: 4, orders: 820),
  _LeaderEntry(rank: 41, name: 'Amina T.', city: 'Salé', level: 2, orders: 156, avatarInitial: 'A', avatarColor: Color(0xFF00BFFF)),
];

final _nationalData = <_LeaderEntry>[
  _LeaderEntry(rank: 1, name: 'Hassan A.', city: 'Casablanca', level: 6, orders: 3450),
  _LeaderEntry(rank: 2, name: 'Sara M.', city: 'Rabat', level: 5, orders: 2890),
  _LeaderEntry(rank: 3, name: 'Omar B.', city: 'Marrakech', level: 5, orders: 2210),
  _LeaderEntry(rank: 89, name: 'Amina T.', city: 'Salé', level: 2, orders: 156, avatarInitial: 'A', avatarColor: Color(0xFF00BFFF)),
];

const _myEntry = _LeaderEntry(rank: 42, name: 'You', city: 'Salé', level: 2, orders: 152);

const _nextPerson = 'Amina';
const _ordersToPass = 4;

// ── Screen ────────────────────────────────────────────────────────────────

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  bool _isMyCity = true;

  @override
  Widget build(BuildContext context) {
    final data = _isMyCity ? _cityData : _nationalData;

    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),
            // Toggle pills
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _TogglePills(
                isMyCity: _isMyCity,
                onToggle: (v) => setState(() => _isMyCity = v),
              ),
            ),
            const SizedBox(height: 16),
            // Ranked list (scrollable)
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  // Top 3 rows
                  for (final entry in data.take(3)) ...[
                    _RankRow(entry: entry, isMe: false, showMedal: true),
                    const SizedBox(height: 10),
                  ],
                  // Ellipsis separator
                  if (data.length > 3) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Center(
                        child: Text(
                          '· · ·',
                          style: TextStyle(
                            fontSize: 18,
                            color: _onSurfaceVariant,
                            letterSpacing: 4,
                          ),
                        ),
                      ),
                    ),
                    // 4th entry (user just above me)
                    _RankRow(entry: data.last, isMe: false, showMedal: false),
                    const SizedBox(height: 10),
                  ],
                  // Bottom padding so the pinned row doesn't cover content
                  const SizedBox(height: 80),
                ],
              ),
            ),
            // Pinned "You" row
            _MyPinnedRow(myEntry: _myEntry),
          ],
        ),
      ),
    );
  }
}

// ── Toggle Pills ─────────────────────────────────────────────────────────────

class _TogglePills extends StatelessWidget {
  final bool isMyCity;
  final ValueChanged<bool> onToggle;

  const _TogglePills({required this.isMyCity, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFEDE8E4),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          _Pill(
            label: 'My city ($_myCity)',
            isActive: isMyCity,
            onTap: () => onToggle(true),
          ),
          _Pill(
            label: 'National',
            isActive: !isMyCity,
            onTap: () => onToggle(false),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _Pill({required this.label, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? _brownDark : Colors.transparent,
            borderRadius: BorderRadius.circular(26),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: isActive ? Colors.white : _onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Rank Row ─────────────────────────────────────────────────────────────────

class _RankRow extends StatelessWidget {
  final _LeaderEntry entry;
  final bool isMe;
  final bool showMedal;

  const _RankRow({
    required this.entry,
    required this.isMe,
    required this.showMedal,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Rank number with medal overlay
          SizedBox(
            width: 36,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                if (showMedal)
                  Positioned(
                    top: -4,
                    left: 0,
                    child: Text(
                      _medal(entry.rank),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                Padding(
                  padding: EdgeInsets.only(top: showMedal ? 12 : 0),
                  child: Text(
                    '${entry.rank}',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: _onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // Avatar
          _Avatar(
            name: entry.name,
            initial: entry.avatarInitial,
            bgColor: entry.avatarColor,
          ),
          const SizedBox(width: 12),
          // Name & city/level
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.name,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: _onBackground,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined,
                        size: 12, color: _onSurfaceVariant),
                    const SizedBox(width: 2),
                    Text(
                      '${entry.city} · Level ${entry.level}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: _onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Order count
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${entry.orders}',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: _primary,
                ),
              ),
              Text(
                'orders',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: _onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _medal(int rank) {
    switch (rank) {
      case 1:
        return '🥇';
      case 2:
        return '🥈';
      case 3:
        return '🥉';
      default:
        return '';
    }
  }
}

// ── My Pinned Row ─────────────────────────────────────────────────────────────

class _MyPinnedRow extends StatelessWidget {
  final _LeaderEntry myEntry;

  const _MyPinnedRow({required this.myEntry});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: _brownDark,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _brownDark.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          // Rank circle
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '${myEntry.rank}',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Avatar (user photo placeholder)
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.25),
              border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 2),
            ),
            child: const Icon(Icons.person_rounded, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          // Name & nudge
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'You',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      '$_ordersToPass more orders to pass $_nextPerson',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.arrow_upward_rounded,
                        color: Colors.white.withValues(alpha: 0.85), size: 14),
                  ],
                ),
              ],
            ),
          ),
          // Order count
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${myEntry.orders}',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              Text(
                'orders',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withValues(alpha: 0.75),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Avatar ────────────────────────────────────────────────────────────────────

class _Avatar extends StatelessWidget {
  final String name;
  final String? initial;
  final Color? bgColor;

  const _Avatar({required this.name, this.initial, this.bgColor});

  @override
  Widget build(BuildContext context) {
    final hasInitial = initial != null;
    final bg = bgColor ?? const Color(0xFFF5EDE4);

    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: bg,
        border: Border.all(color: _cardBorder, width: 1.5),
      ),
      alignment: Alignment.center,
      child: hasInitial
          ? Text(
              initial!,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            )
          : Text(
              _initials(name),
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: _brownDark,
              ),
            ),
    );
  }

  String _initials(String n) {
    final parts = n.trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }
}
