import 'package:dio/dio.dart';
import '../../../../core/network/api_constants.dart';

class WorkoutWebService {
  final Dio dio;
  WorkoutWebService(this.dio);

  // =========================================
  // 1. جلب العضلات الأساسية (صدر، ظهر..)
  // بينادي categories/2
  // =========================================
  Future<Response> getCategories(int id) async {
    return await dio.get("categories/$id");
  }

  // =========================================
  // 2. جلب الفلاتر الصغيرة (صدر علوي، سفلي..)
  // بينادي categories/3
  // =========================================
  Future<Response> getSubCategories(int organId) async {
    return await dio.get(
      "categories/3",
      queryParameters: {
        // 🔥 هون السر: الباك إند مسمي البرامتر هون category_id
        // مع إنو نحن بنقصد فيه العضلة الأب (organId)
        'category_id': organId,
      },
    );
  }

  // =========================================
  // 3. جلب التمارين
  // =========================================
  Future<Response> getExercises({int? categoryId, int? organId, List<int>? partIds}) async {
    Map<String, dynamic> queryParams = {};

    if (categoryId != null) queryParams['category_id'] = categoryId;
    if (organId != null) queryParams['organ_id'] = organId;

    // 🔥 هون السحر: مكتبة Dio ذكية جداً، بس تبعتيلها List رح تفهمها وتبعثها للباك إند كمصفوفة
    if (partIds != null && partIds.isNotEmpty) {
      queryParams['smallest_category_id'] = partIds;
    }

    return await dio.get(
      ApiConstants.exercise,
      queryParameters: queryParams,
    );
  }

  // داخل WorkoutWebService
  Future<Response> toggleSaveExercise(int exerciseId) async {
    return await dio.post(
      ApiConstants.saveExercise, // "savedExercise"
      data: {'exercise_id': exerciseId},
    );
  }
}