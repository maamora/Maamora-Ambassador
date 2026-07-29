import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/services/mock_data_service.dart';
import '../../../../models/models.dart';
import '../data/repositories/share_repository.dart';
import 'product_catalog_provider.dart';

class CreateGroupState {
  final bool isLoading;
  final String? errorMessage;
  final Ambassador? ambassador;
  final ProductGroup? productGroup;
  final ReferralLink? referralLink;
  final String? referralUrl;

  const CreateGroupState({
    this.isLoading = false,
    this.errorMessage,
    this.ambassador,
    this.productGroup,
    this.referralLink,
    this.referralUrl,
  });

  CreateGroupState copyWith({
    bool? isLoading,
    String? errorMessage,
    Ambassador? ambassador,
    ProductGroup? productGroup,
    ReferralLink? referralLink,
    String? referralUrl,
  }) {
    return CreateGroupState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      ambassador: ambassador ?? this.ambassador,
      productGroup: productGroup ?? this.productGroup,
      referralLink: referralLink ?? this.referralLink,
      referralUrl: referralUrl ?? this.referralUrl,
    );
  }
}

final createGroupProvider = StateNotifierProvider.family<CreateGroupNotifier, CreateGroupState, Product>(
  (ref, product) {
    final repository = ref.watch(shareRepositoryProvider);
    return CreateGroupNotifier(repository, product);
  },
);

class CreateGroupNotifier extends StateNotifier<CreateGroupState> {
  final ShareRepository _repository;
  final Product _product;
  RealtimeChannel? _realtimeChannel;

  CreateGroupNotifier(this._repository, this._product) : super(const CreateGroupState()) {
    initialize();
  }

  Future<void> initialize() async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      // 1. Fetch current ambassador
      Ambassador? ambassador;
      try {
        ambassador = await _repository.fetchCurrentAmbassador();
      } catch (e) {
        print('Error fetching ambassador: $e');
      }

      if (ambassador == null) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Veuillez vous connecter pour créer un groupe.',
        );
        return;
      }

      // 2. Build Referral URL & Link record
      ReferralLink? link;
      try {
        link = await _repository.getOrCreateReferralLink(
          productId: _product.id,
          ambassadorId: ambassador.id,
          ambassadorCode: ambassador.referralCode,
        );
      } catch (_) {}

      final referralUrl = _repository.buildReferralUrl(
        productId: _product.id,
        ambassadorCode: ambassador.referralCode,
      );

      // 3. Product Group logic (if product is grouped or has group campaign)
      ProductGroup? group;
      try {
        group = await _repository.getOrCreateProductGroup(
          productId: _product.id,
          ambassadorId: ambassador.id,
          prixGroupe: _product.price * 0.85, // 15% discount for group buy
          seuilMin: 5,
        );

        // 4. Realtime updates subscription on product group
        _subscribeToRealtimeGroupUpdates(group.id);
      } catch (e, stack) {
        print('Error creating group: $e\n$stack');
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Erreur lors de la création du groupe.',
        );
        return;
      }

      state = state.copyWith(
        isLoading: false,
        ambassador: ambassador,
        productGroup: group,
        referralLink: link,
        referralUrl: referralUrl,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erreur lors de l\'initialisation du partage: $e',
      );
    }
  }

  void _subscribeToRealtimeGroupUpdates(String groupId) {
    _realtimeChannel?.unsubscribe();
    _realtimeChannel = _repository.subscribeToProductGroup(
      groupId: groupId,
      onData: (updatedGroup) {
        if (mounted) {
          state = state.copyWith(productGroup: updatedGroup);
        }
      },
    );
  }

  @override
  void dispose() {
    _realtimeChannel?.unsubscribe();
    super.dispose();
  }
}
