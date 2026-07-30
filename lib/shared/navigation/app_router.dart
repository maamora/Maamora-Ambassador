import 'package:flutter/material.dart';
import 'package:ambassadors/features/onboarding/screens/email_verification_screen.dart';
import 'package:ambassadors/features/onboarding/screens/forgot_password_screen.dart';
import 'package:ambassadors/features/onboarding/screens/reset_password_screen.dart';
import 'package:go_router/go_router.dart';
import '../../core/navigation/navigation_service.dart';
import 'app_routes.dart';
import '../../features/onboarding/screens/sign_up_screen.dart';
import '../../models/models.dart';


import '../../features/leaderboard_rewards/screens/leaderboard_screen.dart';
import '../../features/leaderboard_rewards/screens/rewards_screen.dart';
import '../../features/onboarding/screens/ambassador_intro_screen.dart';
import '../../features/onboarding/screens/login_screen.dart';
import 'main_navigation_screen.dart';
import '../../features/community/screens/community_screen.dart';
import '../../features/pickup/screens/pickup_screen.dart';
import '../../features/groups/screens/order_details_screen.dart';
import '../../features/shop/screens/ambassador_shop_screen.dart';
import '../../features/groups/providers/my_groups_provider.dart';

final GoRouter appRouter = GoRouter(
  navigatorKey: NavigationService.navigatorKey,
  initialLocation: AppRoutes.introAmbassador,
  routes: [
    GoRoute(
      path: AppRoutes.introAmbassador,
      builder: (context, state) => AmbassadorIntroScreen(
        onStartApplication: () => context.go(AppRoutes.signUp),
      ),
    ),
    GoRoute(
      path: AppRoutes.signUp,
      builder: (context, state) => SignUpScreen(
        onGoToLogin: () => context.go(AppRoutes.login),
        // 1. On passe l'email saisi au callback de succès
        onSignUpSuccess: (email) =>
            context.go('${AppRoutes.verifyEmail}?email=$email'),
      ),
    ),
    GoRoute(
      path: AppRoutes.verifyEmail,
      builder: (context, state) {
        final email = state.uri.queryParameters['email'] ?? '';
        return EmailVerificationScreen(
          email: email,
          onGoToLogin: () => context.go(AppRoutes.login),
        );
      },
    ),
    // GoRoute(
    //   path: AppRoutes.home,
    //   builder: (context, state) => LoginScreen(
    //     onCreateAccount: () => context.go(AppRoutes.signUp),
    //     onLoginSuccess: () => context.go(AppRoutes.dashboard),
    //     onForgotPassword: () => context.go(AppRoutes.forgotPassword),
    //   ),
    // ),
    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => LoginScreen(
        onCreateAccount: () => context.go(AppRoutes.signUp),
        onLoginSuccess: () => context.go(AppRoutes.dashboard),
        onForgotPassword: () => context.go(AppRoutes.forgotPassword),
      ),
    ),
    GoRoute(
      path: AppRoutes.forgotPassword,
      builder: (context, state) => ForgotPasswordScreen(
        onBackToLogin: () => context.go(AppRoutes.login),
      ),
    ),
    GoRoute(
      path: AppRoutes.resetPassword,
      builder: (context, state) => ResetPasswordScreen(
        onResetSuccess: () => context.go(AppRoutes.login),
      ),
    ),
    GoRoute(
      path: AppRoutes.dashboard,
      builder: (context, state) => const MainNavigationScreen(),
    ),

    GoRoute(
      path: AppRoutes.leaderboard,
      builder: (context, state) => const LeaderboardScreen(),
    ),
    GoRoute(
      path: AppRoutes.rewards,
      // state.extra carries the real points balance from the caller.
      builder: (context, state) =>
          RewardsScreen(initialPoints: state.extra as int?),
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
      builder: (context, state) => AmbassadorShopScreen(product: state.extra as Product),
    ),
    GoRoute(
      path: AppRoutes.orderDetails,
      builder: (context, state) {
        final groupData = state.extra as GroupWithProduct?;
        if (groupData == null) {
          // Fallback in case of hot reload while on the page, or missing data
          return const Scaffold(body: Center(child: Text('Error: Group data is missing. Please go back and try again.')));
        }
        return OrderDetailsScreen(
          groupData: groupData,
        );
      },
    ),
  ],
);
