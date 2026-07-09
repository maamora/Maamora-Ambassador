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
        onSignUpSuccess: () => context.go(AppRoutes.dashboard),
      ),
    ),
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
      builder: (context, state) => const RewardsScreen(),
    ),
  ],
);
