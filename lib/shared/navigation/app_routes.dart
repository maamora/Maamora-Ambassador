/// Noms de routes centralisés — figés en semaine 1, chaque dev ajoute
/// sa route ici quand son écran est prêt (petit risque de conflit git,
/// mais fichier volontairement minimal pour limiter la casse).
class AppRoutes {
  AppRoutes._();

  static const String signUp = '/sign-up';
  static const String dashboard = '/dashboard';
  static const String share = '/share';
  static const String leaderboard = '/leaderboard';
  static const String rewards = '/rewards';
  static const String notifications = '/notifications'; // phase 2
  static const String admin = '/admin'; // phase 2
}
