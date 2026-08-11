import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import '../../../../core/network/api_constants.dart';
import '../../../../core/network/api_error_handler.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/network/dio_factory.dart';

import '../models/activity_set_model.dart';
import '../models/my_plan_model.dart';
import '../models/plan_progress_model.dart';
import '../web_services/my_plans_service.dart';
import 'package:flutter/foundation.dart'; // 👈 ضيفي هاد السطر فوق بالبداية
// 🔥 كل تاب بالشاشة مربوط بـ endpoint مختلف - نفس شكل الـ response بالضبط
// (paginated: data.data[]) لكل واحد فيهن.
enum PlanTabType { coach, custom, saved }

extension PlanTabTypeEndpoint on PlanTabType {
  String get endpoint {
    switch (this) {
      case PlanTabType.coach:
        return ApiConstants.plansSubscribedCoach;
      case PlanTabType.custom:
        return ApiConstants.plansSelf;
      case PlanTabType.saved:
        return ApiConstants.plansPlatformSaved;
    }
  }
}

class MyPlansRepository {
  final MyPlansService _service;

  MyPlansRepository(this._service);

  // 🔥 دالة واحدة عامة تخدم التلاتة تابات - منمرر نوع التاب وهي بتعرف
  // الـ endpoint الصحيح وتحوّل نفس شكل الـ pagination response لكل واحد فيهن.
  Future<ApiResult<List<PlanModel>>> fetchPlansForTab(PlanTabType type) async {
    try {
      final cacheOptions = await DioFactory.getCacheOptions();
      final dioOptions = cacheOptions.copyWith(
        policy: CachePolicy.refreshForceCache,
      ).toOptions();

      final response = await _service.getPlansByEndpoint(type.endpoint, options: dioOptions);

      // 🔥 شكل الـ response الجديد: {"data": {"data": [...], "links": {...}, "meta": {...}}}
      final List data = response.data['data']?['data'] ?? [];
      final List<PlanModel> plans = data.map((json) => PlanModel.fromJson(json)).toList();

      return Success(plans);
    } catch (e) {
      return Failure(ApiErrorHandler.handle(e));
    }
  }

  Future<ApiResult<List<PlanModel>>> fetchMyPlans() async {
    try {
      // 1. جلب إعدادات الكاش
      final cacheOptions = await DioFactory.getCacheOptions();

      // 2. إجبار التطبيق على القراءة من الكاش (التعويذة)
      final dioOptions = cacheOptions.copyWith(
        policy: CachePolicy.refreshForceCache,
      ).toOptions();

      // 3. إرسالها للـ Web Service
      final response = await _service.getMyPlans(options: dioOptions);

      // 4. تحويل الداتا
      final List data = response.data['data'];
      final List<PlanModel> plans = data.map((json) => PlanModel.fromJson(json)).toList();

      return Success(plans);
    } catch (e) {
      return Failure(ApiErrorHandler.handle(e));
    }
  }
  // 🔥 الدالة الجديدة لجلب تفاصيل الخطة (الأيام والتمارين)
  Future<ApiResult<PlanModel>> fetchPlanDays(int planId) async {
    try {
      final cacheOptions = await DioFactory.getCacheOptions();
      final dioOptions = cacheOptions.copyWith(
        policy: CachePolicy.refreshForceCache, // عشان يجيب أحدث التعديلات دايماً
      ).toOptions();

      final response = await _service.getPlanDays(planId, options: dioOptions);

      // تحويل الداتا لموديل الخطة (اللي بيحتوي على الأيام هل المرة)
      final data = response.data['data'];
      final PlanModel plan = PlanModel.fromJson(data);

      return Success(plan);
    } catch (e) {
      return Failure(ApiErrorHandler.handle(e));
    }
  }
// 🔥 دالة الـ Repository لإرسال اللوج ومعالجة الأخطاء
  Future<ApiResult<void>> logExerciseActivity(FormData data) async {
    try {
      final response = await _service.logExerciseActivity(data);
      // إذا رجع 201 Created أو 200 OK
      return  Success(null);
    } catch (e) {
      return Failure(ApiErrorHandler.handle(e));
    }
  }

  // 🔥 جلب سجل الأنشطة الحقيقي بالتواريخ - هاد المصدر الدائم يلي بيحل مشكلة
  // الأوزان يلي كانت بتتصفر، وبيغذّي كمان حساب الأيام/الأسابيع المكتملة.
  Future<ApiResult<List<ActivityDayGroup>>> fetchExerciseActivity({
    required int planId,
    String? from,
    String? to,
    int? exerciseId,
  }) async {
    try {
      final response = await _service.getExerciseActivity(
        planId: planId,
        from: from,
        to: to,
        exerciseId: exerciseId,
      );

      final List data = response.data['data'] ?? [];
      final List<ActivityDayGroup> groups = data.map((json) => ActivityDayGroup.fromJson(json)).toList();

      return Success(groups);
    } catch (e) {
      return Failure(ApiErrorHandler.handle(e));
    }
  }
// 🔥 جلب التقدم وتخطي الكاش إجبارياً
  Future<ApiResult<PlanProgressModel>> fetchPlanProgress(int planId) async {
    try {
      // 1. إعداد خيارات الكاش لإجباره على جلب بيانات جديدة من السيرفر
      final cacheOptions = await DioFactory.getCacheOptions();
      final dioOptions = cacheOptions.copyWith(
        policy: CachePolicy.refreshForceCache, // 👈 السحر هنا: تجاهل الكاش القديم!
      ).toOptions();

      // 2. تمرير الخيارات للسيرفيس
      final response = await _service.getPlanProgress(planId, options: dioOptions);

      final data = response.data['data'];
      return Success(PlanProgressModel.fromJson(data));
    } catch (e) {
      return Failure(ApiErrorHandler.handle(e));
    }
  }
  // إرسال إنهاء اليوم
  Future<ApiResult<void>> markDayAsDone({required int planId, required int planDayId}) async {
    try {
      await _service.markDayAsDone(planId: planId, planDayId: planDayId);
      return Success(null);
    } catch (e) {
      return Failure(ApiErrorHandler.handle(e));
    }
  }
}