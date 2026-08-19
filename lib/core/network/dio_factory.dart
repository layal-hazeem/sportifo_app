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
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        receiveDataWhenStatusError: true,
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
        headers: {
          'Accept': 'application/json',
          'Accept-Language': 'en',
        },
      ),
    );
  }

  Future<void> init() async {
    final options = await getCacheOptions();
    _cacheInterceptor = DioCacheInterceptor(options: options);

    _dio.interceptors.clear();

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

    _dio.interceptors.add(
      InterceptorsWrapper(
        onResponse: (response, handler) {
          response.headers.set('cache-control', 'public, max-age=604800');
          return handler.next(response);
        },
      ),
    );

    _dio.interceptors.add(_cacheInterceptor!);

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

  static Future<CacheOptions> getCacheOptions() async {
    if (_cacheOptions == null) {
      final docDir = await getApplicationDocumentsDirectory();
      final cachePath = '${docDir.path}/sportifo_http_cache';

      _cacheOptions = CacheOptions(
        store: HiveCacheStore(cachePath),
        policy: CachePolicy.request,
        hitCacheOnNetworkFailure: true,
        maxStale: const Duration(days: 7),
        priority: CachePriority.high,
        allowPostMethod: false,

        // ✅ التعديل الأساسي: المفتاح هلق بيتضمن هوية اليوزر (التوكن)
        // مش بس اللغة والرابط. هيك كل يوزر إله كاش مستقل تماماً
        // عن أي يوزر تاني، حتى لو نفس الجهاز ونفس الـ endpoint.
        keyBuilder: ({required Uri url, Map<String, String>? headers, Object? body}) {
          final lang = headers?['Accept-Language'] ?? headers?['accept-language'] ?? 'en';
          final auth = headers?['Authorization'] ?? headers?['authorization'] ?? 'guest';
          return '$auth::$lang::${url.toString()}';
        },
      );
    }
    return _cacheOptions!;
  }

  // ✅ دالة جديدة - بتمسح كل الكاش المخزن عالقرص بالكامل
  // لازم تنادى وقت اللوغ أوت (وبفضل كمان وقت اللوغ إن الناجح)
  static Future<void> clearCache() async {
    final options = await getCacheOptions();
    await options.store?.clean();
  }

  Dio get dio => _dio;
}