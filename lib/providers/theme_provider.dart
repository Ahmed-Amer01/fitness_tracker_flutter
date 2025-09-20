import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  bool _isAuthScreens = true; // Auth screens are always light

  ThemeMode get themeMode => _isAuthScreens ? ThemeMode.light : _themeMode;
  bool get isDark => _themeMode == ThemeMode.dark;

  ThemeProvider() {
    _loadTheme();
  }

  // Load theme from SharedPreferences
  void _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('isDark') ?? false;
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  // Set theme based on user profile (called after login)
  void setThemeFromProfile(String theme) async {
    _themeMode = theme.toLowerCase() == 'dark' ? ThemeMode.dark : ThemeMode.light;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDark', _themeMode == ThemeMode.dark);
    notifyListeners();
  }

  // Toggle theme manually (for settings page later)
  void toggleTheme() async {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDark', _themeMode == ThemeMode.dark);
    notifyListeners();
  }

  // Set auth screen mode (always light for welcome/login/signup/reset)
  void setAuthScreens(bool isAuthScreens) {
    _isAuthScreens = isAuthScreens;
    notifyListeners();
  }

  // Reset to light theme (for signup default)
  void resetToLightTheme() async {
    _themeMode = ThemeMode.light;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDark', false);
    notifyListeners();
  }
}