import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/network/api_result.dart';
import '../../data/models/my_plan_model.dart';
import '../../data/models/plan_progress_model.dart'; // 👈 استيراد موديل التقدم الجديد
import '../../data/repository/my_plans_repository.dart';
import 'plan_days_state.dart';

class PlanDaysCubit extends Cubit<PlanDaysState> {
  final MyPlansRepository _repository;

  PlanDaysCubit(this._repository) : super(PlanDaysInitial());

  Future<void> fetchPlanDays(int planId) async {
    emit(PlanDaysLoading());

    // 1. جلب تفاصيل الخطة والأيام
    final result = await _repository.fetchPlanDays(planId);

    if (isClosed) return;

    switch (result) {
      case Success<PlanModel>():
        emit(await _buildSuccessState(result.data));
        break;

      case Failure<PlanModel>():
        emit(
          PlanDaysFailure(
            result.message ?? 'Failed to load plan days',
          ),
        );
        break;
    }
  }
  /// 🔥 إعادة تحميل حالة التقدم فقط عند العودة من التمرين
  Future<void> refreshProgress() async {
    if (isClosed) return; // 👈 ضيفي هاد السطر لحماية التطبيق من الكراش

    final currentState = state;
    if (currentState is! PlanDaysSuccess) return;
    emit(await _buildSuccessState(currentState.planDetails));
  }

  Future<PlanDaysSuccess> _buildSuccessState(PlanModel plan) async {
    // حساب إجمالي الأسابيع بشكل آمن (كل شهر = 4 أسابيع تقريباً)
    final int totalWeeks = ((plan.durationMonths ?? 1) * 4) > 0 ? ((plan.durationMonths ?? 1) * 4) : 4;

    // جلب داتا التقدم الفعلية من الـ API الجديد الخاص بعمر
    final progressResult = await _repository.fetchPlanProgress(plan.id);

    int currentWeek = 1;
    Set<int> completedPlanDayIds = {};

    if (progressResult is Success<PlanProgressModel>) {
      currentWeek = progressResult.data.currentWeek;

      // فلترة الأيام المكتملة وتخزين الـ ID العادي الخاص بها لتلوينها بالأخضر
      completedPlanDayIds = progressResult.data.days
          .where((day) => day.completed)
          .map((day) => day.id)
          .toSet();
    }

    return PlanDaysSuccess(
      planDetails: plan,
      currentWeek: currentWeek,
      completedPlanDayIds: completedPlanDayIds,
      totalWeeks: totalWeeks,
    );
  }
}