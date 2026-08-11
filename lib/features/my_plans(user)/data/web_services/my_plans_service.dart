import 'package:dio/dio.dart';
import 'package:sportifo_app/core/network/api_constants.dart';

class MyPlansService {
  final Dio _dio;

  MyPlansService(this._dio);

  Future<Response> getMyPlans({Options? options}) async {
    return await _dio.get(
      ApiConstants.getUserPlans,
      options: options,
    );
  }

  // 🔥 دالة واحدة عامة لجلب أي تاب من التلاتة (نفس شكل الـ response بالضبط
  // لكل واحد فيهن: {data: {data: [...], links, meta}}), فبدل ما نكرر نفس
  // الكود 3 مرات، منمرر الـ endpoint بس كباراميتر.
  Future<Response> getPlansByEndpoint(String endpoint, {Options? options}) async {
    return await _dio.get(
      endpoint,
      options: options,
    );
  }

  // 🔥 الدالة الجديدة لجلب تفاصيل أيام الخطة حسب الـ ID
  // رح تندمج وتصير: plans/20
  Future<Response> getPlanDays(int planId, {Options? options}) async {
    return await _dio.get(
      '${ApiConstants.plans}/$planId',
      options: options, // 👈 كان محشور جوا تعليق وما كان عم يوصل لـ Dio أبداً
    );
  }
  // 🔥 إرسال سجل التمرين (وزن وريبات أو وقت) للسيرفر
  Future<Response> logExerciseActivity(FormData data, {Options? options}) async {
    return await _dio.post(
      ApiConstants.exerciseLogs, // 👈 استدعاء نظيف ومباشر من الثوابت
      data: data,
      options: options,
    );
  }

  // 🔥 جلب سجل الأنشطة الحقيقي (بالتواريخ) - مصدر الحقيقة الدائم بدل الذاكرة المؤقتة
  Future<Response> getExerciseActivity({
    required int planId,
    String? from,
    String? to,
    int? exerciseId,
    Options? options,
  }) async {
    return await _dio.get(
      ApiConstants.exerciseLogsActivity,
      queryParameters: {
        'plan_id': planId,
        if (from != null) 'from': from,
        if (to != null) 'to': to,
        if (exerciseId != null) 'exercise_id': exerciseId,
      },
      options: options,
    );
  }
  // 🔥 1. جلب حالة التقدم
  Future<Response> getPlanProgress(int planId, {Options? options}) async {
    return await _dio.get(
      ApiConstants.planProgress(planId), // 👈 استدعاء نظيف من الثوابت
      options: options,
    );
  }

  // 🔥 2. إرسال طلب إنهاء اليوم
  Future<Response> markDayAsDone({required int planId, required int planDayId, Options? options}) async {
    return await _dio.post(
      ApiConstants.planProgressMarkDone(planId), // 👈 استدعاء نظيف من الثوابت
      data: {
        "plan_day_id": planDayId,
      },
      options: options,
    );
  }
}