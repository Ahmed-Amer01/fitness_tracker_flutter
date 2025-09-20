import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../theme/app_theme.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Set non-auth screens mode (theme from user profile)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ThemeProvider>(context, listen: false).setAuthScreens(false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, ThemeProvider>(
      builder: (context, authProvider, themeProvider, child) {
        final user = authProvider.user;
        
        return Scaffold(
          appBar: AppBar(
            title: Text('Fitness Tracker'),
            actions: [
              // Theme Toggle Button
              IconButton(
                onPressed: () {
                  themeProvider.toggleTheme();
                },
                icon: Icon(
                  themeProvider.isDark ? Icons.light_mode : Icons.dark_mode,
                ),
              ),
              // Logout Button
              IconButton(
                onPressed: () {
                  _showLogoutDialog(context, authProvider, themeProvider);
                },
                icon: Icon(Icons.logout),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Card
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      children: [
                        // Profile Picture
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Theme.of(context).primaryColor,
                          backgroundImage: user?.profilePicUrl != null 
                              ? NetworkImage(user!.profilePicUrl!)
                              : null,
                          child: user?.profilePicUrl == null
                              ? Icon(
                                  Icons.person,
                                  size: 30,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                        SizedBox(width: 16),
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

                SizedBox(height: 24),

                // Stats Cards
                Text(
                  'Your Stats',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        context,
                        'Workouts',
                        '12',
                        Icons.fitness_center,
                        Colors.blue,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        context,
                        'Calories',
                        '2,450',
                        Icons.local_fire_department,
                        Colors.orange,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        context,
                        'Hours',
                        '24.5',
                        Icons.access_time,
                        Colors.green,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        context,
                        'Streak',
                        '7 days',
                        Icons.local_fire_department,
                        Colors.red,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 24),

                // Quick Actions
                Text(
                  'Quick Actions',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                SizedBox(height: 16),

                GridView.count(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
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
                      'Settings',
                      Icons.settings,
                      Colors.grey,
                      () {
                        Navigator.pushNamed(context, '/settings');
                      },
                    ),
                  ],
                ),

                SizedBox(height: 24),

                // Theme Info Card
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'App Theme',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Current theme: ${themeProvider.isDark ? "Dark" : "Light"}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        Text(
                          'User preference: ${user?.theme ?? "light"}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
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
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 32),
              SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
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

  void _showLogoutDialog(BuildContext context, AuthProvider authProvider, ThemeProvider themeProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Logout'),
          content: Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await authProvider.logout();
                themeProvider.setAuthScreens(true);
                Navigator.pushReplacementNamed(context, '/');
              },
              child: Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}