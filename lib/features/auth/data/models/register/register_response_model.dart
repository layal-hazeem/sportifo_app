class RegisterResponseModel {
  final int message;
  final String data;

  RegisterResponseModel({
    required this.message,
    required this.data,
  });

  factory RegisterResponseModel.fromJson(Map<String, dynamic> json) {
    return RegisterResponseModel(
      message: json['message'] ?? 0,
      data: json['data'] ?? '',
    );
  }
}