import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'services/auth_service.dart';
import 'screens/checkout_screen.dart';
import 'screens/visitor_status_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('Firebase initialized successfully');
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final darkColorScheme = ColorScheme.dark(
      primary: Colors.grey[300]!,
      onPrimary: Colors.black,
      secondary: Colors.grey[600]!,
      onSecondary: Colors.white,
      surface: Colors.grey[900]!,
      onSurface: Colors.grey[100]!,
      brightness: Brightness.dark,
    );

    return ChangeNotifierProvider(
      create: (_) => AuthService(),
      child: MaterialApp(
        title: 'Visitor Management',
        themeMode: ThemeMode.dark,
        theme: ThemeData(
          colorScheme: darkColorScheme,
          useMaterial3: true,
          cardTheme: CardThemeData(
            color: Colors.grey[850]!,
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[800]!,
              foregroundColor: Colors.white,
              elevation: 4,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.grey[850]!,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[600]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[600]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!, width: 2),
            ),
            labelStyle: TextStyle(color: Colors.grey[300]!),
            hintStyle: TextStyle(color: Colors.grey[500]!),
          ),
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.black,
            foregroundColor: Colors.grey[100]!,
            elevation: 0,
            centerTitle: true,
            titleTextStyle: TextStyle(
              color: Colors.grey[100]!,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          scaffoldBackgroundColor: Colors.black,
        ),
        darkTheme: ThemeData(
          colorScheme: darkColorScheme,
          useMaterial3: true,
          cardTheme: CardThemeData(
            color: Colors.grey[850]!,
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[800]!,
              foregroundColor: Colors.white,
              elevation: 4,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.grey[850]!,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[600]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[600]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!, width: 2),
            ),
            labelStyle: TextStyle(color: Colors.grey[300]!),
            hintStyle: TextStyle(color: Colors.grey[500]!),
          ),
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.black,
            foregroundColor: Colors.grey[100]!,
            elevation: 0,
            centerTitle: true,
            titleTextStyle: TextStyle(
              color: Colors.grey[100]!,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          scaffoldBackgroundColor: Colors.black,
        ),
        home: const SplashScreen(),
        onGenerateRoute: (settings) {
          if (settings.name == '/checkout') {
            return MaterialPageRoute(
              builder: (context) {
                return CheckoutRouteWrapper(settings.arguments);
              },
            );
          }
          if (settings.name == '/visitor-status') {
            final args = settings.arguments as Map<String, dynamic>?;
            final visitorId = args?['visitorId'] as String?;
            if (visitorId != null) {
              return MaterialPageRoute(
                builder: (context) => VisitorStatusScreen(visitorId: visitorId),
              );
            }
          }
          if (settings.name == '/login') {
            return MaterialPageRoute(
              builder: (context) => const LoginScreen(),
            );
          }
          return null;
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class CheckoutRouteWrapper extends StatelessWidget {
  final Object? args;
  const CheckoutRouteWrapper(this.args, {super.key});

  @override
  Widget build(BuildContext context) {
    return CheckoutScreen();
  }
}
