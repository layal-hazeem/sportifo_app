class RegisterResponseModel {
  final String message; // 🔥 غيرناه إلى String لكي يستقبل الأرقام والنصوص بأمان
  final String data;

  RegisterResponseModel({
    required this.message,
    required this.data,
  });

  factory RegisterResponseModel.fromJson(Map<String, dynamic> json) {
    return RegisterResponseModel(
      // استخدام toString يحمي التطبيق من أي Crash بسبب اختلاف نوع البيانات
      message: json['message']?.toString() ?? '',
      data: json['data']?.toString() ?? '',
    );
  }
}