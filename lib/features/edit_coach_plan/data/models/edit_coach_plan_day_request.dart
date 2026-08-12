import 'edit_coach_plan_exercise_request.dart';

class EditCoachPlanDayRequest {
  final int? id;
  final String? name;
  final int? sets;
  final String? reps;
  final bool isDeleted;
  final List<EditCoachPlanExerciseRequest> exercises;

  const EditCoachPlanDayRequest({
    this.id,
    this.name,
    this.sets,
    this.reps,
    this.isDeleted = false,
    this.exercises = const [],
  });

  Map<String, dynamic> toMap() {
    // Deleted existing day
    if (isDeleted) {
      return {if (id != null) 'id': id, '_delete': true};
    }

    final map = <String, dynamic>{
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      '_delete': false,
      'exercises': exercises.map((e) => e.toMap()).toList(),
    };

    if (sets != null) {
      map['sets'] = sets;
    }

    if (reps != null) {
      map['reps'] = reps;
    }

    return map;
  }
}
