class AuthResponse {
  final String? token;
  final String? message;

  AuthResponse({this.token, this.message});

  factory AuthResponse.fromJson(Map<String, dynamic> json) => AuthResponse(
    token: json['token'],
    message: json['message'],
  );
}