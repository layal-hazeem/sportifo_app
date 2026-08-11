class FoodLog {
  final int id;
  final String body;
  final bool isManual;
  final int calories;
  final int protein;
  final int carbs;
  final int fat;
  final String loggedAt;

  FoodLog({
    required this.id,
    required this.body,
    required this.isManual,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.loggedAt,
  });

  factory FoodLog.fromJson(Map<String, dynamic> json) {
    return FoodLog(
      id: json['id'] as int,
      body: json['body'] as String,
      isManual: json['is_manual'] as bool? ?? false,
      calories: json['calories'] as int? ?? 0,
      protein: json['protein'] as int? ?? 0,
      carbs: json['carbs'] as int? ?? 0,
      fat: json['fat'] as int? ?? 0,
      loggedAt: json['logged_at'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'body': body,
      'is_manual': isManual,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'logged_at': loggedAt,
    };
  }
}

class TotalMacros {
  final int calories;
  final int protein;
  final int carbs;
  final int fat;

  TotalMacros({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  factory TotalMacros.fromJson(Map<String, dynamic> json) {
    return TotalMacros(
      calories: json['calories'] as int? ?? 0,
      protein: json['protein'] as int? ?? 0,
      carbs: json['carbs'] as int? ?? 0,
      fat: json['fat'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
    };
  }
}

class TodayFoodLogsResponse {
  final List<FoodLog> logs;
  final TotalMacros total;

  TodayFoodLogsResponse({
    required this.logs,
    required this.total,
  });

  factory TodayFoodLogsResponse.fromJson(Map<String, dynamic> json) {
    return TodayFoodLogsResponse(
      logs: (json['logs'] as List<dynamic>?)
              ?.map((e) => FoodLog.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      total: TotalMacros.fromJson(json['total'] as Map<String, dynamic>? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'logs': logs.map((e) => e.toJson()).toList(),
      'total': total.toJson(),
    };
  }
}

class AddMealResponse {
  final List<FoodLog> logs;
  final TotalMacros total;

  AddMealResponse({
    required this.logs,
    required this.total,
  });

  factory AddMealResponse.fromJson(Map<String, dynamic> json) {
    return AddMealResponse(
      logs: (json['logs'] as List<dynamic>?)
              ?.map((e) => FoodLog.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      total: TotalMacros.fromJson(json['total'] as Map<String, dynamic>? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'logs': logs.map((e) => e.toJson()).toList(),
      'total': total.toJson(),
    };
  }
}