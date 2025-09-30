import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showActions;
  final bool isDashboard;

  const CustomAppBar({
    Key? key,
    required this.title,
    this.showActions = true,
    this.isDashboard = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    final screenWidth = MediaQuery.of(context).size.width;
    final logoSize = screenWidth * 0.08;
    final iconSize = screenWidth * 0.06;

    return AppBar(
      elevation: 0,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      automaticallyImplyLeading: false,
      leading: isDashboard
          ? Padding(
              padding: EdgeInsets.only(left: screenWidth * 0.02),
              child: Image.asset(
                'assets/images/fitnessLogo2.png',
                fit: BoxFit.contain,
                width: logoSize,
                height: logoSize,
                color: Theme.of(context).appBarTheme.iconTheme?.color,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(Icons.image_not_supported,
                              color: Colors.grey.shade600, 
                              size: iconSize * 0.8
                              );
                },
              ),
            )
          : IconButton(
              icon: Icon(Icons.arrow_back, size: iconSize),
              color: Theme.of(context).colorScheme.onBackground,
              onPressed: () => Navigator.pop(context),
            ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isDashboard)
            Padding(
              padding: EdgeInsets.only(right: screenWidth * 0.02),
              child: Image.asset(
                'assets/images/fitnessLogo2.png',
                fit: BoxFit.contain,
                width: logoSize * 0.8,
                height: logoSize * 0.8,
                color: Theme.of(context).appBarTheme.iconTheme?.color,
                errorBuilder: (context, error, stackTrace) {
                  debugPrint('Error loading fitnessLogo2.png: $error\n$stackTrace');
                  return Icon(
                    Icons.image_not_supported,
                    color: Theme.of(context).primaryColor,
                    size: iconSize * 0.6,
                  );
                },
              ),
            ),
          Flexible(
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      centerTitle: true,
      actions: showActions
          ? [
              IconButton(
                icon: Icon(
                  themeProvider.isDark ? Icons.light_mode : Icons.dark_mode,
                  size: iconSize,
                  color: Theme.of(context).colorScheme.onBackground,
                ),
                splashRadius: 20,
                tooltip: 'Toggle Theme',
                onPressed: () {
                  final newTheme = themeProvider.isDark ? 'LIGHT' : 'DARK';
                  themeProvider.toggleTheme();
                  _updateThemePreference(context, newTheme);
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.logout,
                  size: iconSize,
                  color: Theme.of(context).colorScheme.onBackground,
                ),
                splashRadius: 20,
                tooltip: 'Logout',
                onPressed: () => _showLogoutDialog(context, authProvider, themeProvider),
              ),
              SizedBox(width: screenWidth * 0.02),
            ]
          : null,
    );
  }

  Future<void> _updateThemePreference(BuildContext context, String newTheme) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
      final user = authProvider.user;

      if (user == null) throw Exception('User not found');

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
    }
  }

  void _showLogoutDialog(BuildContext context, AuthProvider authProvider, ThemeProvider themeProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text(
            'Logout',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
          ),
          content: Text(
            'Are you sure you want to logout?',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
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
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}