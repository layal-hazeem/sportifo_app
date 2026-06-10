import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import '../../../../core/network/api_error_handler.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/network/dio_factory.dart';
import '../models/coach_model.dart';
import '../models/coach_details_model.dart';
import '../web_services/coach_web_service.dart';

class CoachRepository {
  final CoachWebService _coachWebService;

  CoachRepository(this._coachWebService);

  Future<ApiResult<List<CoachModel>>> getCoaches({
    String? search,
    int? gender,
    int? minExp,
    int? maxExp,
  }) async {
    try {
      final cacheOptions = await DioFactory.getCacheOptions();
      final dioOptions = cacheOptions.copyWith(
        policy: CachePolicy.refreshForceCache,
      ).toOptions();

      final response = await _coachWebService.getCoaches(
        options: dioOptions,
        search: search,
        gender: gender,
        minExp: minExp,
        maxExp: maxExp,
      );

      final List<dynamic> dataList = response.data['data'];

      final List<CoachModel> coachesList = dataList
          .map((json) => CoachModel.fromJson(json))
          .toList();

      return Success(coachesList);
    } catch (e) {
      return Failure(ApiErrorHandler.handle(e));
    }
  }

  Future<ApiResult<CoachDetailsModel>> getCoachDetails(int coachId) async {
    try {
      final cacheOptions = await DioFactory.getCacheOptions();
      final dioOptions = cacheOptions.copyWith(
        policy: CachePolicy.refreshForceCache,
      ).toOptions();

      final response = await _coachWebService.getCoachDetails(
        coachId,
        options: dioOptions,
      );

      final Map<String, dynamic> dataMap = response.data['data'];

      final coachDetails = CoachDetailsModel.fromJson(dataMap);

      return Success(coachDetails);
    } catch (e) {
      return Failure(ApiErrorHandler.handle(e));
    }
  }
}