import 'dart:async';
import 'package:flutter/material.dart';
import 'package:app_links/app_links.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../shared/navigation/app_router.dart';
import '../../shared/navigation/app_routes.dart';

class DeepLinkService {
  static final DeepLinkService _instance = DeepLinkService._internal();
  factory DeepLinkService() => _instance;
  DeepLinkService._internal();

  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  Future<void> initDeepLinks() async {
    _appLinks = AppLinks();

    // Handle initial uri (cold start)
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        // Delay handling the initial link to avoid race conditions with GoRouter initialization
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _handleDeepLink(initialUri);
        });
      }
    } catch (e) {
      debugPrint('[DeepLinkService] Failed to get initial link: $e');
    }

    // Handle incoming deep links while app is running
    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      _handleDeepLink(uri);
    }, onError: (err) {
      debugPrint('[DeepLinkService] Deep link stream error: $err');
    });
  }

  void _handleDeepLink(Uri uri) {
    debugPrint('[DeepLinkService] Received deep link: $uri');

    // On check le custom scheme "maamora" et le host "join"
    // Exemple : maamora://join/123 -> scheme: maamora, host: join, path: /123
    if (uri.scheme == 'maamora' && uri.host == 'join') {
      final session = Supabase.instance.client.auth.currentSession;
      if (session != null) {
        // Utilisateur déjà connecté, on l'envoie vers le dashboard
        appRouter.go(AppRoutes.dashboard);
        return;
      }
      
      // Pas connecté, on transmet la route à go_router
      // ex: '/join' + '/123' -> '/join/123'
      appRouter.go('/join${uri.path}');
    }
  }

  void dispose() {
    _linkSubscription?.cancel();
  }
}
