class User {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String? profilePicUrl;
  final String theme;
  final String role;
  final bool notificationsEnabled;
  final String? workoutReminderTime;
  final DateTime? createdAt;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.profilePicUrl,
    this.theme = 'light',
    this.role = 'USER',
    this.notificationsEnabled = false,
    this.workoutReminderTime,
    this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      profilePicUrl: json['profilePic'],
      theme: json['theme'] ?? 'light',
      role: json['role'] ?? 'USER',
      notificationsEnabled: json['notificationsEnabled'] ?? false,
      workoutReminderTime: json['workoutReminderTime'],
      createdAt: json['createdAt'] != null 
          ? DateTime.tryParse(json['createdAt']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'profilePicUrl': profilePicUrl,
      'theme': theme,
      'role': role,
      'notificationsEnabled': notificationsEnabled,
      'workoutReminderTime': workoutReminderTime,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  String get fullName => '$firstName $lastName';
}

class AuthResult {
  final bool success;
  final String? message;
  final String? token;
  final User? user;

  AuthResult({
    required this.success,
    this.message,
    this.token,
    this.user,
  });

  factory AuthResult.fromJson(Map<String, dynamic> json) {
    return AuthResult(
      success: json['success'] ?? false,
      message: json['message'],
      token: json['token'],
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }
}