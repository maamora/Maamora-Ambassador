import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/supabase_client_service.dart';
import '../../../models/models.dart';

/// Holds a group together with its joined product data (name, image_url).
class GroupWithProduct {
  final ProductGroup group;
  final String productName;
  final String productImageUrl;
  final double productPrice;

  const GroupWithProduct({
    required this.group,
    required this.productName,
    required this.productImageUrl,
    required this.productPrice,
  });
}

/// Fetches all product_groups belonging to the currently logged-in ambassador
/// and joins the related product data so the UI can display name + image.
final myGroupsProvider =
    AsyncNotifierProvider<MyGroupsNotifier, List<GroupWithProduct>>(
        MyGroupsNotifier.new);

class MyGroupsNotifier extends AsyncNotifier<List<GroupWithProduct>> {
  final SupabaseClient _client = SupabaseClientService.client;

  @override
  Future<List<GroupWithProduct>> build() => _fetch();

  Future<List<GroupWithProduct>> _fetch() async {
    final userId = _client.auth.currentUser?.id;

    // Resolve ambassador id from auth_id
    String? ambassadorId;
    if (userId != null) {
      final amb = await _client
          .from('ambassadors')
          .select('id')
          .eq('auth_id', userId)
          .maybeSingle();
      ambassadorId = amb?['id'] as String?;
    }

    if (ambassadorId == null) {
      // Not authenticated yet — return empty list (no crash, no mock data)
      return [];
    }

    // Fetch groups with joined product info using a single query
    final rows = await _client
        .from('product_groups')
        .select('*, products(name, image_url, price)')
        .eq('ambassador_id', ambassadorId)
        .order('created_at', ascending: false);

    return (rows as List<dynamic>).map((row) {
      final productRow = row['products'] as Map<String, dynamic>? ?? {};
      final group = ProductGroup.fromJson(row as Map<String, dynamic>);
      return GroupWithProduct(
        group: group,
        productName: productRow['name'] as String? ?? 'Produit',
        productImageUrl: productRow['image_url'] as String? ?? '',
        productPrice: (productRow['price'] as num?)?.toDouble() ?? 0.0,
      );
    }).toList();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_fetch);
  }
}
