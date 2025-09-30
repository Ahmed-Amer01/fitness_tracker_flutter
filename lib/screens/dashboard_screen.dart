import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/loading_overlay.dart';
import '../widgets/custom_app_bar.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isLoading = false;
  String? _profileImageUrl;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ThemeProvider>(context, listen: false).setAuthScreens(false);
      _loadProfileImage();
      _preloadIcon(context);
    });
  }


  void _preloadIcon(BuildContext context) {
    precacheImage(const AssetImage('assets/images/fitnessLogo2.png'), context, onError: (exception, stackTrace) {
      debugPrint('Error preloading fitnessLogo2.png: $exception\n$stackTrace');
    });
  }

  void _loadProfileImage() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    if (user != null) {
      setState(() {
        _profileImageUrl = user.profilePicUrl;
      });
    }
  }

  Future<void> _updateThemePreference(BuildContext context, String newTheme) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
      final user = authProvider.user;

      if (user == null) {
        throw Exception('User not found');
      }

      final result = await authProvider.updateProfile(
        firstName: user.firstName,
        lastName: user.lastName,
        email: user.email,
        password: null,
        theme: newTheme.toUpperCase(),
        notificationsEnabled: user.notificationsEnabled,
        workoutReminderTime: user.workoutReminderTime,
        profilePicPath: null,
      );

      if (result.success) {
        themeProvider.setThemeFromProfile(newTheme.toUpperCase());
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Theme updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message ?? 'Failed to update theme'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildProfileImage() {
    final authProvider = Provider.of<AuthProvider>(context);
    Widget imageWidget;

    if (authProvider.profileImageBytes != null) {
      // Image fetched from backend
      imageWidget = Image.memory(
        authProvider.profileImageBytes!,
        fit: BoxFit.cover,
        width: 60,
        height: 60,
      );
    } else if (_profileImageUrl != null && _profileImageUrl!.isNotEmpty) {
      // Fallback to network URL
      imageWidget = Image.network(
        _profileImageUrl!,
        fit: BoxFit.cover,
        width: 60,
        height: 60,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.person, size: 30, color: Colors.grey);
        },
      );
    } else {
      imageWidget = const Icon(Icons.person, size: 30, color: Colors.grey);
    }

    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Theme.of(context).primaryColor,
          width: 2,
        ),
        color: Colors.grey[200],
      ),
      child: ClipOval(child: imageWidget),
    );
  }

  Widget _buildAppBarIcon(BoxConstraints constraints) {
    return Image.asset(
      'assets/images/fitnessLogo2.png',
      fit: BoxFit.contain,
      width: constraints.maxWidth,
      height: constraints.maxHeight,
      color: Theme.of(context).appBarTheme.iconTheme?.color,
      errorBuilder: (context, error, stackTrace) {
        debugPrint('Error loading fitnessLogo2.png: $error\n$stackTrace');
        return Container(
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          color: Colors.grey.shade300,
          child: Center(
            child: Text(
              'Image not found',
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: constraints.maxWidth < 360 ? 16 : 18,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return Consumer2<AuthProvider, ThemeProvider>(
      builder: (context, authProvider, themeProvider, child) {
        final user = authProvider.user;

        return Scaffold(
          appBar: CustomAppBar(
            title: 'Fitness Tracker',
            isDashboard: true,
            showActions: true,
          ),
          
          body: Stack(
            children: [
              SingleChildScrollView(
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
                            _buildProfileImage(),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Welcome back,',
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                  Text(
                                    user?.fullName ?? 'User',

                                    style: Theme.of(context).textTheme.headlineMedium,
                                  ),
                                  Text(
                                    'Ready for your workout?',
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
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
                            '12',
                            Icons.fitness_center,
                            Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 12),
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
                    const SizedBox(height: 12),
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
                        const SizedBox(width: 12),
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
                          'Workouts',
                          Icons.fitness_center,
                          Colors.blue,
                          () {
                            Navigator.pushNamed(context, '/workouts');
                          },
                        ),
                        _buildActionCard(
                          context,
                          'Nutrition',
                          Icons.restaurant,
                          Colors.green,
                          () {
                            Navigator.pushNamed(context, '/nutrition');
                          },
                        ),
                        _buildActionCard(
                          context,
                          'Exercises',
                          Icons.sports_gymnastics,
                          Colors.purple,
                          () {
                            Navigator.pushNamed(context, '/exercises');
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
                        _buildActionCard(
                          context,
                          'Goals',
                          Icons.flag,
                          Colors.teal,
                          () {
                            Navigator.pushNamed(context, '/goals');
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
                    const SizedBox(height: 24),
                    // Theme Info Card
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
                              'User preference: ${user?.theme ?? "Light"}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (_isLoading) const LoadingOverlay(text: 'Updating Theme...'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value,
      IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 8),
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


  Widget _buildActionCard(
      BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
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

  void _showLogoutDialog(BuildContext context, AuthProvider authProvider,
      ThemeProvider themeProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(

          title: Text(
            'Logout',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          content: Text(
            'Are you sure you want to logout?',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },

              child: Text(
                'Cancel',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await authProvider.logout();
                themeProvider.setAuthScreens(true);
                Navigator.pushReplacementNamed(context, '/');
              },

              child: Text(
                'Logout',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.red,
                    ),
              ),
            ),
          ],
        );
      },
    );
  }
}