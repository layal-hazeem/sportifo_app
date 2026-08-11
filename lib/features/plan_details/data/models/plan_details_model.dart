import 'package:sportifo_app/features/workout/data/models/exercise_model.dart';

class PlanDetailsResponseModel {
  final String? message;
  final PlanDetailsModel? data;

  PlanDetailsResponseModel({
    this.message,
    this.data,
  });

  factory PlanDetailsResponseModel.fromJson(Map<String, dynamic> json) {
    return PlanDetailsResponseModel(
      message: json['message'],
      data: json['data'] != null
          ? PlanDetailsModel.fromJson(json['data'])
          : null,
    );
  }
}

class PlanDetailsModel {
  final int id;
  final PlanUserModel? user;
  final PlanCoachModel? coach;
  final String? type;
  final String? goal;
  final DateTime? createdAt;
  final int? durationMonths;
  final bool? isSelfMade;
  final int? isFree;
  final List<PlanDayModel> days;

  PlanDetailsModel({
    required this.id,
    this.user,
    this.coach,
    this.type,
    this.goal,
    this.createdAt,
    this.durationMonths,
    this.isSelfMade,
    this.isFree,
    required this.days,
  });

  factory PlanDetailsModel.fromJson(Map<String, dynamic> json) {
    return PlanDetailsModel(
      id: json['id'] ?? 0,
      user: json['user'] != null
          ? PlanUserModel.fromJson(json['user'])
          : null,
      coach: json['coach'] != null
          ? PlanCoachModel.fromJson(json['coach'])
          : null,
      type: json['type'],
      goal: json['goal'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      durationMonths: json['duration_months'],
      isSelfMade: json['is_self_made'],
      isFree: json['is_free'],
      days: (json['days'] as List?)
              ?.map((e) => PlanDayModel.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class PlanDayModel {
  final int id;
  final String name;
  final List<ExerciseModel> exercises;

  PlanDayModel({
    required this.id,
    required this.name,
    required this.exercises,
  });

  factory PlanDayModel.fromJson(Map<String, dynamic> json) {
    return PlanDayModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      exercises: (json['exercises'] as List?)
              ?.map((e) => ExerciseModel.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class PlanUserModel {
  final int id;
  final String firstName;
  final String lastName;
  final String? email;
  final String? phone;
  final DateTime? dateOfBirth;
  final String? role;
  final bool gender;
  final double height;
  final double weight;
  final int? isActive;
  final bool? isVerified;
  final String? profilePic;

  PlanUserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.email,
    this.phone,
    this.dateOfBirth,
    this.role,
    required this.gender,
    required this.height,
    required this.weight,
    this.isActive,
    this.isVerified,
    this.profilePic,
  });

  factory PlanUserModel.fromJson(Map<String, dynamic> json) {
    return PlanUserModel(
      id: json['id'] ?? 0,
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      email: json['email'],
      phone: json['phone'],
      dateOfBirth: json['date_of_birth'] != null
          ? DateTime.tryParse(json['date_of_birth'])
          : null,
      role: json['role'],
      gender: json['gender'] == 1,
      height: (json['height'] ?? 0).toDouble(),
      weight: (json['weight'] ?? 0).toDouble(),
      isActive: json['is_active'],
      isVerified: json['is_verified'],
      profilePic: json['profile_pic'],
    );
  }
}

class PlanCoachModel {
  final int id;
  final String? fullName;
  final String? description;
  final int? yearsOfExp;
  final DateTime? dateOfBirth;
  final bool? gender;
  final String? profilePic;

  PlanCoachModel({
    required this.id,
    this.fullName,
    this.description,
    this.yearsOfExp,
    this.dateOfBirth,
    this.gender,
    this.profilePic,
  });

  factory PlanCoachModel.fromJson(Map<String, dynamic> json) {
    return PlanCoachModel(
      id: json['id'] ?? 0,
      fullName: json['full_name'],
      description: json['description'],
      yearsOfExp: json['years_of_exp'],
      dateOfBirth: json['date_of_birth'] != null
          ? DateTime.tryParse(json['date_of_birth'])
          : null,
      gender: json['gender'] == 1,
      profilePic: json['profile_pic'],
    );
  }
}