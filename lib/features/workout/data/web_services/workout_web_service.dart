import 'package:dio/dio.dart';
 import '../../../../core/network/api_constants.dart'; // تأكدي من مسارك

class WorkoutWebService {
  final Dio dio;
  WorkoutWebService(this.dio);
  Future<Response> getSubCategories(int parentId) async {
    return await dio.get("/api/app/categories/$parentId");
  }
  // مررنا الفلاتر كـ optional parameters
  Future<Response> getExercises({int? categoryId, int? organId, int? partId}) async {

    // بناء الـ Query Parameters بذكاء (إهمال القيم الفارغة)
    Map<String, dynamic> queryParams = {};
    if (categoryId != null) queryParams['category_id'] = categoryId;
    if (organId != null) queryParams['organ_id'] = organId;
    if (partId != null) queryParams['part_id'] = partId;

    return await dio.get(
    ApiConstants.exercise,
      queryParameters: queryParams,
    );
  }
}