import 'package:dio/dio.dart';
import '../../../../core/network/api_constants.dart';

class TargetWebService {
  final Dio dio;
  TargetWebService(this.dio);

  // 1️⃣ دالة إرسال/تعديل الهدف (POST)
  Future<Response> setTarget(String goal) async {
    return await dio.post(
      ApiConstants.targets,
      data: {
        'goal': goal, // بنبعت الـ goal مثل: bulk, cut, maintain
      },
    );
  }

  // 2️⃣ دالة جلب آخر هدف نشط والسعرات الحالية (GET)
  Future<Response> getLatestTarget() async {
    return await dio.get(ApiConstants.targets);
  }
}