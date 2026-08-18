import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:http_cache_hive_store/http_cache_hive_store.dart';
import 'package:path_provider/path_provider.dart';
import '../storage/local_storage.dart';
import 'api_constants.dart';

class DioFactory {
  late final Dio _dio;
  final LocalStorage _localStorage;
  static CacheOptions? _cacheOptions;
  DioCacheInterceptor? _cacheInterceptor;

  DioFactory(this._localStorage) {
    // بناء إعدادات الـ Dio الأساسية بدون إضافة أي Interceptors هنا
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        receiveDataWhenStatusError: true,
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
        headers: {'Accept': 'application/json',
          'Accept-Language': 'en', // 👈 الفاصلة هنا كانت ناقصة
          // 'ngrok-skip-browser-warning': 'true',
          // 'User-Agent': 'PostmanRuntime/7.32.3',
        },
      ),
    );
  }

  // 🔥 دالة التهيئة الرئيسية التي يتم استدعاؤها في الـ Service Locator
  Future<void> init() async {
    // 1. جلب وتجهيز إعدادات الكاش
    final options = await getCacheOptions();
    _cacheInterceptor = DioCacheInterceptor(options: options);

    // 2. تنظيف أي إنترسبتورز قديمة لضمان الترتيب الصحيح
    _dio.interceptors.clear();

    // 3. إضافة Interceptor التوكن (يجب أن يكون أولاً لتوثيق أي ريكويست طالع)
    // 🔥 وهون كمان منضيف Accept-Language ديناميكياً بكل ريكويست، مقروءة من
    // اللغة المحفوظة (نفسها يلي LocaleCubit عم يستخدمها للواجهة) - بدل
    // 'en' الثابتة يلي كانت بالـ BaseOptions. هيك محتوى السيرفر (أسماء/أوصاف
    // تمارين مثلاً) بيتبع لغة التطبيق تلقائياً بمجرد ما المستخدم يبدّلها،
    // بدون ما نحتاج نعيد فتح التطبيق.
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = _localStorage.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          options.headers['Accept-Language'] = _localStorage.getLanguage();
          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          if (e.response?.statusCode == 401) {
            await _localStorage.clearToken();
          }
          return handler.next(e);
        },
      ),
    );

    // 3.5 🔥 مهم جداً: الـ backend عندنا عم يرجع دايماً
    // "Cache-Control: no-cache, private" على كل ريسبونس (شكلها إعدادات
    // افتراضية من Laravel/Nginx، مش قرار مقصود). لو تركناها متل ما هي،
    // مكتبة الكاش (dio_cache_interceptor) رح تحترم توجيه السيرفر وترفض
    // تخزن نسخة قابلة للاستخدام أوفلاين — وهاد بالضبط سبب إنو التطبيق
    // بطل يفتح بدون نت. هون بنعدّل الهيدر قبل ما توصل لإنترسبتور الكاش،
    // حتى نتحكم نحنا بالكاش من جهة الكلايند، مش نعتمد عالسيرفر.
    _dio.interceptors.add(
      InterceptorsWrapper(
        onResponse: (response, handler) {
          response.headers.set('cache-control', 'public, max-age=604800'); // أسبوع
          return handler.next(response);
        },
      ),
    );

    // 4. إضافة Interceptor الكاش (يجب أن يكون قبل الطباعة ليصطاد الريكويست المكيش)
    _dio.interceptors.add(_cacheInterceptor!);

    // 5. إضافة Interceptor الطباعة للكونسول (يكون آخر واحد)
    _dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
        error: true,
      ),
    );
  }

  // دالة جلب إعدادات الكاش الذكية والمحدثة
  static Future<CacheOptions> getCacheOptions() async {
    if (_cacheOptions == null) {
      final docDir = await getApplicationDocumentsDirectory();
      final cachePath = '${docDir.path}/sportifo_http_cache';

      _cacheOptions = CacheOptions(
        store: HiveCacheStore(cachePath),
        // 🔥 رجعناها لـ request بدل refresh: request بيرجع الكاش مباشرة لو
        // موجود وسليم (وهاد يلي بيخلي فتح التطبيق أوفلاين سريع وموثوق)،
        // ويتحقق من السيرفر بس لما يلزم. الشاشات يلي بدها بيانات "طازة"
        // مضمونة (متل my_plans) عندها أصلاً override خاص فيها (refreshForceCache).
        policy: CachePolicy.request,
        hitCacheOnNetworkFailure: true,
        maxStale: const Duration(days: 7),
        priority: CachePriority.high,
        allowPostMethod: false,

        keyBuilder: ({required Uri url, Map<String, String>? headers, Object? body}) {
          final lang = headers?['Accept-Language'] ?? headers?['accept-language'] ?? 'en';
          return '$lang::${url.toString()}';
        },
      );
    }
    return _cacheOptions!;
  }

  Dio get dio => _dio;
}