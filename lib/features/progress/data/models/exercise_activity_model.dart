class ExerciseActivityResponse {
  final String message;
  final List<DayActivity> data;

  ExerciseActivityResponse({required this.message, required this.data});

  factory ExerciseActivityResponse.fromJson(Map<String, dynamic> json) {
    return ExerciseActivityResponse(
      message: json['message'] ?? '',
      data: json['data'] != null
          ? List<DayActivity>.from(
              json['data'].map((x) => DayActivity.fromJson(x)),
            )
          : [],
    );
  }
}

class DayActivity {
  final String date;
  final String dateLabel;
  final int totalExercises;
  final List<ActivityLog> logs;

  DayActivity({
    required this.date,
    required this.dateLabel,
    required this.totalExercises,
    required this.logs,
  });

  factory DayActivity.fromJson(Map<String, dynamic> json) {
    return DayActivity(
      date: json['date'] ?? '',
      dateLabel: json['date_label'] ?? '',
      totalExercises: json['total_exercises'] ?? 0,
      logs: json['logs'] != null
          ? List<ActivityLog>.from(
              json['logs'].map((x) => ActivityLog.fromJson(x)),
            )
          : [],
    );
  }
}

class ActivityLog {
  final int id;
  final int planId;
  final String type;
  final String date;
  final String time;
  final ExerciseSummary exercise;
  final List<SetLog> sets;

  ActivityLog({
    required this.id,
    required this.planId,
    required this.type,
    required this.date,
    required this.time,
    required this.exercise,
    required this.sets,
  });

  factory ActivityLog.fromJson(Map<String, dynamic> json) {
    return ActivityLog(
      id: json['id'] ?? 0,
      planId: json['plan_id'] ?? 0,
      type: json['type'] ?? '',
      date: json['date'] ?? '',
      time: json['time'] ?? '',
      exercise: json['exercise'] != null
          ? ExerciseSummary.fromJson(json['exercise'])
          : ExerciseSummary(id: 0, name: ''),
      sets: json['sets'] != null
          ? List<SetLog>.from(json['sets'].map((x) => SetLog.fromJson(x)))
          : [],
    );
  }
}

class ExerciseSummary {
  final int id;
  final String name;

  ExerciseSummary({required this.id, required this.name});

  factory ExerciseSummary.fromJson(Map<String, dynamic> json) {
    return ExerciseSummary(id: json['id'] ?? 0, name: json['name'] ?? '');
  }
}

class SetLog {
  final int setNumber;
  final int reps;
  final double weight;

  SetLog({required this.setNumber, required this.reps, required this.weight});

  factory SetLog.fromJson(Map<String, dynamic> json) {
    return SetLog(
      setNumber: json['set_number'] ?? 0,
      reps: json['reps'] ?? 0,
      weight: double.tryParse(json['weight']?.toString() ?? '0') ?? 0.0,
    );
  }
}
