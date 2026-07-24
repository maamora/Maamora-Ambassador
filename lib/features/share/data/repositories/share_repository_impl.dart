import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/services/supabase_client_service.dart';
import '../../../../models/models.dart';
import 'share_repository.dart';

class ShareRepositoryImpl implements ShareRepository {
  final SupabaseClient _client;

  ShareRepositoryImpl({SupabaseClient? client})
      : _client = client ?? SupabaseClientService.client;

  @override
  Future<List<Product>> fetchProducts() async {
    final response = await _client.from('products').select('*').order('name');
    final list = response as List<dynamic>;
    return list.map((json) => Product.fromJson(json as Map<String, dynamic>)).toList();
  }

  @override
  Future<Ambassador?> fetchCurrentAmbassador() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return null;

    final response = await _client
        .from('ambassadors')
        .select('*')
        .eq('auth_id', userId)
        .maybeSingle();

    if (response == null) return null;

    return Ambassador(
      id: response['id'] as String,
      name: response['name'] as String? ?? '',
      email: response['email'] as String? ?? '',
      referralCode: response['referral_code'] as String? ?? '',
      points: (response['points_total'] as num?)?.toInt() ?? 0,
    );
  }

  @override
  Future<ProductGroup> getOrCreateProductGroup({
    required String productId,
    required String ambassadorId,
    double? prixGroupe,
    int seuilMin = 5,
  }) async {
    // 1. Rule check: Check if active group exists for ambassador_id & product_id
    final existing = await _client
        .from('product_groups')
        .select('*')
        .eq('ambassador_id', ambassadorId)
        .eq('product_id', productId)
        .eq('statut', 'active')
        .maybeSingle();

    if (existing != null) {
      return ProductGroup.fromJson(existing);
    }

    final payload = <String, dynamic>{
      'product_id': productId,
      'ambassador_id': ambassadorId,
      'seuil_min': seuilMin,
      'compteur_actuel': 0,
      'statut': 'active',
    };
    if (prixGroupe != null) {
      payload['prix_groupe'] = prixGroupe;
    }

    final inserted = await _client
        .from('product_groups')
        .insert(payload)
        .select('*')
        .single();

    return ProductGroup.fromJson(inserted);
  }

  @override
  Future<ReferralLink> getOrCreateReferralLink({
    required String productId,
    required String ambassadorId,
    required String ambassadorCode,
  }) async {
    final existing = await _client
        .from('links')
        .select('*')
        .eq('ambassador_id', ambassadorId)
        .eq('product_id', productId)
        .maybeSingle();

    if (existing != null) {
      return ReferralLink.fromJson(existing);
    }

    final inserted = await _client
        .from('links')
        .insert({
          'ambassador_id': ambassadorId,
          'product_id': productId,
          'code': ambassadorCode,
          'click_count': 0,
        })
        .select('*')
        .single();

    return ReferralLink.fromJson(inserted);
  }

  @override
  String buildReferralUrl({
    required String productId,
    required String ambassadorCode,
  }) {
    return 'https://maamora.app/p/$productId?ref=$ambassadorCode';
  }

  @override
  RealtimeChannel subscribeToProductGroup({
    required String groupId,
    required void Function(ProductGroup updatedGroup) onData,
  }) {
    final channel = _client.channel('public:product_groups:$groupId');

    channel.onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'product_groups',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'id',
        value: groupId,
      ),
      callback: (payload) {
        if (payload.newRecord.isNotEmpty) {
          final updated = ProductGroup.fromJson(payload.newRecord);
          onData(updated);
        }
      },
    ).subscribe();

    return channel;
  }

  @override
  String getProductImageUrl(String imageUrl) {
    if (imageUrl.isEmpty) return '';
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return imageUrl;
    }
    return _client.storage.from('products').getPublicUrl(imageUrl);
  }
}
