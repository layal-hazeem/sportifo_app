import 'package:dio/dio.dart';
import '../storage/local_storage.dart';
import 'api_constants.dart';

class DioFactory {
  late final Dio _dio;

  // Constructor
  DioFactory() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        receiveDataWhenStatusError: true,
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
        headers: {
          'Accept': 'application/json',
          'Accept-Language': 'ar',
        },
        // 🔥 تم حذف validateStatus من هنا لكي يقوم Dio باصطياد أخطاء الـ 400 والـ 422 ورميها للـ catch!
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await LocalStorage.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          if (e.response?.statusCode == 401) {
            // توجيه المستخدم لصفحة تسجيل الدخول
          }
          return handler.next(e);
        },
      ),
    );

    _dio.interceptors.add(LogInterceptor(
      request: true,
      requestHeader: true,
      requestBody: true,
      responseHeader: true,
      responseBody: true,
      error: true,
    ));
  }

  Dio get dio => _dio;
}