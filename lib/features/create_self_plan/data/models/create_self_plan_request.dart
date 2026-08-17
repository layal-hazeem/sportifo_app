
import 'package:sportifo_app/features/workout/data/models/exercise_model.dart';

class CreateSelfPlanRequest {
  final String goal;
  final int durationMonths;
  final List<CreateSelfPlanDayRequest> days;

  CreateSelfPlanRequest({
    required this.goal,
    required this.durationMonths,
    required this.days,
  });
}

class CreateSelfPlanDayRequest {
  final String name;
  final int? sets;
  final String? reps;

  final List<ExerciseModel> exercises;

  CreateSelfPlanDayRequest({
    required this.name,
    this.sets,
    this.reps,
    required this.exercises,
  });
}

extension CreateSelfPlanRequestMapper on CreateSelfPlanRequest {
  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = {};

    data['goal'] = goal;
    data['duration_months'] = durationMonths;

    for (int i = 0; i < days.length; i++) {
      final day = days[i];

      data['days[$i][name]'] = day.name;

      if (day.sets != null) {
        data['days[$i][sets]'] = day.sets;
      }

      if (day.reps != null) {
        data['days[$i][reps]'] = day.reps;
      }

      for (int j = 0; j < day.exercises.length; j++) {
        final exercise = day.exercises[j];

        data[
          'days[$i][exercises][$j][exercise_id]'
        ] = exercise.id;

        if (exercise.isResistance) {
          if (exercise.sets != null) {
            data[
              'days[$i][exercises][$j][sets]'
            ] = exercise.sets;
          }

          if (exercise.reps != null) {
            data[
              'days[$i][exercises][$j][reps]'
            ] = exercise.reps;
          }
        }

        if (exercise.isCardio) {
          if (exercise.duration != null) {
            data[
              'days[$i][exercises][$j][duration]'
            ] = exercise.duration;
          }
        }
      }
    }

    return data;
  }
}

