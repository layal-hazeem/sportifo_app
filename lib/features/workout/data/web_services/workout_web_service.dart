import 'package:dio/dio.dart';
import '../../../../core/network/api_constants.dart';

class WorkoutWebService {
  final Dio dio;
  WorkoutWebService(this.dio);

  Future<Response> getCategories(int id) async {
    return await dio.get("${ApiConstants.categories}/$id");  }

  Future<Response> getSubCategories(int organId) async {
    return await dio.get(
      "${ApiConstants.categories}/3",      queryParameters: {

        'category_id': organId,
      },
    );
  }

  Future<Response> getExercises({
    int? categoryId,
    int? organId,
    List<int>? partIds, // القائمة اللي فيها (Middle, Lower)
    String? searchQuery,
  }) async {
    Map<String, dynamic> queryParams = {};

    if (categoryId != null) queryParams['category_id'] = categoryId;
    if (organId != null) queryParams['organ_id'] = organId;

    if (partIds != null && partIds.isNotEmpty) {
      // 🔥 التعديل هنا: إضافة الأقواس المربعة ليفهم السيرفر أنها مصفوفة (Array)
      queryParams['smallest_category_id[]'] = partIds;
    }

    if (searchQuery != null && searchQuery.isNotEmpty) {
      queryParams['search'] = searchQuery;
    }

    return await dio.get(
      ApiConstants.exercise,
      queryParameters: queryParams,
      // 🔥 هذا الخيار مهم جداً لإرسال المصفوفات بشكل صحيح في Dio
      options: Options(
        listFormat: ListFormat.multiCompatible,
      ),
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