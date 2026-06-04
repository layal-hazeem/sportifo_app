// تأكدي من استيراد ApiResult و ApiErrorHandler
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';

import '../../../../core/network/api_result.dart';
import '../../../../core/network/api_error_handler.dart';

import '../../../../core/network/dio_factory.dart';
import '../models/exercise_model.dart';
import '../models/filter_item_model.dart';
import '../web_services/workout_web_service.dart';

class WorkoutRepository {
  final WorkoutWebService _webService;
  WorkoutRepository(this._webService);


  // 1. دالة جلب العضلات الأساسية (للصور اللي فوق)

  Future<ApiResult<List<FilterItemModel>>> getCategories(int id) async {
    try {
      // 1️⃣ جلب إعدادات كاش الـ Hive المجهزة مسبقاً من الـ DioFactory
      final cacheOptions = await DioFactory.getCacheOptions();

      // 2️⃣ تحويل السياسة وتوليد الـ Options الخاصة بـ دايو
      final dioOptions = cacheOptions.copyWith(
        policy: CachePolicy.refreshForceCache, // جلب محلي فوري، وتحديث تلقائي
      ).toOptions();

      // 3️⃣ تمرير الـ options المعدلة للـ WebService (تأكدي من تعديل الـ WebService ليستقبلها)
      final response = await _webService.getCategories(id, options: dioOptions);

      final responseModel = FilterResponseModel.fromJson(response.data);
      return Success(responseModel.data);
    } catch (e) {
      return Failure(ApiErrorHandler.handle(e));
    }
  }


  // 2. دالة جلب الأجزاء الدقيقة (للكبسولات)
  Future<ApiResult<List<FilterItemModel>>> getSubCategories(int organId) async {
    try {
      final cacheOptions = await DioFactory.getCacheOptions();

      final dioOptions = cacheOptions.copyWith(
        policy: CachePolicy.refreshForceCache,
      ).toOptions();

      final response = await _webService.getSubCategories(organId, options: dioOptions);

      final responseModel = FilterResponseModel.fromJson(response.data);
      return Success(responseModel.data);
    } catch (e) {
      return Failure(ApiErrorHandler.handle(e));
    }
  }

  Future<ApiResult<List<ExerciseModel>>> getExercises({
    int? categoryId,
    int? organId,
    List<int>? partIds,
    String? searchQuery,
  }) async {
    try {
      // 1. جلب إعدادات كاش الـ Hive المجهزة مسبقاً
      final cacheOptions = await DioFactory.getCacheOptions();

      // 2. تحويل السياسة وتوليد الـ Options الخاصة بـ دايو 5.9.2 لتمريرها بأمان
      final dioOptions = cacheOptions.copyWith(
        policy: CachePolicy.refreshForceCache, // جلب محلي فوري، وتحديث عند انتهاء الـ 7 أيام
      ).toOptions();

      // 3. تمرير الـ options المعدلة للـ WebService لتقوم بحقنها في الـ Request
      final response = await _webService.getExercises(
        categoryId: categoryId,
        organId: organId,
        partIds: partIds,
        searchQuery: searchQuery,
        options: dioOptions, // مرري هذا المتغير إلى دالة الـ WebService
      );

      final responseModel = ExerciseResponseModel.fromJson(response.data);
      return Success(responseModel.data);
    } catch (e) {
      return Failure(ApiErrorHandler.handle(e));
    }
  }


  // داخل WorkoutRepository
  Future<ApiResult<bool>> toggleSaveExercise(int exerciseId) async {
    try {
      final response = await _webService.toggleSaveExercise(exerciseId);
      // إذا كان الباك إند يرجع success: true عند النجاح
      return Success(response.data['success'] ?? true);
    } catch (e) {
      return Failure(ApiErrorHandler.handle(e));
    }
  }
  Future<ApiResult<List<ExerciseModel>>> getSavedExercises() async {
    try {
      final response = await _webService.getSavedExercises();

      if (response.data['data'] is List) {
        final List data = response.data['data'];
        final exercises = data.map((e) => ExerciseModel.fromJson(e)).toList();
        return Success(exercises);
      }

      // إذا كانت الاستجابة هي الكائن نفسه (ResponseModel)
      final responseModel = ExerciseResponseModel.fromJson(response.data);
      return Success(responseModel.data);

    } catch (e) {
      print("Error fetching saved: $e");
      return Failure(ApiErrorHandler.handle(e));
    }
  }
}