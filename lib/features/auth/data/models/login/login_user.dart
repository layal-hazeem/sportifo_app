class LoginUser {
  final int id;
  final String role;

  LoginUser({
    required this.id,
    required this.role,
  });

  factory LoginUser.fromJson(Map<String, dynamic> json) {
    return LoginUser(
      id: json['id'],
      role: json['role'],
    );
  }
}
