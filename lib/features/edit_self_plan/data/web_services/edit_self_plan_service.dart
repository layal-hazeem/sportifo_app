import 'package:dio/dio.dart';
import 'package:sportifo_app/core/network/api_constants.dart';
import 'package:sportifo_app/features/edit_self_plan/data/models/edit_self_plan_model.dart';

class EditSelfPlanService {
  final Dio dio;

  EditSelfPlanService(this.dio);

  Future<SelfPlanResponseModel> updateSelfPlan({
    required int planId,
    required Map<String, dynamic> body,
  }) async {
    final response = await dio.put(
      '${ApiConstants.editSelfPlan}/$planId',
      data: body,
    );

    return SelfPlanResponseModel.fromJson(
      response.data,
    );
  }
}