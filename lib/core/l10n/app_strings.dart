import 'package:flutter/widgets.dart';

/// Lightweight AR/EN translations.
/// Usage in any widget:  context.tr('nav_home')
/// To add a string: add the key in BOTH maps below.
class AppStrings {
  AppStrings._();

  static String of(String lang, String key) =>
      _values[lang]?[key] ?? _values['en']![key] ?? key;

  static const Map<String, Map<String, String>> _values = {
    'en': {
      'nav_home': 'Home',
      'nav_board': 'Leaders',
      'nav_share': 'Share',
      'nav_wallet': 'Wallet',
      'nav_profile': 'Profile',
      'title_home': 'Home',
      'title_board': 'Leaderboard',
      'title_share': 'Share',
      'title_wallet': 'My wallet',
      'login_tagline': 'Together we save more',
      'login_welcome': 'Welcome',
      'login_subtitle': 'Sign in to your ambassador account',
      'login_google': 'Continue with Google',
      'login_new': 'New here?',
      'login_need_invite':
          'You need an invite code to join the ambassador program.',
      'login_have_invite': 'I have an invite code',
      'login_badge': 'Ambassador app',
      'common_loading': 'Loading...',
      'common_retry': 'Try again',
    },
    'ar': {
      'nav_home': 'الرئيسية',
      'nav_board': 'المتصدرون',
      'nav_share': 'شارك',
      'nav_wallet': 'المحفظة',
      'nav_profile': 'حسابي',
      'title_home': 'الرئيسية',
      'title_board': 'المتصدرون',
      'title_share': 'مشاركة',
      'title_wallet': 'محفظتي',
      'login_tagline': 'معاً نوفّر أكثر',
      'login_welcome': 'مرحباً بك',
      'login_subtitle': 'سجّل دخولك إلى حساب السفير',
      'login_google': 'المتابعة عبر Google',
      'login_new': 'جديد هنا؟',
      'login_need_invite': 'تحتاج إلى رمز دعوة للانضمام إلى برنامج السفراء.',
      'login_have_invite': 'لدي رمز دعوة',
      'login_badge': 'تطبيق السفراء',
      'common_loading': 'جارٍ التحميل...',
      'common_retry': 'إعادة المحاولة',
    },
  };
}

extension TrContext on BuildContext {
  String tr(String key) =>
      AppStrings.of(Localizations.localeOf(this).languageCode, key);
}
