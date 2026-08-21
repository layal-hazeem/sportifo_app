import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/network/api_result.dart';
import '../../data/repository/exercise_activity_repository.dart';
import '../../data/models/exercise_activity_model.dart';
import 'exercise_activity_state.dart';

class ExerciseActivityCubit extends Cubit<ExerciseActivityState> {
  final ExerciseActivityRepository _repository;

  // ✅✅✅ هون عدلنا: كاش داخلي لحفظ آخر بيانات ناجحة
  // بيمنع عرض NoInternetView لو في بيانات قديمة مخزنة
  List<DayActivity>? _cachedDays;

  ExerciseActivityCubit(this._repository) : super(ExerciseActivityInitial());

  Future<void> fetchActivity({
    int? planId,
    int? exerciseId,
    String? from,
    String? to,
    bool forceRefresh = false,
  }) async {
    emit(ExerciseActivityLoading());
    final result = await _repository.getExerciseActivity(
      planId: planId,
      exerciseId: exerciseId,
      from: from,
      to: to,
      forceRefresh: forceRefresh,
    );

    if (isClosed) return;

    if (result is Success<List<DayActivity>>) {
      _cachedDays = result.data; // ✅ خزن الكاش
      emit(ExerciseActivitySuccess(result.data));
    } else if (result is Failure) {
      // ✅ إذا في كاش قديم، ارجع البيانات القديمة بدل Error
      if (_cachedDays != null && _cachedDays!.isNotEmpty) {
        emit(ExerciseActivitySuccess(_cachedDays!));
      } else {
        emit(ExerciseActivityError((result as Failure).message));
      }
    }
  }
}