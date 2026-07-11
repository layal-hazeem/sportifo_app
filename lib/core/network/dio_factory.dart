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
        headers: {'Accept': 'application/json', 'Accept-Language': 'en'},
      ),
    );

    // 1. Interceptor الخاص بالتوكن والأوتوريزيشن
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = _localStorage.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
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

    // 2. Interceptor الخاص باللوغز للطباعة
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

  // 🔥 دالة التهيئة الرئيسية التي يتم استدعاؤها في الـ Service Locator واشترطنا انتهاءها
  Future<void> init() async {
    final options = await getCacheOptions();
    _cacheInterceptor = DioCacheInterceptor(options: options);
    _dio.interceptors.add(_cacheInterceptor!);
  }

  // دالة جلب إعدادات الكاش الذكية والمحدثة
  static Future<CacheOptions> getCacheOptions() async {
    if (_cacheOptions == null) {
      final docDir = await getApplicationDocumentsDirectory();
      final cachePath = '${docDir.path}/sportifo_http_cache';

      _cacheOptions = CacheOptions(
        store: HiveCacheStore(cachePath),
        policy: CachePolicy.refresh, 
        hitCacheOnNetworkFailure: true,
        maxStale: const Duration(days: 7),
        priority: CachePriority.high,
        allowPostMethod: false,
      );
    }
    return _cacheOptions!;
  }

  Dio get dio => _dio;
}