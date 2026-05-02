// core/network/api_error_handler.dart
import 'package:dio/dio.dart';

class ApiErrorHandler {
  static String handle(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return "Connection timeout. Please check your internet.";
        case DioExceptionType.badResponse:
          return _handleStatusCode(error.response);
        case DioExceptionType.connectionError:
          return "No Internet connection.";
        default:
        // لا نرجع رسالة هنا، نتركها فارغة أو نرجع null ليتم تجاهلها في الواجهة
          return "";
      }
    }
    return ""; // تجاهل الأخطاء البرمجية غير المتعلقة بالشبكة في الـ UI
  }

  static String _handleStatusCode(Response? response) {
    if (response == null) return "";

    final data = response.data;
    String? serverMessage; // نجعلها نول في البداية

    // استخراج الرسالة الحقيقية فقط
    if (data != null && data is Map) {
      if (data.containsKey('errors')) {
        final errors = data['errors'] as Map<String, dynamic>;
        if (errors.isNotEmpty) {
          serverMessage = errors.values.first[0].toString();
        }
      } else if (data.containsKey('message')) {
        serverMessage = data['message'].toString();
      }
    }

    // القاعدة الذهبية: إذا وجدنا رسالة من السيرفر، نرجعها فوراً مهما كان كود الخطأ
    if (serverMessage != null && serverMessage.isNotEmpty) {
      return serverMessage;
    }

    // إذا لم يرسل السيرفر أي JSON، نضع رسائلنا بناءً على الكود
    switch (response.statusCode) {
      case 401: return "Session expired. Please login again.";
      case 403: return "Access denied.";
      case 404: return "Resource not found.";
      case 500: return "Server is currently down. Try later.";
      default: return ""; // نرجع فارغ لكي لا يظهر SnackBar عشوائي
    }
  }
}