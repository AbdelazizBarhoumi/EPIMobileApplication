import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'core/firebase/firebase_service.dart';
import 'core/services/onesignal_service.dart';
import 'core/storage.dart';
import 'core/providers/api_provider.dart';
import 'routes/app_routes.dart';
import 'shared/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables first
  await dotenv.load(fileName: ".env");

  // Initialize Firebase
  await FirebaseService.instance.initialize();
  
  // Initialize OneSignal
  final oneSignalService = OneSignalService();
  await oneSignalService.initialize();
  
  // Try to ensure user is authenticated before app starts
  // This will show instructions in console if anonymous auth is not enabled
  try {
    await FirebaseService.instance.ensureAuthenticated();
  } catch (e) {
    // Continue anyway - app will work, but Firestore won't until auth is configured
    debugPrint('⚠️ Continuing without authentication - some features may not work');
  }

  final token = await Storage.readToken();
  runApp(MyApp(initialRoute: token != null ? AppRoutes.home : AppRoutes.login));
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: ApiProvider.providers,
      child: MaterialApp(
        title: 'EPI Student App',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        initialRoute: initialRoute,
        routes: AppRoutes.routes,
        onGenerateRoute: AppRoutes.onGenerateRoute,
      ),
    );
  }
}
