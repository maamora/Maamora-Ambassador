import 'package:flutter/material.dart';
import 'shared/theme/app_theme.dart';
import 'shared/navigation/app_router.dart';

void main() {
  runApp(const AmbassadorsApp());
}

class AmbassadorsApp extends StatelessWidget {
  const AmbassadorsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Maamora Ambassadeurs',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: appRouter,
    );
  }
}
