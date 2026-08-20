// ignore_for_file: dead_code
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
import '../../features/onboarding/screens/status_screens.dart';

import '../../features/admin/screens/admin_navigation_screen.dart';
import '../../features/admin/screens/admin_profile_screen.dart';
import '../../features/admin/screens/admin_ambassador_details_screen.dart';

import '../../features/community/screens/community_screen.dart';
import '../../features/pickup/screens/pickup_screen.dart';
import '../../features/groups/providers/my_groups_provider.dart';
import '../../features/groups/providers/my_groups_provider.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/rules/screens/rules_screen.dart';
import '../../features/groups/screens/create_group_screen.dart';
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
  initialLocation: AppRoutes.login,
  refreshListenable: GoRouterRefreshStream(
    Supabase.instance.client.auth.onAuthStateChange,
  ),
  redirect: (context, state) {
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
      builder: (context, state) {
        final inviteCode = state.uri.queryParameters['code'];
        return RegisterScreen(
          initialInviteCode: inviteCode,
          onActivateSuccess: () => context.go(AppRoutes.pending),
          onGoToLogin: () => context.go(AppRoutes.login),
        );
      },
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
      builder: (context, state) =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
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
      path: AppRoutes.profile,
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: AppRoutes.rules,
      builder: (context, state) => const RulesScreen(),
    ),
    GoRoute(
      path: AppRoutes.createGroup,
      builder: (context, state) => const CreateGroupScreen(),
    ),

    // ── Admin app ─────────────────────────────────────────────────────────
    GoRoute(
      path: AppRoutes.admin,
      builder: (context, state) => const AdminNavigationScreen(),
    ),
    GoRoute(
      path: AppRoutes.adminProfile,
      builder: (context, state) => const AdminProfileScreen(),
    ),
    GoRoute(
      path: '${AppRoutes.adminAmbassadorDetails}/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return AdminAmbassadorDetailsScreen(ambassadorId: id);
      },
    ),

    // ── Status Screens ────────────────────────────────────────────────────
    GoRoute(
      path: AppRoutes.pending,
      builder: (context, state) => const PendingScreen(),
    ),
    GoRoute(
      path: AppRoutes.rejected,
      builder: (context, state) => const RejectedScreen(),
    ),
    GoRoute(
      path: AppRoutes.paused,
      builder: (context, state) => const PausedScreen(),
    ),
    GoRoute(
      path: AppRoutes.unregistered,
      builder: (context, state) => const UnregisteredScreen(),
    ),
  ],
);
