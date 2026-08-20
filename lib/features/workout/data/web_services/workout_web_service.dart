import 'package:dio/dio.dart';
import '../../../../core/network/api_constants.dart';

class WorkoutWebService {
  final Dio dio;
  WorkoutWebService(this.dio);

  Future<Response> getCategories(int id,{Options? options}) async {

    return await dio.get("${ApiConstants.categories}/$id",
      options: options,
    );
  }


  Future<Response> getSubCategories(int organId,{Options? options}) async {
    return await dio.get(

      "${ApiConstants.categories}/3", queryParameters: {
      'category_id': organId,
    },
      options: options,
    );
  }
  Future<Response> getAlternativeExercises(int exerciseId, {Options? options}) async {
    return await dio.get(
      "${ApiConstants.exerciseAlternatives}/$exerciseId",
      options: options,
    );
  }
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
        'category_id': ?categoryId,
        'organ_id': ?organId,
        if (smallestCategoryId != null && smallestCategoryId.isNotEmpty) 'smallest_category_id[]': smallestCategoryId,
        'search': ?searchQuery,
      },
      options: options, 
    );
  }

  Future<Response> toggleSaveExercise(int exerciseId) async {
    return await dio.post(
      ApiConstants.saveExercise, 
      data: {'exercise_id': exerciseId},
    );
  }
  Future<Response> getSavedExercises({Options? options}) async {
    return await dio.get(
      ApiConstants.getSavedExercises,
      options: options, 
    );
  }
}