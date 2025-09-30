import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/theme_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/workout_provider.dart';
import 'providers/exercise_provider.dart';
import 'providers/nutrition_provider.dart';
import 'providers/health_metric_provider.dart'; // <-- new provider
import 'providers/goal_provider.dart';
import 'screens/welcome_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/login_screen.dart';
import 'screens/reset_password_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/health_metric_screen.dart';
import 'screens/workouts_screen.dart';
import 'screens/exercises_screen.dart';
import 'screens/nutrition_screen.dart';
import 'screens/goal_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => WorkoutProvider()),
        ChangeNotifierProvider(create: (_) => ExerciseProvider()),
        ChangeNotifierProvider(create: (_) => NutritionProvider()),
        ChangeNotifierProvider(create: (_) => HealthMetricProvider()), // <-- added
        ChangeNotifierProvider(create: (_) => GoalProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, AuthProvider>(
      builder: (context, themeProvider, authProvider, child) {
        return MaterialApp(
          title: 'Fitness Tracker',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          initialRoute: authProvider.isAuthenticated ? '/dashboard' : '/',
          routes: {
            '/': (context) => const WelcomeScreen(),
            '/register': (context) => const SignupScreen(),
            '/login': (context) => const LoginScreen(),
            '/reset-password': (context) => const ResetPasswordScreen(),
            '/dashboard': (context) => const DashboardScreen(),
            '/settings': (context) => const SettingsScreen(),
            '/health-metric': (context) => const HealthMetricScreen(),
            '/workouts': (context) => const WorkoutsScreen(),
            '/exercises': (context) => const ExercisesScreen(),
            '/nutrition': (context) => const NutritionScreen(),
            '/goals': (context) => const GoalScreen(),
          },
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
