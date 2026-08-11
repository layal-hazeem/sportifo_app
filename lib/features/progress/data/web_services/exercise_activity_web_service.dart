import 'package:dio/dio.dart';
import '../../../../core/network/api_constants.dart';

class ExerciseActivityWebService {
  final Dio dio;

  ExerciseActivityWebService(this.dio);
  Future<Response> getExerciseActivity({
    int? planId,
    int? exerciseId,
    String? from,
    String? to,
    Options? options,
  }) async {
    return await dio.get(
      ApiConstants.exerciseActivity,
      queryParameters: {
        if (planId != null) 'plan_id': planId,
        if (exerciseId != null) 'exercise_id': exerciseId,
        if (from != null) 'from': from,
        if (to != null) 'to': to,
      },
      options: options,
    );
  }
}
