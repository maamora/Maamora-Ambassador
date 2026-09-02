import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/models.dart';

class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  String? get currentUserId => _client.auth.currentUser?.id;

  // -- Profile & Status --

  Future<Map<String, dynamic>?> getMyAmbassadorStatus() async {
    // The RPC returns { status: '...', rejection_reason: '...' }
    final response = await _client.rpc('get_my_ambassador_status');
    if (response == null) return null;
    return response as Map<String, dynamic>;
  }

  Future<Ambassador?> getMyProfile() async {
    if (currentUserId == null) return null;
    final response = await _client
        .from('ambassadors')
        .select()
        .eq('id', currentUserId!)
        .maybeSingle();
    
    if (response == null) return null;
    return Ambassador.fromJson(response);
  }

  Future<void> updateMyProfile({
    String? fullName,
    String? phone,
    String? city,
    String? payoutMethod,
    String? payoutBankRib,
    String? payoutCashPoint,
  }) async {
    if (currentUserId == null) throw Exception('Not logged in');
    
    final updates = <String, dynamic>{};
    if (fullName != null) updates['full_name'] = fullName;
    if (phone != null) updates['phone'] = phone;
    if (city != null) updates['city'] = city;
    if (payoutMethod != null) updates['payout_method'] = payoutMethod;
    if (payoutBankRib != null) updates['payout_bank_rib'] = payoutBankRib;
    if (payoutCashPoint != null) updates['payout_cash_point'] = payoutCashPoint;

    if (updates.isEmpty) return;

    await _client.from('ambassadors').update(updates).eq('id', currentUserId!);
  }

  // -- Deal Groups --

  Future<List<DealGroup>> getMyDealGroups() async {
    if (currentUserId == null) return [];
    final response = await _client
        .from('deal_groups')
        .select()
        .eq('ambassador_id', currentUserId!)
        .order('created_at', ascending: false);
    
    return (response as List<dynamic>).map((e) => DealGroup.fromJson(e)).toList();
  }

  Future<void> createDealGroup({
    required String productName,
    required String productDescription,
    required double pricePerPerson,
    required int seatsTotal,
    String? productImageUrl,
  }) async {
    await _client.rpc('create_deal_group', params: {
      'p_product_name': productName,
      'p_product_description': productDescription,
      'p_price_per_person': pricePerPerson,
      'p_seats_total': seatsTotal,
      'p_product_image_url': productImageUrl,
    });
  }

  Future<void> incrementGroupMember(String groupId, {int count = 1}) async {
    await _client.rpc('increment_group_member', params: {
      'p_group_id': groupId,
      'p_count': count,
    });
  }

  Future<void> incrementGroupTaps(String slug) async {
    await _client.rpc('increment_group_taps', params: {
      'p_slug': slug,
    });
  }

  // -- Wallet & Commissions --

  Future<double> getMyWalletBalance() async {
    final response = await _client.rpc('get_my_wallet_balance');
    if (response is List) {
      if (response.isEmpty) return 0.0;
      final first = response.first;
      if (first is num) return first.toDouble();
      if (first is Map) {
        // If it's a map, take the first value
        return (first.values.first as num?)?.toDouble() ?? 0.0;
      }
    }
    return (response as num?)?.toDouble() ?? 0.0;
  }

  Future<List<Commission>> getMyCommissions() async {
    if (currentUserId == null) return [];
    
    // We join with deal_groups to get the product name
    final response = await _client
        .from('commissions')
        .select('*, deal_groups(product_name)')
        .eq('ambassador_id', currentUserId!)
        .order('created_at', ascending: false);

    return (response as List<dynamic>).map((e) => Commission.fromJson(e)).toList();
  }

  Future<List<Payout>> getMyPayouts() async {
    if (currentUserId == null) return [];
    
    final response = await _client
        .from('payouts')
        .select()
        .eq('ambassador_id', currentUserId!)
        .order('created_at', ascending: false);

    return (response as List<dynamic>).map((e) => Payout.fromJson(e)).toList();
  }

  // -- Leaderboard --

  Future<List<Map<String, dynamic>>> getLeaderboard(String city) async {
    final response = await _client.rpc('get_leaderboard', params: {
      'p_city': city,
    });
    return List<Map<String, dynamic>>.from(response as List);
  }
}

final supabaseService = SupabaseService();
