import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/network/api_result.dart';
import '../../data/models/my_plan_model.dart';
import '../../data/repository/my_plans_repository.dart';
import 'my_plans_state.dart';

class MyPlansCubit extends Cubit<MyPlansState> {
  final MyPlansRepository _repository;

  MyPlansCubit(this._repository) : super(const MyPlansState());

  Future<void> fetchTab(PlanTabType type, {bool isRefresh = false}) async {
    if (isClosed) return;

    // 🔥 لو بدك Saved tab يتجدد دايماً لما تفتحه، خلّي هالسطر. إذا بدك يتصرف مثل الباقي، احذفه.
    if (type == PlanTabType.saved) {
      isRefresh = true;
    }

    final previousStatus = state.statusFor(type);

    // ✅ نعرض Loading بس بهالحالات:
    // 1. Pull-to-refresh (isRefresh = true)
    // 2. أول فتح (TabInitial)
    // 3. آخر مرة فشلت (TabFailure) → محاولة جديدة
    final bool shouldShowLoading = isRefresh || previousStatus is TabInitial || previousStatus is TabFailure;

    if (shouldShowLoading) {
      emit(state.copyWithTab(type, const TabLoading()));
    }

    final result = await _repository.fetchPlansForTab(type, isRefresh: isRefresh);
    if (isClosed) return;

    switch (result) {
      case Success<List<PlanModel>>():
        emit(state.copyWithTab(type, TabSuccess(result.data)));
        break;
      case Failure<List<PlanModel>>():
        // ✅ إذا عندنا بيانات قديمة (من الكاش أو تحميل سابق):
        // نرجّعها وما نعرض شاشة الخطأ للمستخدم.
        if (previousStatus is TabSuccess) {
          emit(state.copyWithTab(type, previousStatus));
          return;
        }
        emit(state.copyWithTab(type, TabFailure(result.message ?? 'حدث خطأ غير متوقع')));
        break;
    }
  }
}