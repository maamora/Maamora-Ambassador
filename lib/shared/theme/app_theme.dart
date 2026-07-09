import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorSchemeSeed: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: AppColors.cardBorder),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
    );
  }

  static const TextStyle headlineLg = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w800,
    color: AppColors.onBackground,
    height: 1.2,
  );

  static const TextStyle headlineSm = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w700,
    color: AppColors.onBackground,
  );

  static const TextStyle bodyLg = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.onBackground,
    height: 1.4,
  );

  static const TextStyle bodySm = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: Color(0xFF7A7168),
  );

  static const TextStyle labelMd = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.4,
    color: AppColors.onBackground,
  );

  static const TextStyle bodyMd = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.onBackground,
    height: 1.35,
  );

  static const TextStyle headlineXl = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w800,
    color: AppColors.onBackground,
    height: 1.15,
  );

  // static ThemeData get lightTheme {
  //   return ThemeData(
  //     useMaterial3: true,
  //     brightness: Brightness.light, // force light, ignore system dark mode
  //     colorScheme: ColorScheme.fromSeed(
  //       seedColor: AppColors.primary,
  //       brightness: Brightness.light,
  //     ),
  //     scaffoldBackgroundColor: AppColors.background,
  //     cardTheme: CardThemeData(
  //       elevation: 0,
  //       color: AppColors.surface,
  //       shape: RoundedRectangleBorder(
  //         borderRadius: BorderRadius.circular(14),
  //         side: const BorderSide(color: AppColors.cardBorder),
  //       ),
  //     ),
  //     inputDecorationTheme: InputDecorationTheme(
  //       border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
  //       filled: true,
  //       fillColor: Colors.grey.shade50,
  //     ),
  //   );
  // }
}
