import '../../../models/models.dart';

/// Pure calculation behind the "next level" card (easy to unit test).
/// Same thresholds as before: Bronze 6, Silver 27, Gold 360 orders.
class LevelProgress {
  const LevelProgress({
    required this.target,
    required this.completed,
    required this.nextTierKey,
    required this.isMax,
    required this.daysLeft,
  });

  final int target;
  final int completed;

  /// Translation key of the tier being worked towards.
  final String nextTierKey;
  final bool isMax;
  final int daysLeft;

  double get ratio =>
      target > 0 ? (completed / target).clamp(0.0, 1.0).toDouble() : 0.0;

  int get remaining => (target - completed).clamp(0, target).toInt();

  factory LevelProgress.from(Ambassador ambassador, {DateTime? now}) {
    final today = now ?? DateTime.now();
    final completed = ambassador.totalValidatedMembers;

    final (int target, String tierKey, bool isMax) = switch (ambassador.level) {
      AmbassadorLevel.neutral => (6, 'dash_tier_bronze', false),
      AmbassadorLevel.bronze => (27, 'dash_tier_silver', false),
      AmbassadorLevel.silver => (360, 'dash_tier_gold', false), // 6 groups of 60+
      AmbassadorLevel.gold => (
          completed > 0 ? completed : 1,
          'dash_tier_max',
          true,
        ),
    };

    var daysLeft = 0;
    final activatedAt = ambassador.activatedAt;
    if (activatedAt != null) {
      final diff = today.difference(activatedAt).inDays;
      if (diff <= 7) {
        daysLeft = 7 - diff;
      } else {
        final daysInMonth = DateTime(today.year, today.month + 1, 0).day;
        daysLeft = daysInMonth - today.day;
      }
    }

    return LevelProgress(
      target: target,
      completed: completed,
      nextTierKey: tierKey,
      isMax: isMax,
      daysLeft: daysLeft,
    );
  }
}
