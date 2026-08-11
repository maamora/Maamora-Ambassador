class AppRoutes {
  AppRoutes._();

  // ── Auth / Onboarding ──────────────────────────────────────────────────────
  static const String login = '/login';
  static const String register = '/register';
  static const String welcome = '/welcome';

  // ── Callback (OAuth web) ───────────────────────────────────────────────────
  static const String callbackLogin = '/callback/login';

  // ── Main app ───────────────────────────────────────────────────────────────
  static const String dashboard = '/dashboard';
  static const String share = '/share';
  static const String leaderboard = '/leaderboard';
  static const String rewards = '/rewards';
  static const String notifications = '/notifications'; // phase 2
  // ── Admin app ────────────────────────────────────────────────────────────
  static const String admin = '/admin';
  static const String adminInvite = '/admin/invite';
  static const String adminAmbassadorsPending = '/admin/ambassadors/pending';
  static const String adminAmbassadorsList = '/admin/ambassadors/list';
  static const String adminGroupsPending = '/admin/groups';
  static const String adminCommissions = '/admin/commissions';
  static const String adminAuditLog = '/admin/audit-log';
  static const String community = '/community';
  static const String pickup = '/pickup';
  static const String productDetail = '/product-detail';
  static const String ambassadorShop = '/ambassador-shop';
  static const String orderDetails = '/order-details';
  static const String profile = '/profile';
  static const String rules = '/rules';
}
