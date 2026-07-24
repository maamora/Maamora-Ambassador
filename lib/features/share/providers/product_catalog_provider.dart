import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/mock_data_service.dart';
import '../../../../models/models.dart';
import '../data/repositories/share_repository.dart';
import '../data/repositories/share_repository_impl.dart';

final shareRepositoryProvider = Provider<ShareRepository>((ref) {
  return ShareRepositoryImpl();
});

final productCatalogProvider = AsyncNotifierProvider<ProductCatalogNotifier, List<Product>>(() {
  return ProductCatalogNotifier();
});

class ProductCatalogNotifier extends AsyncNotifier<List<Product>> {
  late final ShareRepository _repository;

  @override
  Future<List<Product>> build() async {
    _repository = ref.watch(shareRepositoryProvider);
    return fetchCatalog();
  }

  Future<List<Product>> fetchCatalog() async {
    try {
      return await _repository.fetchProducts();
    } catch (e) {
      print('Error fetching products: $e');
      return [];
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => fetchCatalog());
  }
}
