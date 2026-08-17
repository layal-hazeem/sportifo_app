import 'package:sportifo_app/features/workout/data/models/exercise_model.dart';

class CreateSelfPlanResponse {
  final String message;
  final SelfPlanData data;

  CreateSelfPlanResponse({required this.message, required this.data});

  factory CreateSelfPlanResponse.fromJson(Map<String, dynamic> json) {
    return CreateSelfPlanResponse(
      message: json['message'] ?? '',
      data: json['data'] != null
          ? SelfPlanData.fromJson(json['data'])
          : SelfPlanData.empty(),
    );
  }
}

class SelfPlanData {
  final int id;
  final SelfPlanUser? user;
  final dynamic type;
  final String goal;
  final String createdAt;
  final dynamic image;
  final String durationMonths;
  final bool isSelfMade;
  final bool isFree;
  final List<SelfPlanDay> days;

  SelfPlanData({
    required this.id,
    required this.user,
    required this.type,
    required this.goal,
    required this.createdAt,
    required this.image,
    required this.durationMonths,
    required this.isSelfMade,
    required this.isFree,
    required this.days,
  });

  factory SelfPlanData.fromJson(Map<String, dynamic> json) {
    return SelfPlanData(
      id: json['id'] ?? 0,
      user: json['user'] != null ? SelfPlanUser.fromJson(json['user']) : null,
      type: json['type'],
      goal: json['goal'] ?? '',
      createdAt: json['created_at'] ?? '',
      image: json['image'],
      durationMonths: json['duration_months']?.toString() ?? '',
      isSelfMade: json['is_self_made'] ?? false,
      isFree: json['is_free'] ?? false,
      days: json['days'] != null
          ? List<SelfPlanDay>.from(
              json['days'].map((day) => SelfPlanDay.fromJson(day)),
            )
          : [],
    );
  }

  factory SelfPlanData.empty() {
    return SelfPlanData(
      id: 0,
      user: null,
      type: null,
      goal: '',
      createdAt: '',
      image: null,
      durationMonths: '',
      isSelfMade: false,
      isFree: false,
      days: [],
    );
  }
}

class SelfPlanUser {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String dateOfBirth;
  final String role;
  final int gender;
  final double height;
  final double weight;
  final int isActive;
  final bool isVerified;
  final String? profilePic;
  final bool? hasPlan;

  SelfPlanUser({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.dateOfBirth,
    required this.role,
    required this.gender,
    required this.height,
    required this.weight,
    required this.isActive,
    required this.isVerified,
    required this.profilePic,
    required this.hasPlan,
  });

  factory SelfPlanUser.fromJson(Map<String, dynamic> json) {
    return SelfPlanUser(
      id: json['id'] ?? 0,
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      dateOfBirth: json['date_of_birth'] ?? '',
      role: json['role'] ?? '',
      gender: json['gender'] ?? 0,
      height: (json['height'] as num?)?.toDouble() ?? 0,
      weight: (json['weight'] as num?)?.toDouble() ?? 0,
      isActive: json['is_active'] ?? 0,
      isVerified: json['is_verified'] ?? false,
      profilePic: json['profile_pic'],
      hasPlan: json['has_plan'],
    );
  }
}

class SelfPlanDay {
  final int id;
  final String name;
  final List<ExerciseModel> exercises;

  SelfPlanDay({required this.id, required this.name, required this.exercises});

  factory SelfPlanDay.fromJson(Map<String, dynamic> json) {
    return SelfPlanDay(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      exercises: json['exercises'] != null
          ? List<ExerciseModel>.from(
              json['exercises'].map(
                (exercise) => ExerciseModel.fromJson(exercise),
              ),
            )
          : [],
    );
  }
}
