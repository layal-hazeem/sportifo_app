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
      return "Something went wrong. Please try again.";
    }
  }

  static String _handleStatusCode(Response? response) {
    if (response == null) return "Unknown server error.";

    final statusCode = response.statusCode;
    final data = response.data;

    String? extractedMessage;

    if (data != null && data is Map<String, dynamic>) {
      if (data.containsKey('errors') && data['errors'] is Map) {
        final errors = data['errors'] as Map<String, dynamic>;
        if (errors.isNotEmpty) {
          final firstErrorList = errors.values.first;
          if (firstErrorList is List && firstErrorList.isNotEmpty) {
            extractedMessage = firstErrorList[0].toString();
          }
        }
      }

      if (data.containsKey('message') && data['message'] != null) {
        final serverMessage = data['message'].toString();

        if (serverMessage.contains("user_targets")) {
          extractedMessage =
              "Your account cannot be deleted because some data is still linked to it.";
        } else if (serverMessage.contains("SQLSTATE") ||
            serverMessage.contains("Integrity constraint violation")) {
          extractedMessage =
              "Unable to complete this action. Please try again later.";
        } else {
          extractedMessage = serverMessage;
        }
      }
    }

    if (extractedMessage != null && extractedMessage.trim().isNotEmpty) {
      return extractedMessage;
    }

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
      case 429:
        return "Too many attempts. Please try again later.";
      case 500:
        return "Internal server error. Please try again later.";
      default:
        return "Unexpected error occurred (Code: $statusCode).";
    }
  }
}
