// features/onboarding/providers/profile_provider.dart
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/supabase_client_service.dart';

class ProfileProvider extends ChangeNotifier {
  final _supabase = SupabaseClientService.client;

  bool isLoading = true;
  String? errorMessage;

  Map<String, dynamic>? ambassadorData;
  String? tierName;
  int ordersCount = 0;
  int linksCount = 0; // Utilisé pour remplacer "Groupes" si applicable

  ProfileProvider() {
    fetchProfileData();
  }

  Future<void> fetchProfileData() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('Utilisateur non connecté');
      }

      // 1. Récupérer les infos de l'ambassadeur et son tier
      final data = await _supabase
          .from('ambassadors')
          .select('*, tiers(name)')
          .eq('auth_id', userId)
          .single();

      ambassadorData = data;

      // Extraction sécurisée du nom du tier
      if (data['tiers'] != null) {
        tierName = data['tiers']['name'];
      }

      final ambassadorId = data['id'];

      // 2. Compter les commandes
      final ordersResponse = await _supabase
          .from('orders')
          .select('id')
          .eq('ambassador_id', ambassadorId)
          .count(CountOption.exact);

      ordersCount = ordersResponse.count;

      // 3. Compter les liens (remplace "Groupes" en attendant)
      final linksResponse = await _supabase
          .from('links')
          .select('id')
          .eq('ambassador_id', ambassadorId)
          .count(CountOption.exact);

      linksCount = linksResponse.count;
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }
}
