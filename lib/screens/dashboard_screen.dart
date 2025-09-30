import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/health_metric_provider.dart';
// import '../theme/app_theme.dart'; // No longer directly needed for AppBar/Scaffold
// import '../widgets/loading_overlay.dart'; // No longer needed

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // _isLoading, _updateThemePreference, and _showLogoutDialog are removed

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // This call might need re-evaluation if setAuthScreens(false) is critical
      // It was likely to control theme behavior, now managed by MainLayoutScreen context
      // Provider.of<ThemeProvider>(context, listen: false).setAuthScreens(false);
      Provider.of<HealthMetricProvider>(context, listen: false).fetchMetrics();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Returns the Consumer3 directly, which was the body of the Scaffold
    return Consumer3<AuthProvider, ThemeProvider, HealthMetricProvider>(
      builder: (context, authProvider, themeProvider, healthProvider, child) {
        final user = authProvider.user;
        // final metrics = healthProvider.metrics; // metrics seems unused in the snippet below

        // The Stack and LoadingOverlay are removed.
        // MainLayoutScreen handles loading states for global actions like theme changes.
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Welcome Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Theme.of(context).primaryColor,
                        backgroundImage: user?.profilePicUrl != null
                            ? NetworkImage(user!.profilePicUrl!)
                            : null,
                        child: user?.profilePicUrl == null
                            ? const Icon(
                                Icons.person,
                                size: 30,
                                color: Colors.white,
                              )
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome back,',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            Text(
                              user?.fullName ?? 'User',
                              style: Theme.of(context).textTheme.headlineMedium,  
                            ),
                            Text(
                              'Ready for your workout?',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Stats Cards
              Text(
                'Your Stats',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      context,
                      'Workouts',
                      '12', // Example data
                      Icons.fitness_center,
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      context,
                      'Calories',
                      '2,450', // Example data
                      Icons.local_fire_department,
                      Colors.orange,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      context,
                      'Hours',
                      '24.5', // Example data
                      Icons.access_time,
                      Colors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      context,
                      'Streak',
                      '7 days', // Example data
                      Icons.local_fire_department, // Consider a different icon for streak
                      Colors.red,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Quick Actions
              Text(
                'Quick Actions',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.3,
                children: [
                  _buildActionCard(
                    context,
                    'Start Workout',
                    Icons.play_arrow,
                    Colors.blue,
                    () {
                      // Navigate to workout screen
                    },
                  ),
                  _buildActionCard(
                    context,
                    'Track Food',
                    Icons.restaurant,
                    Colors.green,
                    () {
                      // Navigate to food tracking
                    },
                  ),
                  _buildActionCard(
                    context,
                    'View Progress',
                    Icons.trending_up,
                    Colors.purple,
                    () {
                      // Navigate to progress screen
                    },
                  ),
                  _buildActionCard(
                    context,
                    'Health Metrics',
                    Icons.health_and_safety_rounded,
                    Colors.red,
                    () {
                      Navigator.pushNamed(context, '/health-metric');
                    },
                  ),
                  // The Settings action card might be redundant if settings is a main tab
                  // _buildActionCard(
                  //   context,
                  //   'Settings',
                  //   Icons.settings,
                  //   Colors.grey,
                  //   () {
                  //     // Navigation to settings is handled by BottomNavBar
                  //   },
                  // ),
                ],
              ),
              const SizedBox(height: 24),
              // Theme Info Card (Can be kept if still relevant)
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'App Theme',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Current theme: ${themeProvider.isDark ? "Dark" : "Light"}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        'User preference: ${user?.theme ?? "System"}', // Default to System or Light
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(
      BuildContext context, String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2, // Reduced elevation for a flatter look within the page
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall, // Adjusted style
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
  // _showLogoutDialog method is removed
}
