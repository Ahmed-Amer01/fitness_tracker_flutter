import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/theme_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/health_metric_provider.dart';
import 'providers/health_metric_provider.dart'; // <-- new provider
import 'providers/goal_provider.dart';
import 'screens/welcome_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/login_screen.dart';
import 'screens/reset_password_screen.dart';
// import 'screens/dashboard_screen.dart'; // No longer directly routed
// import 'screens/settings_screen.dart'; // No longer directly routed
import 'screens/health_metric_screen.dart';
import 'screens/main_layout_screen.dart'; // <-- new import
import 'screens/community_screen.dart'; // <-- new import
import 'screens/dashboard_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/health_metric_screen.dart'; // <-- new screen
import 'screens/goal_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => HealthMetricProvider()),
        ChangeNotifierProvider(create: (_) => HealthMetricProvider()), // <-- added
        ChangeNotifierProvider(create: (_) => GoalProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, AuthProvider>(
      builder: (context, themeProvider, authProvider, child) {
        return MaterialApp(
          title: 'Fitness Tracker',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          initialRoute: authProvider.isAuthenticated ? '/main_layout' : '/', // <-- updated
          routes: {
            '/': (context) => const WelcomeScreen(),
            '/register': (context) => const SignupScreen(),
            '/login': (context) => const LoginScreen(),
            '/reset-password': (context) => const ResetPasswordScreen(),
            '/main_layout': (context) => const MainLayoutScreen(), // <-- new route
            // '/dashboard': (context) => const DashboardScreen(), // Replaced by MainLayoutScreen
            // '/settings': (context) => const SettingsScreen(), // Replaced by MainLayoutScreen
            '/health-metric': (context) => const HealthMetricScreen(), 
            '/dashboard': (context) => const DashboardScreen(),
            '/settings': (context) => const SettingsScreen(),
            '/health-metric': (context) => const HealthMetricScreen(), // <-- added
            '/goals': (context) => const GoalScreen(),
          },
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
