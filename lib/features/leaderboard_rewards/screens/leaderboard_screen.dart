import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/leaderboard_provider.dart';
import '../../../core/services/ambassador_state_provider.dart';
import '../../../models/models.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../design_system/design_system.dart';
import '../../../shared/widgets/design_kit.dart';

// ── Design tokens: central charte (zero hardcoded hex) ──────────────────────
const Color _primary = MaamoraColors.primary; // orange
const Color _background = MaamoraColors.scaffold; // cream
const Color _surface = MaamoraColors.surface;
const Color _onBackground = MaamoraColors.textPrimary; // navy
const Color _onSurfaceVariant = MaamoraColors.textSecondary;
const Color _cardBorder = MaamoraColors.border;
const Color _brownDark = _primary;

// Metal accents for the podium — charte tier colors (highlight→mid→depth),
// the mid tone is used for the medal icons.
const Color _gold = MaamoraColors.tierGold; // charte tierGold (levels)
const Color _silver = MaamoraColors.tierSilver; // charte tierSilver
const Color _bronze = MaamoraColors.tierBronze; // charte tierBronze

// ── Screen ───────────────────────────────────────────────────────────────────

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
        loading: () => const _LeaderboardSkeleton(),
        error: (err, _) => Padding(
          padding: const EdgeInsets.all(20),
          child: MaamoraErrorState(
            subtitle: err.toString(),
            onRetry: () => ref.invalidate(leaderboardProvider(city)),
          ),
        ),
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

          // Podium takes the top 3; the ranked list shows the rest.
          final podiumTop = listData.take(3).toList();
          final restStart = podiumTop.length;

          if (listData.isEmpty) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _TogglePills(
                      city: city,
                      isMyCity: _isMyCity,
                      onToggle: (v) => setState(() => _isMyCity = v),
                    ),
                    const SizedBox(height: 24),
                    Expanded(
                      child: MaamoraEmptyState(
                        icon: MaamoraIcons.board,
                        title: context.tr('lb_empty'),
                        subtitle:
                            context.tr('lb_empty_sub'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 8),
                // Podium top 3 — different heights, floating micro-motion
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _Podium(top3: podiumTop),
                ),
                const SizedBox(height: 16),
                // Toggle pills (city / national)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _TogglePills(
                    city: city,
                    isMyCity: _isMyCity,
                    onToggle: (v) => setState(() => _isMyCity = v),
                  ),
                ),
                const SizedBox(height: 12),
                // Ranked list (rest, scrollable)
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
                        for (int i = restStart; i < listData.length; i++) ...[
                          _RankRow(
                            rank: i + 1,
                            entry: listData[i],
                            isMe: ambassadorState.ambassador?.id ==
                                listData[i]['id'],
                            index: i - restStart,
                          ),
                          const SizedBox(height: 10),
                        ],
                        if (restStart >= listData.length)
                          Padding(
                            padding: EdgeInsets.only(top: 8, bottom: 12),
                            child: Text(
                              context.tr('lb_podium_hint'),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: _onSurfaceVariant,
                              ),
                            ),
                          ),
                        // Bottom padding so the pinned row doesn't cover content
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),
                // Pinned "You" row — slides in with a rotating halo
                if (myEntry != null && myRank != null)
                  _MyPinnedRow(
                    myEntry: myEntry,
                    myRank: myRank,
                    nextPerson: nextPerson,
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ── Skeleton (shimmer — replaces the loader) ─────────────────────────────────

class _LeaderboardSkeleton extends StatelessWidget {
  const _LeaderboardSkeleton();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: [
            // Podium placeholder (3 floating circles at different heights)
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      MaamoraShimmerBox(height: 60, radius: 30),
                      const SizedBox(height: 8),
                      MaamoraShimmerBox(height: 110, radius: 16),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    children: [
                      MaamoraShimmerBox(height: 70, radius: 35),
                      const SizedBox(height: 8),
                      MaamoraShimmerBox(height: 150, radius: 16),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    children: [
                      MaamoraShimmerBox(height: 60, radius: 30),
                      const SizedBox(height: 8),
                      MaamoraShimmerBox(height: 125, radius: 16),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerLeft,
              child: MaamoraShimmerBox(height: 36, width: 180, radius: 18),
            ),
            const SizedBox(height: 16),
            const MaamoraSkeletonList(count: 4),
          ],
        ),
      ),
    );
  }
}

// ── Podium (top 3) ────────────────────────────────────────────────────────────
//
// Gold center, silver left, bronze right — different heights, each medalist
// floats gently (transform-only loop, 60fps safe).

class _Podium extends StatelessWidget {
  const _Podium({required this.top3});

  final List<Map<String, dynamic>> top3;

  static const Color _medalFor1 = _gold;
  static const Color _medalFor2 = _silver;
  static const Color _medalFor3 = _bronze;

  @override
  Widget build(BuildContext context) {
    final first = top3.isNotEmpty ? top3[0] : null;
    final second = top3.length > 1 ? top3[1] : null;
    final third = top3.length > 2 ? top3[2] : null;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (second != null)
          Expanded(
            child: _PodiumCard(
              entry: second,
              rank: 2,
              medalColor: _medalFor2,
              blockHeight: 64,
              avatarSize: 58,
              floatDelay: .6,
            ),
          ),
        if (first != null || second != null) const SizedBox(width: 10),
        Expanded(
          flex: 1,
          child: _PodiumCard(
            entry: first,
            rank: 1,
            medalColor: _medalFor1,
            blockHeight: 88,
            avatarSize: 68,
            floatDelay: 0,
          ),
        ),
        if (third != null || first != null) const SizedBox(width: 10),
        if (third != null)
          Expanded(
            child: _PodiumCard(
              entry: third,
              rank: 3,
              medalColor: _medalFor3,
              blockHeight: 52,
              avatarSize: 54,
              floatDelay: .3,
            ),
          ),
      ],
    );
  }
}

class _PodiumCard extends StatefulWidget {
  const _PodiumCard({
    required this.entry,
    required this.rank,
    required this.medalColor,
    required this.blockHeight,
    required this.avatarSize,
    required this.floatDelay,
  });

  final Map<String, dynamic>? entry;
  final int rank;
  final Color medalColor;
  final double blockHeight;
  final double avatarSize;
  final double floatDelay;

  @override
  State<_PodiumCard> createState() => _PodiumCardState();
}

class _PodiumCardState extends State<_PodiumCard>
    with TickerProviderStateMixin {
  late final AnimationController _float = AnimationController(
    vsync: this,
    duration: MaamoraDurations.floatLoop,
  );

  @override
  void initState() {
    super.initState();
    // Offset the waves so they don't move in sync.
    Future<void>.delayed(
      Duration(milliseconds: (widget.floatDelay * 1000).round()),
      () {
        if (mounted) _float.repeat();
      },
    );
  }

  @override
  void dispose() {
    _float.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final entry = widget.entry;
    final name = entry?['full_name'] as String? ?? '—';
    final city = entry?['city'] as String? ?? context.tr('lb_unknown');
    final level = entry?['level'] as String? ?? 'neutral';
    final orders = (entry?['total_validated_members'] as num?)?.toInt() ?? 0;

    return AnimatedBuilder(
      animation: _float,
      builder: (context, child) {
        // 3px sine float — transform only.
        final dy = 3 * sin(_float.value * 2 * pi);
        return Transform.translate(offset: Offset(0, dy), child: child);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Avatar(name: name, size: widget.avatarSize),
          const SizedBox(height: 6),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(MaamoraIcons.medal, size: 14, color: widget.medalColor),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  name.split(' ').first,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: _onBackground,
                  ),
                ),
              ),
            ],
          ),
          Text(
            '$orders',
            style: GoogleFonts.cairo(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: _primary,
            ),
          ),
          const SizedBox(height: 8),
          // Pedestal block: heights differ per rank.
          Container(
            height: widget.blockHeight,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  widget.medalColor.withValues(alpha: 0.22),
                  MaamoraColors.surface.withValues(alpha: 0.0),
                ],
              ),
              color: widget.medalColor.withValues(alpha: 0.16),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(14)),
              border: Border.all(
                color: widget.medalColor.withValues(alpha: 0.35),
              ),
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.center,
              // Column is min-sized so FittedBox can compress it down to fit
              // the short side pedestals (silver 64 / bronze 52) without
              // ever overflowing.
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    MaamoraIcons.location,
                    size: 11,
                    color: _onSurfaceVariant,
                  ),
                  Text(
                    city,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.cairo(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: _onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  LevelBadge(
                    level: AmbassadorLevelExtension.fromString(level),
                    showRate: false,
                    compact: true,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Toggle Pills ──────────────────────────────────────────────────────────────

class _TogglePills extends StatelessWidget {
  final String city;
  final bool isMyCity;
  final ValueChanged<bool> onToggle;

  const _TogglePills({
    required this.city,
    required this.isMyCity,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: MaamoraColors.surfaceLow,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          Expanded(
            child: _Pill(
              label: context.tr('lb_my_city') + (city.isNotEmpty ? ' ($city)' : ''),
              isActive: isMyCity,
              onToggle: () => onToggle(true),
            ),
          ),
          Expanded(
            child: _Pill(
              label: context.tr('lb_national'),
              isActive: !isMyCity,
              onToggle: () => onToggle(false),
            ),
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

  const _Pill({
    required this.label,
    required this.isActive,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onToggle();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          color: isActive ? _brownDark : Colors.transparent,
          borderRadius: BorderRadius.circular(26),
          boxShadow: isActive
              ? MaamoraShadows.glow(_brownDark, 0.25)
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
            color: isActive ? Colors.white : _onSurfaceVariant,
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
  final int index;

  const _RankRow({
    required this.rank,
    required this.entry,
    required this.isMe,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final name = entry['full_name'] as String? ?? context.tr('lb_ambassador');
    final city = entry['city'] as String? ?? context.tr('lb_unknown');
    final level = entry['level'] as String? ?? 'neutral';
    final orders = (entry['total_validated_members'] as num?)?.toInt() ?? 0;

    // Stagger slot (capped so long lists stay fast).
    final start = (0.08 + index * 0.10).clamp(0.0, 0.85);

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: MaamoraDurations.countUp,
      curve: Interval(start, 1.0, curve: Curves.easeOutCubic),
      builder: (context, t, child) {
        final tc = t.clamp(0.0, 1.0);
        return Opacity(
          opacity: tc,
          child: FractionalTranslation(
            translation: Offset((1 - tc) * 0.06, 0),
            child: child,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: isMe ? MaamoraColors.primarySoft : _surface,
          borderRadius: BorderRadius.circular(MaamoraRadius.cardSm),
          border: Border.all(
            color: isMe
                ? MaamoraColors.primaryHairline
                : _cardBorder,
          ),
          boxShadow: MaamoraShadows.soft,
        ),
        child: Row(
          children: [
            // Rank number with medal icon for top 3 (kept for safety although
            // rows normally start after the podium).
            SizedBox(
              width: 36,
              child: _RankChip(rank: rank),
            ),
            const SizedBox(width: 10),
            _Avatar(name: name),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.cairo(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: _onBackground,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(MaamoraIcons.location,
                          size: 12, color: _onSurfaceVariant),
                      const SizedBox(width: 3),
                      Flexible(
                        child: Text(
                          city,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.cairo(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                            color: _onSurfaceVariant,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      LevelBadge(
                        level: AmbassadorLevelExtension.fromString(level),
                        showRate: false,
                        compact: true,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                CountUpText(
                  value: orders.toDouble(),
                  style: GoogleFonts.cairo(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: _primary,
                  ),
                ),
                Text(
                  context.tr('lb_members'),
                  style: GoogleFonts.cairo(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w500,
                    color: _onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Rank numeral — small chip; medal color accent for 1–3.
class _RankChip extends StatelessWidget {
  const _RankChip({required this.rank});

  final int rank;

  @override
  Widget build(BuildContext context) {
    final Color medalColor;
    switch (rank) {
      case 1:
        medalColor = _gold;
      case 2:
        medalColor = _silver;
      case 3:
        medalColor = _bronze;
      default:
        medalColor = MaamoraColors.textFaint;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (rank <= 3) ...[
          Icon(MaamoraIcons.medal, size: 14, color: medalColor),
          const SizedBox(width: 2),
        ],
        Text(
          '$rank',
          style: GoogleFonts.cairo(
            fontSize: 13.5,
            fontWeight: FontWeight.w800,
            color: rank <= 3 ? medalColor : _onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

// ── My Pinned Row ("You") — slides in, avatar halo rotates ────────────────────

class _MyPinnedRow extends StatefulWidget {
  final Map<String, dynamic> myEntry;
  final int myRank;
  final Map<String, dynamic>? nextPerson;

  const _MyPinnedRow({
    required this.myEntry,
    required this.myRank,
    this.nextPerson,
  });

  @override
  State<_MyPinnedRow> createState() => _MyPinnedRowState();
}

class _MyPinnedRowState extends State<_MyPinnedRow>
    with TickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 520),
  )..forward();

  late final AnimationController _ring = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 4),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    _ring.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final orders =
        (widget.myEntry['total_validated_members'] as num?)?.toInt() ?? 0;

    int ordersToPass = 0;
    String nextName = '';

    if (widget.nextPerson != null) {
      final nextOrders =
          (widget.nextPerson!['total_validated_members'] as num?)?.toInt() ?? 0;
      ordersToPass = nextOrders - orders + 1;
      nextName =
          (widget.nextPerson!['full_name'] as String? ?? 'Next').split(' ').first;
    }

    return AnimatedBuilder(
      animation: _c,
      builder: (context, child) {
        final t = Curves.easeOutCubic.transform(
          Interval(0, 1).transform(_c.value),
        );
        return Transform.translate(
          offset: Offset(0, 60 * (1 - t)),
          child: Opacity(opacity: t, child: child),
        );
      },
      child: Container(
        margin: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: MaamoraGradients.heroNavy,
          ),
          color: _brownDark,
          borderRadius: BorderRadius.circular(20),
          boxShadow: MaamoraShadows.glow(_brownDark, 0.35),
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
                '${widget.myRank}',
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Avatar with slowly rotating halo
            AnimatedBuilder(
              animation: _ring,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _ring.value * 2 * pi,
                  child: child,
                );
              },
              child: Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const SweepGradient(
                    colors: [
                      _gold,
                      Colors.white,
                      _gold,
                      Colors.white,
                      _gold,
                    ],
                  ),
                ),
                alignment: Alignment.center,
                padding: const EdgeInsets.all(3),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.25),
                  ),
                  child: const Icon(
                    MaamoraIcons.referral,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Name & nudge
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.tr('lb_you'),
                    style: GoogleFonts.cairo(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      if (widget.nextPerson != null) ...[
                        Flexible(
                          child: Text(
                            context.tr('lb_pass_hint',
                                args: {'n': '$ordersToPass', 'name': nextName}),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.cairo(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withValues(alpha: 0.85),
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(MaamoraIcons.arrowUp,
                            color: Colors.white.withValues(alpha: 0.85),
                            size: 14),
                      ] else ...[
                        Text(
                          'Tu es n°1 !',
                          style: GoogleFonts.cairo(
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
                CountUpText(
                  value: orders.toDouble(),
                  style: GoogleFonts.cairo(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                Text(
                  context.tr('lb_members'),
                  style: GoogleFonts.cairo(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.75),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Avatar ────────────────────────────────────────────────────────────────────

class _Avatar extends StatelessWidget {
  final String name;
  final double size;

  const _Avatar({required this.name, this.size = 46});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: MaamoraColors.creamIntense, // cream-intense chip (charte derived)
        border: Border.fromBorderSide(
          BorderSide(color: _cardBorder, width: 1.5),
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        _initials(name),
        style: GoogleFonts.cairo(
          fontSize: size > 56 ? 20 : 16,
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
