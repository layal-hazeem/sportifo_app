import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:sportifo_app/core/network/api_constants.dart';

class PlanDetailsWebService {
  final Dio _dio;

  PlanDetailsWebService(this._dio);

  Future<Response> getPlanDetails(int planId) async {
    return await _dio.get(
      '${ApiConstants.planDetails}/$planId',
      // بيتخطى الكاش المحلي ويعمل طلب شبكة حقيقي دايماً — ضروري هون
      // لأنو هاد الإندبوينت ممكن ينجلب مباشرة بعد PUT ناجح، وبدنا
      // نضمن آخر نسخة أكيد، مش النسخة المخزّنة اللي كانت قبل التعديل.
      options: Options(
        extra: CacheOptions(policy: CachePolicy.refresh, store: null).toExtra(),
      ),
    );
  }
}