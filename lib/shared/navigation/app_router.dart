import 'package:ambassadors/features/onboarding/screens/email_verification_screen.dart';
import 'package:go_router/go_router.dart';
import '../../core/navigation/navigation_service.dart';
import 'app_routes.dart';
import '../../features/onboarding/screens/sign_up_screen.dart';
import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/share/screens/share_screen.dart';
import '../../features/leaderboard_rewards/screens/leaderboard_screen.dart';
import '../../features/leaderboard_rewards/screens/rewards_screen.dart';
import '../../features/onboarding/screens/ambassador_intro_screen.dart';
import '../../features/onboarding/screens/login_screen.dart';
import 'main_navigation_screen.dart';
import '../../features/community/screens/community_screen.dart';
import '../../features/pickup/screens/pickup_screen.dart';

/// Ajoutez votre écran ici dès qu'il est prêt (une ligne par GoRoute).
/// Chacun ajoute SA ligne — évitez de reformater tout le fichier pour
/// limiter les conflits Git avec les autres.
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
        // 2. On récupère l'email depuis les paramètres de recherche (?email=...)
        final email = state.uri.queryParameters['email'] ?? '';
        return EmailVerificationScreen(
          email: email,
          onGoToLogin: () => context.go(AppRoutes.login),
        );
      },
    ),
    // GoRoute(
    //   path: AppRoutes.signUp,
    //   builder: (context, state) => SignUpScreen(
    //     onGoToLogin: () => context.go(AppRoutes.login),
    //     onSignUpSuccess: () => context.go(AppRoutes.dashboard),
    //   ),
    // ),
    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => LoginScreen(
        onCreateAccount: () => context.go(AppRoutes.signUp),
        onLoginSuccess: () => context.go(AppRoutes.dashboard),
      ),
    ),
    GoRoute(
      path: AppRoutes.dashboard,
      builder: (context, state) => const MainNavigationScreen(),
    ),
    GoRoute(
      path: AppRoutes.share,
      builder: (context, state) => const ShareScreen(),
    ),
    GoRoute(
      path: AppRoutes.leaderboard,
      builder: (context, state) => const LeaderboardScreen(),
    ),
    GoRoute(
      path: AppRoutes.rewards,
      // state.extra porte le solde de points réel transmis par l'écran
      // appelant (ex: bouton "Échanger" du Profile) — voir le point
      // signalé #5 dans rewards_screen.dart.
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
  ],
);
