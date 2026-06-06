import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/network/api_result.dart';
import '../../../data/repository/workout_repository.dart';
import 'exercises_state.dart';

class ExercisesCubit extends Cubit<ExercisesState> {
  final WorkoutRepository _repository;

  ExercisesCubit(this._repository) : super(ExercisesInitial());

  // الدالة التي سنستدعيها من الـ UI
  Future<void> fetchExercises({int? categoryId, int? organId, List<int>? partIds}) async {
    emit(ExercisesLoading());

    final result = await _repository.getExercises(
      categoryId: categoryId,
      organId: organId,
      partIds: partIds, // 🔥 التعديل هون: صارت partIds
    );

    // 🛡️ خط الدفاع الأساسي: إذا تم إغلاق الـ Cubit أثناء طلب البيانات، اخرج فوراً ولا تعمل emit
    if (isClosed) return;

    switch (result) {
      case Success():
        emit(ExercisesSuccess(result.data));
        break;
      case Failure():
        emit(ExercisesFailure(result.message));
        break;
    }
  }
}