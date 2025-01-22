// lib/models/general/user_model.dart

class UserModel {
  final int id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String? lastLogin;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.lastLogin,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      lastLogin: json['last_login'],
    );
  }
}