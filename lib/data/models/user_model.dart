class UserModel {
  final int userId;
  final String username;
  final String email;

  UserModel({
    required this.userId,
    required this.username,
    required this.email,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['userId'] ?? 0,
      username: json['username'] ?? '',
      email: json['email'] ?? '',
    );
  }
}
