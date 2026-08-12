import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/supabase_service.dart';

class LeaderboardData {
  final List<Map<String, dynamic>> cityRankings;
  final List<Map<String, dynamic>> nationalRankings;

  LeaderboardData({
    required this.cityRankings,
    required this.nationalRankings,
  });
}

final leaderboardProvider = AsyncNotifierProviderFamily<LeaderboardNotifier, LeaderboardData, String>(LeaderboardNotifier.new);

class LeaderboardNotifier extends FamilyAsyncNotifier<LeaderboardData, String> {
  @override
  Future<LeaderboardData> build(String arg) async {
    final cityRankings = await supabaseService.getLeaderboard(arg);
    final nationalRankings = await supabaseService.getLeaderboard(''); // empty string for national
    return LeaderboardData(
      cityRankings: cityRankings,
      nationalRankings: nationalRankings,
    );
  }
  
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => build(arg));
  }
}
