class EditCoachPlanExerciseRequest {
  final int exerciseId;
  final int? sets;
  final String? reps;
  final int? order;
  final bool isDeleted;

  const EditCoachPlanExerciseRequest({
    required this.exerciseId,
    this.sets,
    this.reps,
    this.order,
    this.isDeleted = false,
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{'exercise_id': exerciseId};

    if (sets != null) {
      map['sets'] = sets;
    }

    if (reps != null) {
      map['reps'] = reps;
    }

    if (order != null) {
      map['order'] = order;
    }

    if (isDeleted) {
      map['_delete'] = true;
    }

    return map;
  }
}
