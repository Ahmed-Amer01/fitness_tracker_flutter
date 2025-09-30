import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user;
  String? _token;
  bool _isLoading = false;
  Uint8List? _profileImageBytes;

  User? get user => _user;
  String? get token => _token;
  bool get isAuthenticated => _token != null;
  bool get isLoading => _isLoading;
  Uint8List? get profileImageBytes => _profileImageBytes;

  AuthProvider() {
    _loadToken();
  }

  // Load token from SharedPreferences on app start
  void _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    if (_token != null) {
      // Optional: Verify token and fetch user profile
      await fetchUserProfile();
    }
    notifyListeners();
  }

  // Login
  Future<AuthResult> login(String email, String password) async {
    _setLoading(true);
    try {
      final result = await _authService.login(email, password);
      if (result.success && result.token != null) {
        _token = result.token;
        await _saveToken(_token!);
        await fetchUserProfile();
      }
      _setLoading(false);
      return result;
    } catch (e) {
      _setLoading(false);
      return AuthResult(success: false, message: e.toString());
    }
  }

  // Signup
  Future<AuthResult> signup({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    String? profilePicPath,
  }) async {
    _setLoading(true);
    try {
      final result = await _authService.signup(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
        profilePicPath: profilePicPath,
      );
      if (result.success && result.token != null) {
        _token = result.token;
        await _saveToken(_token!);
        await fetchUserProfile();
      }
      _setLoading(false);
      return result;
    } catch (e) {
      _setLoading(false);
      return AuthResult(success: false, message: e.toString());
    }
  }

  // Request OTP
  Future<AuthResult> requestOtp(String email) async {
    _setLoading(true);
    try {
      final result = await _authService.requestOtp(email);
      _setLoading(false);
      return result;
    } catch (e) {
      _setLoading(false);
      return AuthResult(success: false, message: e.toString());
    }
  }

  // Reset Password
  Future<AuthResult> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    _setLoading(true);
    try {
      final result = await _authService.resetPassword(
        email: email,
        otp: otp,
        newPassword: newPassword,
      );
      _setLoading(false);
      return result;
    } catch (e) {
      _setLoading(false);
      return AuthResult(success: false, message: e.toString());
    }
  }

  Future<void> fetchProfileImage() async {
    if (_token == null || _user?.profilePicUrl == null) return;

    try {
      final bytes = await _authService.fetchProfileImage(_token!, _user!.profilePicUrl!);
      if (bytes != null) {
        _profileImageBytes = bytes;
        notifyListeners();
      }
    } catch (e) {
      print('Error fetching profile image in provider: $e');
    }
  }

  // Fetch user profile
  Future<void> fetchUserProfile() async {
    if (_token == null) return;
    
    try {
      _user = await _authService.getUserProfile(_token!);
      notifyListeners();

      // Fetch profile image if available
      if (_user?.profilePicUrl != null) {
        await fetchProfileImage();
      }
    } catch (e) {
      print('Error fetching user profile: $e');
    }
  }

  // Logout
  Future<void> logout() async {
    _token = null;
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    notifyListeners();
  }

  // Update Profile
  Future<AuthResult> updateProfile({
    required String firstName,
    required String lastName,
    required String email,
    String? password,
    required String theme,
    required bool notificationsEnabled,
    String? workoutReminderTime,
    String? profilePicPath,
  }) async {
    _setLoading(true);
    try {
      final result = await _authService.updateProfile(
        token: _token!,
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
        theme: theme,
        notificationsEnabled: notificationsEnabled,
        workoutReminderTime: workoutReminderTime,
        profilePicPath: profilePicPath,
      );

      if (result.success && result.token != null) {
        _token = result.token;
        await _saveToken(_token!);
        await fetchUserProfile();
      }
      else if (result.success) {
        // Refresh user profile after successful update
        await fetchUserProfile();
      }
      
      _setLoading(false);
      return result;
    } catch (e) {
      _setLoading(false);
      return AuthResult(success: false, message: e.toString());
    }
  }

  // Delete Account
  Future<AuthResult> deleteAccount() async {
    _setLoading(true);
    try {
      final result = await _authService.deleteAccount(_token!);
      
      if (result.success) {
        // Clear user data after successful deletion
        await logout();
      }
      
      _setLoading(false);
      return result;
    } catch (e) {
      _setLoading(false);
      return AuthResult(success: false, message: e.toString());
    }
  }
  
  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}