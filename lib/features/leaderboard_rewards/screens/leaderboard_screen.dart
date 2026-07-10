import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/services/mock_data_service.dart';
import '../../../models/models.dart';
import '../../../shared/navigation/app_routes.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/widgets/tier_badge.dart';

// Dev 4 - Leaderboard: recreated from the "Maamora Ambassador Leaderboard"
// Stitch screen. Uses MockDataService.mockLeaderboard (already sorted by
// points) and highlights MockDataService.mockCurrentAmbassador wherever
// they land (podium or list). Reuses shared/widgets/tier_badge.dart.
//
// The "This week / All time" toggle is UI-only for now — hook it up to real
// weekly aggregation once the backend lands (see mock_data_service.dart).

final NumberFormat _pointsFormat = NumberFormat.decimalPattern('en_US');

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  int _selectedPeriod = 0; // 0 = This week, 1 = All time

  @override
  Widget build(BuildContext context) {
    final leaderboard = MockDataService.mockLeaderboard;
    final currentUserId = MockDataService.mockCurrentAmbassador.id;
    final podium = leaderboard.take(3).toList();
    final rest = leaderboard.skip(3).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _Header(
              onBack: () => context.canPop()
                  ? context.pop()
                  : context.go(AppRoutes.dashboard),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 4, 20, 16),
              child: Text(
                'Top ambassadors this week — climb the ranks to earn '
                'more rewards.',
                style: AppTheme.bodyMd,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _PeriodToggle(
                selectedIndex: _selectedPeriod,
                onChanged: (index) => setState(() => _selectedPeriod = index),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(bottom: 24),
                children: [
                  _Podium(ambassadors: podium, currentUserId: currentUserId),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        for (var i = 0; i < rest.length; i++)
                          _RankRow(
                            rank: i + 4,
                            ambassador: rest[i],
                            isCurrentUser: rest[i].id == currentUserId,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => context.push(AppRoutes.share),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryContainer,
                    foregroundColor: AppColors.onPrimaryContainer,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Invite a neighbor',
                        style: AppTheme.headlineSm.copyWith(
                          color: AppColors.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.arrow_forward,
                        size: 18,
                        color: AppColors.onPrimaryContainer,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back, color: AppColors.onBackground),
          ),
          const Expanded(
            child: Text(
              'Leaderboard',
              textAlign: TextAlign.center,
              style: AppTheme.headlineLg,
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_horiz, color: AppColors.onBackground),
          ),
        ],
      ),
    );
  }
}

/// "This week / All time" pill toggle — visual only until real weekly
/// aggregation exists.
class _PeriodToggle extends StatelessWidget {
  const _PeriodToggle({required this.selectedIndex, required this.onChanged});

  final int selectedIndex;
  final ValueChanged<int> onChanged;

  static const _labels = ['This week', 'All time'];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: List.generate(_labels.length, (index) {
          final bool selected = index == selectedIndex;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected ? AppColors.surface : Colors.transparent,
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: selected
                      ? [
                          BoxShadow(
                            color: AppColors.onBackground.withValues(
                              alpha: 0.08,
                            ),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  _labels[index],
                  style: AppTheme.labelMd.copyWith(
                    color: selected
                        ? AppColors.onBackground
                        : AppColors.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

/// Top-3 podium — 1st place elevated in the center, 2nd on the left, 3rd on
/// the right, bottoms aligned like a real podium.
class _Podium extends StatelessWidget {
  const _Podium({required this.ambassadors, required this.currentUserId});

  final List<Ambassador> ambassadors;
  final String currentUserId;

  Ambassador? _atRank(int rank) =>
      ambassadors.length >= rank ? ambassadors[rank - 1] : null;

  @override
  Widget build(BuildContext context) {
    final first = _atRank(1);
    final second = _atRank(2);
    final third = _atRank(3);
    if (first == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: second == null
                ? const SizedBox.shrink()
                : _PodiumColumn(
                    rank: 2,
                    ambassador: second,
                    height: 128,
                    isCurrentUser: second.id == currentUserId,
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _PodiumColumn(
              rank: 1,
              ambassador: first,
              height: 164,
              isCurrentUser: first.id == currentUserId,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: third == null
                ? const SizedBox.shrink()
                : _PodiumColumn(
                    rank: 3,
                    ambassador: third,
                    height: 114,
                    isCurrentUser: third.id == currentUserId,
                  ),
          ),
        ],
      ),
    );
  }
}

class _PodiumColumn extends StatelessWidget {
  const _PodiumColumn({
    required this.rank,
    required this.ambassador,
    required this.height,
    required this.isCurrentUser,
  });

  final int rank;
  final Ambassador ambassador;
  final double height;
  final bool isCurrentUser;

  bool get _isFirst => rank == 1;

  Color get _medalColor {
    switch (rank) {
      case 1:
        return AppColors.tierGold;
      case 2:
        return AppColors.tierSilver;
      default:
        return AppColors.tierBronze;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_isFirst) ...[
          Icon(Icons.emoji_events, color: _medalColor, size: 28),
          const SizedBox(height: 4),
        ],
        _InitialsAvatar(
          name: ambassador.name,
          radius: _isFirst ? 34 : 26,
          ringColor: _medalColor,
          ringWidth: _isFirst ? 4 : 3,
        ),
        const SizedBox(height: 8),
        Container(
          height: height,
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: _isFirst
                ? AppColors.secondaryContainer.withValues(alpha: 0.6)
                : AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isCurrentUser
                  ? AppColors.primaryContainer
                  : AppColors.cardBorder,
              width: isCurrentUser ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              Text(
                '#$rank',
                style: AppTheme.bodySm.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                isCurrentUser ? 'You' : ambassador.name,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTheme.labelMd,
              ),
              const SizedBox(height: 2),
              Text(
                '${_pointsFormat.format(ambassador.points)} pts',
                style: AppTheme.bodySm.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// A ranked row for positions 4+, highlighted if it's the current user.
class _RankRow extends StatelessWidget {
  const _RankRow({
    required this.rank,
    required this.ambassador,
    required this.isCurrentUser,
  });

  final int rank;
  final Ambassador ambassador;
  final bool isCurrentUser;

  @override
  Widget build(BuildContext context) {
    final tier = TierInfo.fromPoints(ambassador.points);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isCurrentUser
            ? AppColors.primaryContainer.withValues(alpha: 0.12)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        border: isCurrentUser
            ? Border.all(color: AppColors.primaryContainer)
            : null,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              '$rank',
              style: AppTheme.labelMd.copyWith(
                color: isCurrentUser
                    ? AppColors.primaryContainer
                    : AppColors.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: 8),
          _InitialsAvatar(name: ambassador.name, radius: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isCurrentUser ? '${ambassador.name} (You)' : ambassador.name,
                  style: AppTheme.headlineSm.copyWith(fontSize: 15),
                ),
                const SizedBox(height: 4),
                TierBadge(tier: tier),
              ],
            ),
          ),
          Text(
            '${_pointsFormat.format(ambassador.points)} pts',
            style: AppTheme.labelMd,
          ),
        ],
      ),
    );
  }
}

/// Placeholder circular avatar showing initials (no photo assets available).
class _InitialsAvatar extends StatelessWidget {
  const _InitialsAvatar({
    required this.name,
    required this.radius,
    this.ringColor,
    this.ringWidth = 0,
  });

  final String name;
  final double radius;
  final Color? ringColor;
  final double ringWidth;

  String get _initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: radius * 2,
      height: radius * 2,
      padding: EdgeInsets.all(ringWidth),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: ringColor != null
            ? Border.all(color: ringColor!, width: ringWidth)
            : null,
      ),
      child: CircleAvatar(
        backgroundColor: AppColors.secondaryContainer,
        child: Text(
          _initials,
          style: AppTheme.labelMd.copyWith(color: AppColors.onBackground),
        ),
      ),
    );
  }
}
