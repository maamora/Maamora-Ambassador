// features/onboarding/providers/profile_provider.dart
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/supabase_client_service.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

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

      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('Utilisateur non connecté');
      }

      // 1. Chercher l'ambassadeur (maybeSingle évite PGRST116 si absent)
      var data = await _supabase
          .from('ambassadors')
          .select('*, tiers(name)')
          .eq('auth_id', user.id)
          .maybeSingle();

      // Si aucune ligne n'existe encore (ex: premier login Google sur web,
      // avant que le trigger SQL ait créé la ligne), on la crée ici.
      if (data == null) {
        debugPrint('[ProfileProvider] Aucun ambassadeur trouvé — création automatique.');
        final name = user.userMetadata?['full_name'] ??
            user.userMetadata?['name'] ??
            user.email?.split('@').first ??
            'Ambassadeur';
        final email = user.email ?? '';
        // Code de parrainage provisoire — le trigger le remplacera à terme
        final tempCode = 'AMB${DateTime.now().millisecondsSinceEpoch % 100000}';
        await _supabase.from('ambassadors').insert({
          'auth_id': user.id,
          'name': name,
          'email': email,
          'referral_code': tempCode,
          'points_total': 0,
        });
        // Relit la ligne fraîchement insérée avec son tier
        data = await _supabase
            .from('ambassadors')
            .select('*, tiers(name)')
            .eq('auth_id', user.id)
            .single();
      }

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
    // 1. Déconnexion de Supabase, qui ne doit pas être bloquée par Google
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      debugPrint('Erreur lors de la déconnexion Supabase: $e');
    }

    // 2. Déconnexion de Google avec le clientId, entourée d'un try-catch
    try {
      final googleSignIn = GoogleSignIn(
        serverClientId: dotenv.env['GOOGLE_WEB_CLIENT_ID'],
      );
      await googleSignIn.signOut();
    } catch (e) {
      debugPrint('Erreur lors de la déconnexion GoogleSignIn: $e');
    }
  }
}
