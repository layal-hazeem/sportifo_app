import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../my_plans(user)/data/models/my_plan_model.dart';
import '../../../my_plans(user)/data/repository/my_plans_repository.dart';
import '../../../my_plans(user)/presentation/view_model/my_plans_cubit.dart';
import 'platform_plans_state.dart';
import '../../data/repository/platform_plans_repository.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/di/service_locator.dart';

class PlatformPlansCubit extends Cubit<PlatformPlansState> {
  final PlatformPlansRepository _repository;

  PlatformPlansCubit(this._repository) : super(PlatformPlansInitial());

  Future<void> fetchPlatformPlans() async {
    emit(PlatformPlansLoading());
    final result = await _repository.getPlatformPlans();
    if (result is Success<List<PlanModel>>) {
      emit(PlatformPlansSuccess(result.data));
    } else if (result is Failure) {
      emit(PlatformPlansError((result as Failure).message));
    }
  }

  Future<String?> toggleSave(int planId) async {
    bool? previousState;
    print('🚀 [PlatformPlansCubit] User clicked save for plan: $planId');

    if (state is PlatformPlansSuccess) {
      final currentState = state as PlatformPlansSuccess;
      final currentPlans = List<PlanModel>.from(currentState.plans);
      final planIndex = currentPlans.indexWhere((p) => p.id == planId);

      if (planIndex != -1) {
        previousState = currentPlans[planIndex].isSaved;
        currentPlans[planIndex].isSaved = !currentPlans[planIndex].isSaved;
        emit(PlatformPlansSuccess(currentPlans));
      }
    }

    final result = await _repository.toggleSavePlan(planId);

    if (result is Success<String>) {
      print('✅ [PlatformPlansCubit] Backend success: ${result.data}');
      try {
        print('🔄 [PlatformPlansCubit] Asking MyPlansCubit to refresh Saved tab...');
        await getIt<MyPlansCubit>().fetchTab(PlanTabType.saved, isRefresh: true);
        print('✅ [PlatformPlansCubit] MyPlansCubit refresh done!');
      } catch (e) {
        print('❌ [PlatformPlansCubit] Error talking to MyPlansCubit: $e');
      }
      return result.data;
    } else if (result is Failure && previousState != null) {
      print('❌ [PlatformPlansCubit] Backend failed: ${(result as Failure).message}');
      if (state is PlatformPlansSuccess) {
        final fallbackPlans = List<PlanModel>.from((state as PlatformPlansSuccess).plans);
        final fallbackIndex = fallbackPlans.indexWhere((p) => p.id == planId);
        if (fallbackIndex != -1) {
          fallbackPlans[fallbackIndex].isSaved = previousState;
          emit(PlatformPlansSuccess(fallbackPlans));
        }
      }
      return null;
    }
    return null;
  }
}