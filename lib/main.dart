import 'package:flutter/material.dart';
import 'shared/theme/app_theme.dart';
import 'shared/navigation/app_router.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'firebase_options.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
//   runApp(const AmbassadorsApp());
// }

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
