import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import 'dashboard_screen.dart';
import 'community_screen.dart';
import 'settings_screen.dart';
import '../widgets/loading_overlay.dart'; // For _isLoading state
import '../theme/app_theme.dart'; // For BottomNavigationBar theming

class MainLayoutScreen extends StatefulWidget {
  const MainLayoutScreen({Key? key}) : super(key: key);

  @override
  State<MainLayoutScreen> createState() => _MainLayoutScreenState();
}

class _MainLayoutScreenState extends State<MainLayoutScreen> {
  int _selectedIndex = 0;
  bool _isLoading = false; // Moved from DashboardScreen

  static const List<Widget> _widgetOptions = <Widget>[
    DashboardScreen(),
    CommunityScreen(),
    SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Copied and adapted from DashboardScreen
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
        password: null, // Password is not updated here
        theme: newTheme.toUpperCase(),
        notificationsEnabled: user.notificationsEnabled,
        workoutReminderTime: user.workoutReminderTime,
        profilePicPath: null, // Profile pic is not updated here
      );

      if (result.success) {
        themeProvider.setThemeFromProfile(newTheme.toUpperCase());
        if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Theme updated successfully!'),
                backgroundColor: Colors.green,
              ),
            );
        }
      } else {
         if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(result.message ?? 'Failed to update theme'),
                backgroundColor: Colors.red,
              ),
            );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Copied and adapted from DashboardScreen
  void _showLogoutDialog(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop(); // Close dialog first
                await authProvider.logout();
                themeProvider.setAuthScreens(true); // Ensure theme consistency for auth screens
                // Use context from MainLayoutScreen for navigation
                Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context); // listen: true for theme changes

    String appBarTitle = 'Fitness Tracker';
    if (_selectedIndex == 1) {
      appBarTitle = 'Community';
    } else if (_selectedIndex == 2) {
      appBarTitle = 'Settings';
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle),
        actions: [
          IconButton(
            onPressed: () {
              final newTheme = themeProvider.isDark ? 'LIGHT' : 'DARK';
              // themeProvider.toggleTheme(); // Immediate UI update, handled by setThemeFromProfile after backend call
              _updateThemePreference(context, newTheme);
            },
            icon: Icon(
              themeProvider.isDark ? Icons.light_mode : Icons.dark_mode,
            ),
          ),
          IconButton(
            onPressed: () {
              _showLogoutDialog(context);
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Stack(
        children: [
          IndexedStack(
            index: _selectedIndex,
            children: _widgetOptions,
          ),
          if (_isLoading)
            const LoadingOverlay(text: 'Updating Theme...'), // Loading overlay for theme update
        ],
      ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(12.0), // space from edges
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BottomNavigationBar(
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.dashboard),
                    label: 'Dashboard',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.people),
                    label: 'Community',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.settings),
                    label: 'Settings',
                  ),
                ],
                currentIndex: _selectedIndex,
                onTap: _onItemTapped,
              ),
            ),
          ),
        ),
    );

  }
}
