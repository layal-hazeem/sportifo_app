// مسار الملف: lib/features/my_plans(user)/presentation/view_model/my_plans_cubit.dart

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

    // 🔥 التعديل الأول: تاب المحفوظات بالذات لازم دايماً يعمل ريفريش ليجيب أحدث شي!
    if (type == PlanTabType.saved) {
      isRefresh = true;
    }

    final currentStatus = state.statusFor(type);

    if (!isRefresh && currentStatus is TabSuccess) {
      return;
    }

    // 🔥 التعديل الثاني السحري: إجبار الواجهة على رمي "تحميل" لحظي لضمان تحديث الشاشة 100%
    emit(state.copyWithTab(type, TabLoading()));

    final result = await _repository.fetchPlansForTab(type);
    if (isClosed) return;

    switch (result) {
      case Success<List<PlanModel>>():
        emit(state.copyWithTab(type, TabSuccess(result.data)));
        break;
      case Failure<List<PlanModel>>():
        if (currentStatus is TabSuccess) return;
        emit(state.copyWithTab(type, TabFailure(result.message ?? 'حدث خطأ غير متوقع')));
        break;
    }
  }
}