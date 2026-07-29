import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/models.dart';

class AmbassadorDashboardState {
  final bool isLoading;
  final String? errorMessage;
  final int points;
  final Tier tier;

  AmbassadorDashboardState({
    this.isLoading = true,
    this.errorMessage,
    this.points = 0,
    Tier? tier,
  }) : tier = tier ?? Tier.bronze;

  double get progressToNextTier {
    final nextTier = tier.next;
    if (nextTier == null) return 1.0;
    
    final currentMin = tier.minPoints;
    final nextMin = nextTier.minPoints;
    final range = nextMin - currentMin;
    final progress = points - currentMin;
    
    return (progress / range).clamp(0.0, 1.0);
  }
  
  String get progressLabel {
    final nextTier = tier.next;
    if (nextTier == null) return 'Max tier';
    return 'to ${nextTier.label}';
  }

  AmbassadorDashboardState copyWith({
    bool? isLoading,
    String? errorMessage,
    int? points,
    Tier? tier,
  }) {
    return AmbassadorDashboardState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      points: points ?? this.points,
      tier: tier ?? this.tier,
    );
  }
}

final ambassadorStateProvider = StateNotifierProvider<AmbassadorStateNotifier, AmbassadorDashboardState>((ref) {
  return AmbassadorStateNotifier();
});

class AmbassadorStateNotifier extends StateNotifier<AmbassadorDashboardState> {
  RealtimeChannel? _channel;
  final _supabase = Supabase.instance.client;

  AmbassadorStateNotifier() : super(AmbassadorDashboardState()) {
    _init();
  }

  Future<void> _init() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        state = state.copyWith(isLoading: false, errorMessage: 'User not logged in');
        return;
      }

      final response = await _supabase
          .from('ambassadors')
          .select('points_balance')
          .eq('auth_id', user.id)
          .maybeSingle();

      if (response != null) {
        final points = (response['points_balance'] as num?)?.toInt() ?? 0;
        state = state.copyWith(
          isLoading: false,
          points: points,
          tier: TierInfo.fromPoints(points),
        );
      } else {
        state = state.copyWith(isLoading: false, errorMessage: 'Ambassador not found');
      }

      _channel = _supabase.channel('public:ambassadors:${user.id}');
      _channel!.onPostgresChanges(
        event: PostgresChangeEvent.update,
        schema: 'public',
        table: 'ambassadors',
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: 'auth_id',
          value: user.id,
        ),
        callback: (payload) {
          final newRecord = payload.newRecord;
          if (newRecord.containsKey('points_balance')) {
            final points = (newRecord['points_balance'] as num?)?.toInt() ?? 0;
            if (mounted) {
              state = state.copyWith(
                points: points,
                tier: TierInfo.fromPoints(points),
              );
            }
          }
        },
      ).subscribe();
    } catch (e) {
      if (mounted) {
        state = state.copyWith(isLoading: false, errorMessage: e.toString());
      }
    }
  }

  @override
  void dispose() {
    _channel?.unsubscribe();
    super.dispose();
  }
}
