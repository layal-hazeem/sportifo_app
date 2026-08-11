// ---- Cubit (my_plans_cubit.dart) ----
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/api_result.dart';
import '../../data/models/my_plan_model.dart';
import '../../data/repository/my_plans_repository.dart';
import 'my_plans_state.dart';

class MyPlansCubit extends Cubit<MyPlansState> {
  final MyPlansRepository _repository;

  MyPlansCubit(this._repository) : super(const MyPlansState());

  /// 🔥 كل تاب بيتحمّل لحاله وبريكويست مستقل - مش زي قبل (طلب واحد بيرجع
  /// كل شي ومنقسمه محلياً). هيك كمان بنقدر نحمّل كل تاب "بشكل كسول" (lazy) -
  /// بس أول ما المستخدم يفتحه فعلياً، مش الكل مرة وحدة.
  Future<void> fetchTab(PlanTabType type, {bool isRefresh = false}) async {
    final currentStatus = state.statusFor(type);

    // 🛑 عندنا داتا ناجحة أصلاً ومش refresh إجباري؟ ما تعيد الطلب، وفري ريكويست
    if (!isRefresh && currentStatus is TabSuccess) return;

    if (currentStatus is! TabSuccess) {
      emit(state.copyWithTab(type, TabLoading()));
    }

    final result = await _repository.fetchPlansForTab(type);
    if (isClosed) return;

    switch (result) {
      case Success<List<PlanModel>>():
        emit(state.copyWithTab(type, TabSuccess(result.data)));
        break;
      case Failure<List<PlanModel>>():
      // لو عنا داتا ناجحة قبل وفشل الـ refresh، منخلي القديمة (ما نمسحها بغلط)
        if (currentStatus is TabSuccess) return;
        emit(state.copyWithTab(type, TabFailure(result.message ?? 'حدث خطأ غير متوقع')));
        break;
    }
  }
}