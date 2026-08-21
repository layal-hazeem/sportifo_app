import 'package:dio/dio.dart';
import '../../../../core/network/api_constants.dart';

class WorkoutWebService {
  final Dio dio;

  WorkoutWebService(this.dio);

  // 1️⃣ جلب فئات العضلات
  Future<Response> getCategories(int id, {Options? options}) async {
    return await dio.get(
      "${ApiConstants.categories}/$id",
      options: options,
    );
  }

  // 2️⃣ جلب الأجزاء الدقيقة (الكبسولات)
  Future<Response> getSubCategories(int organId, {Options? options}) async {
    return await dio.get(
      "${ApiConstants.categories}/3",
      queryParameters: {
        'category_id': organId,
      },
      options: options,
    );
  }

  // 3️⃣ جلب التمارين البديلة
  Future<Response> getAlternativeExercises(int exerciseId, {Options? options}) async {
    return await dio.get(
      "${ApiConstants.exerciseAlternatives}/$exerciseId",
      options: options,
    );
  }

  // 4️⃣ جلب التمارين مع معالجة الـ Query Parameters بشكل سليم
  Future<Response> getExercises({
    int? categoryId,
    int? organId,
    List<int>? smallestCategoryId,
    String? searchQuery,
    Options? options,
  }) async {
    return await dio.get(
      ApiConstants.exercise,
      queryParameters: {
        if (categoryId != null) 'category_id': categoryId,
        if (organId != null) 'organ_id': organId,
        if (smallestCategoryId != null && smallestCategoryId.isNotEmpty)
          'smallest_category_id[]': smallestCategoryId,
        if (searchQuery != null && searchQuery.isNotEmpty)
          'search': searchQuery,
      },
      options: options,
    );
  }

  // 5️⃣ حفظ / إلغاء حفظ تمرين
  Future<Response> toggleSaveExercise(int exerciseId) async {
    return await dio.post(
      ApiConstants.saveExercise,
      data: {'exercise_id': exerciseId},
    );
  }

  // 6️⃣ جلب التمارين المحفوظة
  Future<Response> getSavedExercises({Options? options}) async {
    return await dio.get(
      ApiConstants.getSavedExercises,
      options: options,
    );
  }
}