// core/network/api_error_handler.dart
import 'package:dio/dio.dart';

class ApiErrorHandler {
  static String handle(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return "Connection timeout. Please check your internet and try again.";
        case DioExceptionType.badResponse:
          return _handleStatusCode(error.response);
        case DioExceptionType.cancel:
          return "Request to the server was cancelled.";
        case DioExceptionType.connectionError:
          return "No Internet connection. Please check your network.";
        case DioExceptionType.unknown:
        default:
          return "Unexpected network error occurred.";
      }
    } else {
      return "Something went wrong. Please try again."; // أخطاء برمجية أخرى
    }
  }

  static String _handleStatusCode(Response? response) {
    if (response == null) return "Unknown server error.";

    final statusCode = response.statusCode;
    final data = response.data;

    String serverMessage = "Server error occurred.";

    // 🔥 الترقية الذكية: استخراج أخطاء Laravel (Validation Errors)
    if (data != null && data is Map) {
      // 1. إذا كان الخطأ بداخل مصفوفة "errors" (وهذا هو الطبيعي في Laravel 422)
      if (data.containsKey('errors')) {
        final errors = data['errors'] as Map<String, dynamic>;
        if (errors.isNotEmpty) {
          // نأخذ أول خطأ في أول حقل ونعرضه
          serverMessage = errors.values.first[0].toString();
        }
      }
      // 2. إذا كان الخطأ موجوداً في حقل "message" العادي
      else if (data.containsKey('message')) {
        serverMessage = data['message'].toString();
      }
    }

    switch (statusCode) {
      case 400: // Bad Request
        return serverMessage;
      case 401: // Unauthorized
        return serverMessage.isNotEmpty ? serverMessage : "Unauthorized access.";
      case 403: // Forbidden
        return "You do not have permission to access this.";
      case 404: // Not Found
        return "Requested resource was not found.";
      case 422: // 🔥 Validation Error (هنا يقع خطأ الإيميل المستخدم)
        return serverMessage;
      case 500: // Internal Server Error
        return "Internal server error. Please try again later.";
      default:
        return serverMessage;
    }
  }
}