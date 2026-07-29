import 'package:sportifo_app/features/workout/data/models/exercise_model.dart';

class CreatePlanRequest {
  final int userId;
  final List<PlanDayRequest> days;

  CreatePlanRequest({required this.userId, required this.days});
}

class PlanDayRequest {
  final String name;

  final int? sets;
  final String? reps;

  final List<ExerciseModel> exercises;

  PlanDayRequest({
    required this.name,
    this.sets,
    this.reps,
    required this.exercises,
  });
}

extension CreatePlanRequestMapper on CreatePlanRequest {
  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = {};

    data['user_id'] = userId;

    for (int i = 0; i < days.length; i++) {
      data['days[$i][name]'] = days[i].name;

      if (days[i].sets != null) {
        data['days[$i][sets]'] = days[i].sets;
      }

      if (days[i].reps != null) {
        data['days[$i][reps]'] = days[i].reps;
      }

      for (int j = 0; j < days[i].exercises.length; j++) {
        final exercise = days[i].exercises[j];

        data['days[$i][exercises][$j][exercise_id]'] = exercise.id;

        // Resistance
        if (exercise.isResistance) {
          if (exercise.sets != null) {
            data['days[$i][exercises][$j][sets]'] = exercise.sets;
          }

          if (exercise.reps != null) {
            data['days[$i][exercises][$j][reps]'] = exercise.reps;
          }
        }

        // Cardio
        if (exercise.isCardio) {
          if (exercise.duration != null) {
            data['days[$i][exercises][$j][duration]'] = exercise.duration;
          }
        }
      }
    }
    return data;
  }
}
