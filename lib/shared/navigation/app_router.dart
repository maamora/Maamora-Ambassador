import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/navigation/navigation_service.dart';
import 'app_routes.dart';
import 'main_navigation_screen.dart';

import '../../features/onboarding/screens/login_screen.dart';
import '../../features/onboarding/screens/register_screen.dart';
import '../../features/onboarding/screens/welcome_screen.dart';


import '../../features/community/screens/community_screen.dart';
import '../../features/pickup/screens/pickup_screen.dart';
import '../../features/groups/screens/order_details_screen.dart';
import '../../features/shop/screens/ambassador_shop_screen.dart';
import '../../features/groups/providers/my_groups_provider.dart';
import '../../models/models.dart';

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

final GoRouter appRouter = GoRouter(
  navigatorKey: NavigationService.navigatorKey,
  initialLocation: AppRoutes.dashboard,
  refreshListenable: GoRouterRefreshStream(
    Supabase.instance.client.auth.onAuthStateChange,
  ),
  redirect: (context, state) {
    return null; // 👈 TEMPORARY: disabled auth to access dashboard directly
    
    final session = Supabase.instance.client.auth.currentSession;
    final isLoggedIn = session != null;

    final isPublicRoute =
        state.matchedLocation == AppRoutes.login ||
        state.matchedLocation == AppRoutes.register ||
        state.matchedLocation == AppRoutes.welcome ||
        state.matchedLocation.startsWith(AppRoutes.callbackLogin);

    if (!isLoggedIn && !isPublicRoute) {
      return AppRoutes.login;
    }

    if (isLoggedIn &&
        (state.matchedLocation == AppRoutes.login ||
            state.matchedLocation == AppRoutes.register)) {
      return AppRoutes.dashboard;
    }

    return null;
  },
  routes: [
    // ── Auth / Onboarding ────────────────────────────────────────────────────
    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => LoginScreen(
        onLoginSuccess: () => context.go(AppRoutes.dashboard),
        onCreateAccount: () => context.go(AppRoutes.register),
      ),
    ),
    GoRoute(
      path: AppRoutes.register,
      builder: (context, state) => RegisterScreen(
        onActivateSuccess: () => context.go(AppRoutes.welcome),
        onGoToLogin: () => context.go(AppRoutes.login),
      ),
    ),
    GoRoute(
      path: AppRoutes.welcome,
      builder: (context, state) => WelcomeScreen(
        onGoToDashboard: () => context.go(AppRoutes.dashboard),
        onSeeHowLevelsWork: () => context.go(AppRoutes.dashboard),
      ),
    ),

    // OAuth callback
    GoRoute(
      path: AppRoutes.callbackLogin,
      builder: (context, state) => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
    ),

    // ── Main app ─────────────────────────────────────────────────────────────
    GoRoute(
      path: AppRoutes.dashboard,
      builder: (context, state) => const MainNavigationScreen(),
    ),

    GoRoute(
      path: AppRoutes.community,
      builder: (context, state) => const CommunityScreen(),
    ),
    GoRoute(
      path: AppRoutes.pickup,
      builder: (context, state) => const PickupScreen(),
    ),
    GoRoute(
      path: AppRoutes.ambassadorShop,
      builder: (context, state) =>
          AmbassadorShopScreen(product: state.extra as Product),
    ),
    GoRoute(
      path: AppRoutes.orderDetails,
      builder: (context, state) {
        final groupData = state.extra as GroupWithProduct?;
        if (groupData == null) {
          return const Scaffold(
            body: Center(
              child: Text(
                'Error: Group data is missing. Please go back and try again.',
              ),
            ),
          );
        }
        return OrderDetailsScreen(groupData: groupData);
      },
    ),
  ],
);
