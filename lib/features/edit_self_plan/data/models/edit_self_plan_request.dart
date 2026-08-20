class EditSelfPlanRequest {
  final String goal;
  final int durationMonths;
  final List<EditSelfPlanDayRequest> days;

  EditSelfPlanRequest({
    required this.goal,
    required this.durationMonths,
    required this.days,
  });

  Map<String, dynamic> toJson() {
    return {
      'goal': goal,
      'duration_months': durationMonths,
      'days': days.map((day) => day.toJson()).toList(),
    };
  }
}

class EditSelfPlanDayRequest {
  final int? id;
  final String? name;

  /// Default sets/reps for the whole day
  final int? sets;
  final String? reps;

  /// Used when deleting an existing day
  final bool? delete;

  final List<EditSelfPlanExerciseRequest> exercises;

  EditSelfPlanDayRequest({
    this.id,
    this.name,
    this.sets,
    this.reps,
    this.delete,
    this.exercises = const [],
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {};

    if (id != null) {
      json['id'] = id;
    }

    if (name != null) {
      json['name'] = name;
    }

    if (sets != null) {
      json['sets'] = sets;
    }

    if (reps != null) {
      json['reps'] = reps;
    }

    if (delete != null) {
      json['_delete'] = delete;
    }

    if (exercises.isNotEmpty) {
      json['exercises'] = exercises
          .map((exercise) => exercise.toJson())
          .toList();
    }

    return json;
  }
}

class EditSelfPlanExerciseRequest {
  final int exerciseId;
  final int? sets;
  final String? reps;
  final int order;

  /// Used when deleting an existing exercise
  final bool? delete;

  EditSelfPlanExerciseRequest({
    required this.exerciseId,
    this.sets,
    this.reps,
    required this.order,
    this.delete,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'exercise_id': exerciseId,
      'order': order,
    };

    if (sets != null) {
      json['sets'] = sets;
    }

    if (reps != null) {
      json['reps'] = reps;
    }

    if (delete != null) {
      json['_delete'] = delete;
    }

    return json;
  }
}