import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import 'dart:io' show File; // هيشتغل بس على الموبايل
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http_parser/http_parser.dart';

class AuthService {
  static const String baseUrl = 'http://10.0.2.2:8080'; // Change to your backend URL
  
  // For Android emulator, use: http://10.0.2.2:8080
  // For iOS simulator, use: http://localhost:8080
  // For physical device, use your computer's IP: http://192.168.x.x:8080

  Future<AuthResult> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['token'] != null) {
        return AuthResult(
          success: true,
          token: data['token'],
          message: 'Login successful',
        );
      } else {
        return AuthResult(
          success: false,
          message: data['message'] ?? 'Login failed',
        );
      }
    } catch (e) {
      return AuthResult(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  Future<AuthResult> signup({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    String? profilePicPath,
  }) async {
    try {
      var uri = Uri.parse('$baseUrl/auth/signup');
      var request = http.MultipartRequest('POST', uri);

      // Text fields
      request.fields['firstName'] = firstName;
      request.fields['lastName'] = lastName;
      request.fields['email'] = email;
      request.fields['password'] = password;
      request.fields['role'] = 'USER'; // default role

      // Profile picture (only if selected)
      if (profilePicPath != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'profilePic', 
            profilePicPath,
            contentType: MediaType('image', _getMimeType(profilePicPath)), // set proper MIME
          ),
        );
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      final data = jsonDecode(responseBody);

      if (response.statusCode == 200 && data['token'] != null) {
        return AuthResult(
          success: true,
          token: data['token'],
          message: 'Signup successful',
        );
      } else {
        return AuthResult(
          success: false,
          message: data['message'] ?? 'Signup failed',
        );
      }
    } catch (e) {
      return AuthResult(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  // Helper function to detect MIME from extension
  String _getMimeType(String filePath) {
    final ext = filePath.split('.').last.toLowerCase();
    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return 'jpeg';
      case 'png':
        return 'png';
      case 'gif':
        return 'gif';
      default:
        return 'jpeg'; // fallback
    }
  }

  // Request OTP API
  Future<AuthResult> requestOtp(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/otp-request'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode == 200) {
        return AuthResult(
          success: true,
          message: response.body, // نص عادي
        );
      } else {
        final data = jsonDecode(response.body);
        return AuthResult(
          success: false,
          message: data['message'] ?? 'Failed',
        );
      }
    } catch (e) {
      return AuthResult(success: false, message: 'Network error: ${e.toString()}');
    }
  }

  // Reset Password API
  Future<AuthResult> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'otp': otp,
          'newPassword': newPassword,
        }),
      );

      if (response.statusCode == 200) {
        return AuthResult(
          success: true,
          message: response.body, // نص عادي
        );
      } else {
        final data = jsonDecode(response.body);
        return AuthResult(
          success: false,
          message: data['message'] ?? 'Password reset failed',
        );
      }
    } catch (e) {
      return AuthResult(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  Future<User> getUserProfile(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return User.fromJson(data);
      } else {
        throw Exception('Failed to fetch user profile');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  Future<AuthResult> updateProfile({
    required String token,
    required String firstName,
    required String lastName,
    required String email,
    String? password,
    required String theme,
    required bool notificationsEnabled,
    String? workoutReminderTime,
    String? profilePicPath,
  }) async {
    try {
      var uri = Uri.parse('$baseUrl/profile/update');
      var request = http.MultipartRequest('PATCH', uri);

      // Headers
      request.headers['Authorization'] = 'Bearer $token';

      // Text fields
      request.fields['firstName'] = firstName;
      request.fields['lastName'] = lastName;
      request.fields['email'] = email;
      request.fields['theme'] = theme.toUpperCase();
      request.fields['notificationsEnabled'] = notificationsEnabled.toString();

      if (password != null && password.isNotEmpty) {
        request.fields['password'] = password;
      }

      if (workoutReminderTime != null && workoutReminderTime.isNotEmpty) {
        request.fields['workoutReminderTime'] = workoutReminderTime;
      }

      // Profile picture handling
      if (profilePicPath != null) {
        final ext = profilePicPath.split('.').last.toLowerCase();
        final mimeType = _getMimeType(profilePicPath);
        request.files.add(
          await http.MultipartFile.fromPath(
            'profilePic',
            profilePicPath,
            contentType: MediaType('image', mimeType),
          ),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return AuthResult(
          success: true,
          message: data['message'] ?? 'Profile updated successfully',
        );
      } else {
        final msg = data['message'] ?? 'Profile update failed';
        return AuthResult(success: false, message: msg);
      }
    } catch (e) {
      return AuthResult(success: false, message: 'Network error: $e');
    }
  }

  Future<AuthResult> deleteAccount(String token) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );


      if (response.statusCode == 200) {
        return AuthResult(
          success: true,
          message: 'Account deleted successfully',
        );
      } else {
        return AuthResult(
          success: false,
          message: 'Account deletion failed',
        );
      }
    } catch (e) {
      return AuthResult(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  Future<Uint8List?> fetchProfileImage(String token, String profilePicPath) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$profilePicPath'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return response.bodyBytes; // returns image bytes
      } else {
        print('Failed to fetch profile image: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching profile image: $e');
      return null;
    }
  }
}