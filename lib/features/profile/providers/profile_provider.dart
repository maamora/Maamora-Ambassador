import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/supabase_service.dart';
import '../../../models/models.dart';

final profileProvider = AsyncNotifierProvider<ProfileNotifier, Ambassador?>(ProfileNotifier.new);

class ProfileNotifier extends AsyncNotifier<Ambassador?> {
  @override
  Future<Ambassador?> build() => supabaseService.getMyProfile();

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => supabaseService.getMyProfile());
  }

  Future<void> updateProfile({
    String? phone,
    String? city,
    String? payoutMethod,
    String? payoutBankRib,
    String? payoutCashPoint,
  }) async {
    await supabaseService.updateMyProfile(
      phone: phone,
      city: city,
      payoutMethod: payoutMethod,
      payoutBankRib: payoutBankRib,
      payoutCashPoint: payoutCashPoint,
    );
    await refresh();
  }
}
