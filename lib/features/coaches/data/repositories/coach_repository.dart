import 'package:flutter/foundation.dart'; // 👈 1. استيراد مكتبة الفاونديشن للـ compute
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import '../../../../core/network/api_error_handler.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/network/dio_factory.dart';
import '../models/coach_model.dart';
import '../models/coach_details_model.dart';
import '../web_services/coach_web_service.dart';

// 🔥 2. دالة تحليل الكوتشات بالخلفية (خارج الكلاس)
List<CoachModel> _parseCoachesList(dynamic data) {
  final list = data as List<dynamic>;
  return list.map((json) => CoachModel.fromJson(json)).toList();
}

// 🔥 3. دالة تحليل تفاصيل الكوتش بالخلفية (اختياري بس بيعطي أداء صاروخي)
CoachDetailsModel _parseCoachDetails(dynamic data) {
  final map = data as Map<String, dynamic>;
  return CoachDetailsModel.fromJson(map);
}

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
        policy: CachePolicy.forceCache,
      ).toOptions();

      final response = await _coachWebService.getCoaches(
        options: dioOptions,
        search: search,
        gender: gender,
        minExp: minExp,
        maxExp: maxExp,
      );

      final List<dynamic> dataList = response.data['data'];

      // 🔥 4. التعديل الأهم: إسناد مهمة قراءة الكوتشات لـ مسار خلفي
      final List<CoachModel> coachesList = await compute(_parseCoachesList, dataList);

      return Success(coachesList);
    } catch (e) {
      return Failure(ApiErrorHandler.handle(e));
    }
  }

  Future<ApiResult<CoachDetailsModel>> getCoachDetails(int coachId) async {
    try {
      final cacheOptions = await DioFactory.getCacheOptions();
      final dioOptions = cacheOptions.copyWith(
        policy: CachePolicy.forceCache,
      ).toOptions();

      final response = await _coachWebService.getCoachDetails(
        coachId,
        options: dioOptions,
      );

      final Map<String, dynamic> dataMap = response.data['data'];

      // 🔥 5. فك ضغط تفاصيل الكوتش بمسار خلفي أيضاً
      final coachDetails = await compute(_parseCoachDetails, dataMap);

      return Success(coachDetails);
    } catch (e) {
      return Failure(ApiErrorHandler.handle(e));
    }
  }
}