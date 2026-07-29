import '../../../../models/models.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class ShareRepository {
  /// Fetch list of products from Supabase
  Future<List<Product>> fetchProducts();

  /// Retrieve existing active product group or create a new one if unlocked/none exists
  Future<ProductGroup> getOrCreateProductGroup({
    required String productId,
    required String ambassadorId,
    double? prixGroupe,
    int seuilMin = 5,
  });

  /// Retrieve or create a referral link for ambassador & product
  Future<ReferralLink> getOrCreateReferralLink({
    required String productId,
    required String ambassadorId,
    required String ambassadorCode,
  });

  /// Build full shareable referral link URL
  String buildReferralUrl({
    required String productId,
    required String ambassadorCode,
  });

  /// Realtime channel subscription for product group changes (compteur_actuel / statut)
  RealtimeChannel subscribeToProductGroup({
    required String groupId,
    required void Function(ProductGroup updatedGroup) onData,
  });

  /// Get absolute URL for product image (handles Supabase Storage relative paths)
  String getProductImageUrl(String imageUrl);

  /// Fetch currently authenticated ambassador from database
  Future<Ambassador?> fetchCurrentAmbassador();

  Future<ProductGroup?> fetchExistingProductGroup({
    required String productId,
    required String ambassadorId,
  });
}
