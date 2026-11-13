import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  String _label(int index) {
    switch (index) {
      case 1:
        return 'Bronze';
      case 2:
        return 'Silver';
      case 3:
        return 'Gold';
      default:
        return 'Neutral';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<int?>(
      ambassadorStateProvider.select<int?>((s) => s.ambassador?.level.index),
      (previous, next) async {
        if (previous != null && next != null && next > previous) {
          final prefs = await SharedPreferences.getInstance();
          final lastSeen =
              prefs.getInt(_kLastSeenLevelKey) ?? 0;
          if (next <= lastSeen) return; // already celebrated once
          await prefs.setInt(_kLastSeenLevelKey, next);
          if (context.mounted) {
            const subtitle = 'Bienvenue au niveau';
            TierCelebration.show(
              context,
              tierIndex: next,
              tierName: _label(next),
              subtitle: subtitle,
            );
          }
        }
      },
    );

    return child;
  }
}
