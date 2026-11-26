import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/l10n/app_strings.dart';
import '../../design_system/components/celebration_overlay.dart';
import '../../core/services/ambassador_state_provider.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// TIER CELEBRATION WATCHER — auto-fire for the cinematic tier-up overlay.
///
/// Presentation only: it reads the level the session already has
/// (`ambassadorState`), compares it against the last level this device has
/// seen (SharedPreferences), and shows `TierCelebration` on any promotion.
/// It never writes to or triggers any business logic.
///
/// Insert once: inside MainNavigationScreen's build, above the Scaffold.
/// ─────────────────────────────────────────────────────────────────────────────

const String _kLastSeenLevelKey = 'maamora_last_seen_level';

class TierCelebrationWatcher extends ConsumerWidget {
  const TierCelebrationWatcher({super.key, required this.child});

  final Widget child;

  /// Same i18n keys as the dashboard tier labels (FR « Argent », AR « الفضي »).
  String _labelKey(int index) {
    switch (index) {
      case 1:
        return 'dash_tier_bronze';
      case 2:
        return 'dash_tier_silver';
      case 3:
        return 'dash_tier_gold';
      default:
        return 'dash_tier_neutral';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<int?>(
      ambassadorStateProvider.select<int?>((s) => s.ambassador?.level.index),
      (previous, next) async {
        if (previous != null && next != null && next > previous) {
          final prefs = await SharedPreferences.getInstance();
          final lastSeen = prefs.getInt(_kLastSeenLevelKey) ?? 0;
          if (next <= lastSeen) return; // already celebrated once
          await prefs.setInt(_kLastSeenLevelKey, next);
          if (context.mounted) {
            TierCelebration.show(
              context,
              tierIndex: next,
              tierName: context.tr(_labelKey(next)),
              subtitle: context.tr('celebration_welcome_level'),
            );
          }
        }
      },
    );

    return child;
  }
}
