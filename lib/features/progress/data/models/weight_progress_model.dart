class WeightProgressResponse {
  final String message;
  final WeightProgressData data;

  WeightProgressResponse({required this.message, required this.data});

  factory WeightProgressResponse.fromJson(Map<String, dynamic> json) {
    return WeightProgressResponse(
      message: json['message'] ?? '',
      data: json['data'] != null
          ? WeightProgressData.fromJson(json['data'])
          : WeightProgressData(user: null, target: null, weightHistory: []),
    );
  }
}

class WeightProgressData {
  final UserWeightInfo? user;
  final WeightTarget? target;
  final List<WeightHistoryEntry> weightHistory;

  WeightProgressData({
    required this.user,
    required this.target,
    required this.weightHistory,
  });

  factory WeightProgressData.fromJson(Map<String, dynamic> json) {
    return WeightProgressData(
      user: json['user'] != null ? UserWeightInfo.fromJson(json['user']) : null,
      target: json['target'] != null
          ? WeightTarget.fromJson(json['target'])
          : null,
      weightHistory: json['weight_history'] != null
          ? List<WeightHistoryEntry>.from(
              json['weight_history'].map((x) => WeightHistoryEntry.fromJson(x)),
            )
          : [],
    );
  }
}

class UserWeightInfo {
  final int id;
  final String firstName;
  final String lastName;
  final double weight;
  final double? height;

  UserWeightInfo({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.weight,
    this.height,
  });

  factory UserWeightInfo.fromJson(Map<String, dynamic> json) {
    return UserWeightInfo(
      id: json['id'] ?? 0,
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      weight: double.tryParse(json['weight']?.toString() ?? '0') ?? 0.0,
      height: json['height'] != null
          ? double.tryParse(json['height'].toString())
          : null,
    );
  }
}

class WeightTarget {
  final int id;
  final String goal;
  final int calories;
  final int protein;
  final int carbs;
  final int fat;

  WeightTarget({
    required this.id,
    required this.goal,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  factory WeightTarget.fromJson(Map<String, dynamic> json) {
    return WeightTarget(
      id: json['id'] ?? 0,
      goal: json['goal'] ?? '',
      calories: json['calories'] ?? 0,
      protein: json['protein'] ?? 0,
      carbs: json['carbs'] ?? 0,
      fat: json['fat'] ?? 0,
    );
  }
}

class WeightHistoryEntry {
  final String date;
  final double weight;

  WeightHistoryEntry({required this.date, required this.weight});

  factory WeightHistoryEntry.fromJson(Map<String, dynamic> json) {
    return WeightHistoryEntry(
      date: json['date'] ?? '',
      weight: double.tryParse(json['weight']?.toString() ?? '0') ?? 0.0,
    );
  }
}
