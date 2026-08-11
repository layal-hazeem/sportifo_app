import 'package:sportifo_app/core/network/api_result.dart';
import 'package:sportifo_app/features/trainees/data/models/coach_plan_model.dart';
import '../web_services/trainees_web_service.dart';

class TraineesRepository {
  final TraineesWebService _webService;

  TraineesRepository(this._webService);

  Future<ApiResult<CoachPlansResponseModel>> getCoachTrainees() async {
    try {
      final response = await _webService.getCoachTrainees();

      final data = CoachPlansResponseModel.fromJson(response.data);

      return Success(data);
    } catch (error) {
      return Failure(error.toString());
    }
  }
}