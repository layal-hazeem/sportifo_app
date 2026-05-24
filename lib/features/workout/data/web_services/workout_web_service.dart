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
    List<int>? partIds,
    String? searchQuery,
    Options? options, // 🔥 السحر هنا: أضفنا المعامل الاختياري لاستقبال خيارات الكاش
  }) async {
    return await dio.get(
      'exercise', // المسار الخاص بكِ من الـ ApiConstants
      queryParameters: {
        if (categoryId != null) 'category_id': categoryId,
        if (organId != null) 'organ_id': organId,
        if (partIds != null) 'part_ids': partIds,
        if (searchQuery != null) 'search': searchQuery,
      },
      options: options, // 🔥 هنا يتم دمج خيارات التخزين الذكي مع الريكويست الحالي
    );
  }

  // داخل WorkoutWebService
  Future<Response> toggleSaveExercise(int exerciseId) async {
    return await dio.post(
      ApiConstants.saveExercise, // "savedExercise"
      data: {'exercise_id': exerciseId},
    );
  }
  // دالة لجلب التمارين التي حفظها المستخدم فقط
  Future<Response> getSavedExercises() async {
    return await dio.get(ApiConstants.getSavedExercises); // اللي هو "savedExercises"
  }
}