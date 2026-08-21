import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/constants/api_constants.dart';
import 'shared/theme/app_theme.dart';
import 'shared/navigation/app_router.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/services/deep_link_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: ApiConstants.supabaseUrl,
    publishableKey: ApiConstants.supabaseAnonKey,
  );

  await DeepLinkService().initDeepLinks();

  runApp(const ProviderScope(child: AmbassadorsApp()));
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
