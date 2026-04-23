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
        // تحديد وقت الانتظار الأقصى للاتصال بالسيرفر (مثلاً 10 ثوانٍ)
        connectTimeout: const Duration(seconds: 10),
        // تحديد وقت الانتظار الأقصى لاستلام الرد من السيرفر
        receiveTimeout: const Duration(seconds: 10),
        // Headers الافتراضية
        headers: {
          'Accept': 'application/json',
          // إذا كان الباك إند يتطلب لغة معينة
          'Accept-Language': 'ar',
        },
          validateStatus: (status) {
            return status != null && status < 500;
          },
      ),
    );

    // إضافة Interceptors (الوسطاء)
    // وظيفتهم مراقبة وتعديل أي طلب يخرج أو رد يدخل
    _dio.interceptors.add(
      InterceptorsWrapper(
        // قبل خروج أي طلب
        onRequest: (options, handler) async {
          final token = await LocalStorage.getToken();

          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          return handler.next(options);
        },
        // عند استلام رد ناجح
        onResponse: (response, handler) {
          return handler.next(response); // أكمل دورة الرد
        },
        // عند حدوث خطأ
        onError: (DioException e, handler) {
          // هنا يمكنك معالجة أخطاء معينة بشكل عام
          // مثلاً: إذا كان الخطأ 401 (غير مصرح)، يمكنك تسجيل خروج المستخدم تلقائياً
          if (e.response?.statusCode == 401) {
            // توجيه المستخدم لصفحة تسجيل الدخول
          }
          return handler.next(e); // مرر الخطأ ليتم التقاطه في الـ Data Source
        },
      ),
    );

    // إضافة LogInterceptor مفيد جداً أثناء التطوير لرؤية الطلبات والردود في الـ Console
    // احرص على إيقافه في نسخة الـ Production (release mode)
    _dio.interceptors.add(LogInterceptor(
      request: true,
      requestHeader: true,
      requestBody: true,
      responseHeader: true,
      responseBody: true,
      error: true,
    ));
  }

  // دالة تُعيد نسخة הـ Dio الجاهزة
  Dio get dio => _dio;
}