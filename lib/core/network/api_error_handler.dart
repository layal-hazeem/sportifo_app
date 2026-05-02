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
    } else {
      return "Something went wrong. Please try again.";
    }
    return ""; // تجاهل الأخطاء البرمجية غير المتعلقة بالشبكة في الـ UI
  }

  static String _handleStatusCode(Response? response) {
    if (response == null) return "";

    final data = response.data;
    String? serverMessage; // نجعلها نول في البداية

    String? extractedMessage;

    // 🔥 استخراج ذكي وآمن جداً للأخطاء من السيرفر
    if (data != null && data is Map<String, dynamic>) {
      // 1. خط الدفاع الأول: البحث في مصفوفة 'errors' (Laravel Validation)
      if (data.containsKey('errors') && data['errors'] is Map) {
        final errors = data['errors'] as Map<String, dynamic>;
        if (errors.isNotEmpty) {
          final firstErrorList = errors.values.first;
          // التأكد من أنها List وليست فارغة لمنع الـ Crash
          if (firstErrorList is List && firstErrorList.isNotEmpty) {
            extractedMessage = firstErrorList[0].toString();
          }
        }
      }

      // 2. خط الدفاع الثاني: البحث في حقل 'message' العادي
      if (extractedMessage == null || extractedMessage.isEmpty) {
        if (data.containsKey('message') && data['message'] != null) {
          extractedMessage = data['message'].toString();
        }
      }
    }

    // 🏆 إذا نجحنا في استخراج رسالة من السيرفر، نعرضها فوراً ونتجاهل الـ Status Code العادي!
    if (extractedMessage != null && extractedMessage.trim().isNotEmpty) {
      return extractedMessage;
    }

    // 🛡️ خط الدفاع الثالث (الخطة البديلة): السيرفر لم يرسل رسالة صريحة (مثلاً Crash أو صفحة HTML)
    switch (statusCode) {
      case 400:
        return "Bad Request. Please check your inputs.";
      case 401:
        return "Unauthorized access. Please login again.";
      case 403:
        return "You do not have permission to access this.";
      case 404:
        return "Requested resource was not found.";
      case 422:
        return "Validation Error. Please check your inputs.";
      case 429: // 🔥 أضفنا حالة الـ Too Many Requests التي ظهرت لكِ!
        return "Too many attempts. Please try again later.";
      case 500:
        return "Internal server error. Please try again later.";
      default:
        return "Unexpected error occurred (Code: $statusCode).";
    }
  }
}