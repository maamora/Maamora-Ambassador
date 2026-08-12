import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/models.dart';
import 'supabase_service.dart';

class AmbassadorDashboardState {
  final bool isLoading;
  final String? errorMessage;
  final Ambassador? ambassador;

  AmbassadorDashboardState({
    this.isLoading = true,
    this.errorMessage,
    this.ambassador,
  });

  AmbassadorDashboardState copyWith({
    bool? isLoading,
    String? errorMessage,
    Ambassador? ambassador,
  }) {
    return AmbassadorDashboardState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      ambassador: ambassador ?? this.ambassador,
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

      final profile = await supabaseService.getMyProfile();

      if (profile != null) {
        state = state.copyWith(
          isLoading: false,
          ambassador: profile,
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
          column: 'id',
          value: user.id,
        ),
        callback: (payload) {
          final newRecord = payload.newRecord;
          if (mounted && newRecord.isNotEmpty) {
            state = state.copyWith(
              ambassador: Ambassador.fromJson(newRecord),
            );
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
