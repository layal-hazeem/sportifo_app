import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sportifo_app/features/workout/data/models/exercise_model.dart';
import 'package:sportifo_app/features/workout/data/repository/workout_repository.dart';
import 'package:sportifo_app/features/workout/data/web_services/workout_web_service.dart';
import 'package:sportifo_app/features/workout/presentation/view_model/saved_exercises/saved_exercises_cubit.dart';
import 'package:sportifo_app/core/network/api_result.dart';

class FakeWorkoutWebService extends WorkoutWebService {
  FakeWorkoutWebService() : super(Dio());
}

class FakeWorkoutRepository extends WorkoutRepository {
  FakeWorkoutRepository({required this.savedExercisesToReturn})
      : super(FakeWorkoutWebService());

  final List<ExerciseModel> savedExercisesToReturn;

  @override
  Future<ApiResult<bool>> toggleSaveExercise(int exerciseId) async {
    return Success(true);
  }

  @override
  Future<ApiResult<List<ExerciseModel>>> getSavedExercises() async {
    return Success(savedExercisesToReturn);
  }
}

ExerciseModel buildExercise(int id) {
  return ExerciseModel(
    id: id,
    name: 'Exercise $id',
    description: 'Description $id',
    images: const [],
  );
}

void main() {
  group('SavedExercisesCubit', () {
    test('merges server results with locally saved exercises', () async {
      final repository = FakeWorkoutRepository(
        savedExercisesToReturn: [buildExercise(1)],
      );
      final cubit = SavedExercisesCubit(repository);

      await cubit.toggleSave(buildExercise(1));
      await cubit.toggleSave(buildExercise(2));

      await cubit.fetchSavedExercises();

      expect(cubit.savedList.map((exercise) => exercise.id), [1, 2]);
    });
  });
}
