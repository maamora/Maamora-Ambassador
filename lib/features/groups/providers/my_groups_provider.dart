import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/supabase_service.dart';
import '../../../models/models.dart';

final myGroupsProvider =
    AsyncNotifierProvider<MyGroupsNotifier, List<DealGroup>>(
        MyGroupsNotifier.new);

class MyGroupsNotifier extends AsyncNotifier<List<DealGroup>> {
  @override
  Future<List<DealGroup>> build() => _fetch();

  Future<List<DealGroup>> _fetch() async {
    return supabaseService.getMyDealGroups();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_fetch);
  }

  Future<void> createGroup({
    required String productName,
    required String productDescription,
    required double pricePerPerson,
    required int seatsTotal,
    String? productImageUrl,
  }) async {
    await supabaseService.createDealGroup(
      productName: productName,
      productDescription: productDescription,
      pricePerPerson: pricePerPerson,
      seatsTotal: seatsTotal,
      productImageUrl: productImageUrl,
    );
    await refresh();
  }

  Future<void> addParticipant(String groupId) async {
    await supabaseService.incrementGroupMember(groupId);
    await refresh();
  }
}
