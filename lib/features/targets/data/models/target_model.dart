class TargetModel {
  final int id;
  final int userId;
  final String goal;
  final int calories;
  final int protein;
  final int carbs;
  final int fat;

  TargetModel({
    required this.id,
    required this.userId,
    required this.goal,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  factory TargetModel.fromJson(Map<String, dynamic> json) {
    return TargetModel(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      goal: json['goal'] ?? '',
      calories: (json['calories'] as num?)?.toInt() ?? 0,
      protein: (json['protein'] as num?)?.toInt() ?? 0,
      carbs: (json['carbs'] as num?)?.toInt() ?? 0,
      fat: (json['fat'] as num?)?.toInt() ?? 0,
    );
  }
}

class TargetResponseModel {
  final String message;
  final TargetModel data;

  TargetResponseModel({required this.message, required this.data});

  factory TargetResponseModel.fromJson(Map<String, dynamic> json) {
    return TargetResponseModel(
      message: json['message'] ?? '',
      data: TargetModel.fromJson(json['data'] ?? {}),
    );
  }
}