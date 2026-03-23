import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/constants/app_theme.dart';
import 'features/auth/presentation/screens/splash_screen.dart';
import 'features/learning/presentation/learning_progress_store.dart';
import 'shared/models/portal_store.dart';
import 'shared/models/user_session_store.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await LearningProgressStore.instance.ensureInitialized();
  await PortalStore.instance.ensureInitialized();
  await UserSessionStore.instance.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const BioxploraApp());
}

class BioxploraApp extends StatelessWidget {
  const BioxploraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BioXplora',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}
