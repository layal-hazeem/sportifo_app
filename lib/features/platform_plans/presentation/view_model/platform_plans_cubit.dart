import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../my_plans(user)/data/models/my_plan_model.dart';
import '../../../my_plans(user)/data/repository/my_plans_repository.dart';
import '../../../my_plans(user)/presentation/view_model/my_plans_cubit.dart';
import 'platform_plans_state.dart';
import '../../data/repository/platform_plans_repository.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/di/service_locator.dart'; // 👈 استدعاء الـ getIt

class PlatformPlansCubit extends Cubit<PlatformPlansState> {
  final PlatformPlansRepository _repository;

  PlatformPlansCubit(this._repository) : super(PlatformPlansInitial());

  // دالة جلب الخطط (تبقى كما هي)
  Future<void> fetchPlatformPlans() async {
    emit(PlatformPlansLoading());
    final result = await _repository.getPlatformPlans();
    if (result is Success<List<PlanModel>>) {
      emit(PlatformPlansSuccess(result.data));
    } else if (result is Failure) {
      emit(PlatformPlansError((result as Failure).message));
    }
  }

  // 🔥 دالة الحفظ الذكية (المزامنة الشاملة)
  Future<void> toggleSave(int planId) async {
    bool? previousState; // للاحتفاظ بالحالة القديمة في حال فشل السيرفر

    // 1️⃣ تحديث واجهة الهوم فوراً (Optimistic Update)
    if (state is PlatformPlansSuccess) {
      final currentState = state as PlatformPlansSuccess;
      final currentPlans = List<PlanModel>.from(currentState.plans);
      final planIndex = currentPlans.indexWhere((p) => p.id == planId);

      if (planIndex != -1) {
        previousState = currentPlans[planIndex].isSaved;
        currentPlans[planIndex].isSaved = !currentPlans[planIndex].isSaved;
        emit(PlatformPlansSuccess(currentPlans)); // الواجهة بتتحدث فوراً
      }
    }

    // 2️⃣ إرسال الطلب للسيرفر بالخلفية
    final result = await _repository.toggleSavePlan(planId);

    // 3️⃣ التعامل مع النتيجة (نجاح أو فشل)
    if (result is Success) {
      // ✅ السحر هنا: نأمر تاب الـ Saved بتحديث بياناته بصمت بالخلفية لضمان ظهور/اختفاء الخطة
      try {
        // ملاحظة: تأكد إنك عامل import لـ PlanTabType أو مرر القيمة الصحيحة للـ enum عندك
        getIt<MyPlansCubit>().fetchTab(PlanTabType.saved, isRefresh: true);
      } catch (e) {
        // في حال لم يتم فتح صفحة MyPlans مسبقاً والكيوبيت غير مهيأ، نتجاهل الخطأ
      }
    } else if (result is Failure && previousState != null) {
      // ❌ في حال فشل النت، نرجع الزر لونه القديم (Rollback)
      if (state is PlatformPlansSuccess) {
        final fallbackPlans = List<PlanModel>.from((state as PlatformPlansSuccess).plans);
        final fallbackIndex = fallbackPlans.indexWhere((p) => p.id == planId);
        if (fallbackIndex != -1) {
          fallbackPlans[fallbackIndex].isSaved = previousState;
          emit(PlatformPlansSuccess(fallbackPlans));
        }
      }
    }
  }
}