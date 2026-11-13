import 'package:flutter/material.dart';

/// Clé de navigation globale — permet de naviguer depuis n'importe où
/// (ex: depuis un service, une notification push) sans avoir besoin
/// d'un BuildContext local.
class NavigationService {
  NavigationService._();

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
}
