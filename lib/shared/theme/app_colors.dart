import 'package:flutter/material.dart';

/// Palette centralisée — ne pas coder de couleurs en dur (Color(0xFF...))
/// directement dans vos écrans, utilisez ces constantes pour rester cohérent.
class AppColors {
  AppColors._();

  static const Color primary = Color(0xFFCB8A2E); // ocre/doré Maamora
  static const Color background = Color(0xFFFAFAFA);
  static const Color cardBorder = Color(0xFFE0E0E0);

  static const Color tierBronze = Color(0xFFCD7F32);
  static const Color tierSilver = Color(0xFFB0B0B8);
  static const Color tierGold = Color(0xFFD4AF37);
  static const Color tierPlatinum = Color(0xFF7DE3E8);

  static const Color success = Color(0xFF2E7D32);
}
