import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/leaderboard_provider.dart';
import '../../../core/services/ambassador_state_provider.dart';

// ── Design tokens ──────────────────────────────────────────────────────────
const Color _primary = Color(0xFFFB7701); // orange
const Color _background = Color(0xFFFAF5F0);
const Color _surface = Color(0xFFFFFFFF);
const Color _onBackground = Color(0xFF1A2433);
const Color _onSurfaceVariant = Color(0xFF8A8078);
const Color _cardBorder = Color(0xFFE8DDD3);
const Color _brownDark = _primary;

// ── Screen ────────────────────────────────────────────────────────────────

class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  ConsumerState<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen> {
  bool _isMyCity = true;

  @override
  Widget build(BuildContext context) {
    final ambassadorState = ref.watch(ambassadorStateProvider);
    final city = ambassadorState.ambassador?.city ?? '';
    final leaderboardAsync = ref.watch(leaderboardProvider(city));

    return Scaffold(
      backgroundColor: _background,
      body: leaderboardAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: _primary)),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (data) {
          final listData = _isMyCity ? data.cityRankings : data.nationalRankings;
          
          Map<String, dynamic>? myEntry;
          Map<String, dynamic>? nextPerson;
          int? myRank;
          
          if (ambassadorState.ambassador != null) {
            for (int i = 0; i < listData.length; i++) {
              if (listData[i]['id'] == ambassadorState.ambassador!.id) {
                myEntry = listData[i];
                myRank = i + 1;
                if (i > 0) nextPerson = listData[i - 1];
                break;
              }
            }
          }

          return SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 8),
                // Toggle pills
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _TogglePills(
                    city: city,
                    isMyCity: _isMyCity,
                    onToggle: (v) => setState(() => _isMyCity = v),
                  ),
                ),
                const SizedBox(height: 16),
                // Ranked list (scrollable)
                Expanded(
                  child: RefreshIndicator(
                    color: _primary,
                    onRefresh: () async {
                      ref.invalidate(leaderboardProvider(city));
                      await ref.read(leaderboardProvider(city).future);
                    },
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: [
                        // All rows
                        for (int i = 0; i < listData.length; i++) ...[
                          _RankRow(
                            rank: i + 1,
                            entry: listData[i],
                            isMe: ambassadorState.ambassador?.id == listData[i]['id'],
                            showMedal: i < 3
                          ),
                          const SizedBox(height: 10),
                        ],
                        // Bottom padding so the pinned row doesn't cover content
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),
                // Pinned "You" row
                if (myEntry != null && myRank != null)
                  _MyPinnedRow(
                    myEntry: myEntry,
                    myRank: myRank,
                    nextPerson: nextPerson,
                  ),
              ],
            ),
          );
        }
      ),
    );
  }
}

// ── Toggle Pills ─────────────────────────────────────────────────────────────

class _TogglePills extends StatelessWidget {
  final String city;
  final bool isMyCity;
  final ValueChanged<bool> onToggle;

  const _TogglePills({required this.city, required this.isMyCity, required this.onToggle});

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
            label: 'My city${city.isNotEmpty ? ' ($city)' : ''}',
            isActive: isMyCity,
            onToggle: () => onToggle(true),
          ),
          _Pill(
            label: 'National',
            isActive: !isMyCity,
            onToggle: () => onToggle(false),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onToggle;

  const _Pill({required this.label, required this.isActive, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onToggle,
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
  final int rank;
  final Map<String, dynamic> entry;
  final bool isMe;
  final bool showMedal;

  const _RankRow({
    required this.rank,
    required this.entry,
    required this.isMe,
    required this.showMedal,
  });

  @override
  Widget build(BuildContext context) {
    final name = entry['full_name'] as String? ?? 'User';
    final city = entry['city'] as String? ?? 'Unknown';
    final level = entry['level'] as String? ?? 'neutral';
    final orders = (entry['total_validated_members'] as num?)?.toInt() ?? 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: isMe ? const Color(0xFFFFF0E6) : _surface,
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
                      _medal(rank),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                Padding(
                  padding: EdgeInsets.only(top: showMedal ? 12 : 0),
                  child: Text(
                    '$rank',
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
            name: name,
          ),
          const SizedBox(width: 12),
          // Name & city/level
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
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
                      '$city · $level',
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
                '$orders',
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
  final Map<String, dynamic> myEntry;
  final int myRank;
  final Map<String, dynamic>? nextPerson;

  const _MyPinnedRow({required this.myEntry, required this.myRank, this.nextPerson});

  @override
  Widget build(BuildContext context) {
    final orders = (myEntry['total_validated_members'] as num?)?.toInt() ?? 0;
    
    int ordersToPass = 0;
    String nextName = '';
    
    if (nextPerson != null) {
      final nextOrders = (nextPerson!['total_validated_members'] as num?)?.toInt() ?? 0;
      ordersToPass = nextOrders - orders + 1;
      nextName = (nextPerson!['full_name'] as String? ?? 'Next').split(' ').first;
    }

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
              '$myRank',
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
                    if (nextPerson != null) ...[
                      Text(
                        '$ordersToPass more orders to pass $nextName',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.arrow_upward_rounded,
                          color: Colors.white.withValues(alpha: 0.85), size: 14),
                    ] else ...[
                      Text(
                        'You are #1!',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                      ),
                    ]
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
                '$orders',
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
