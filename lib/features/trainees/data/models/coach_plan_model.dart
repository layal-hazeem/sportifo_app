import 'dart:convert';

CoachPlansResponseModel coachPlansResponseModelFromJson(String str) =>
    CoachPlansResponseModel.fromJson(json.decode(str));

String coachPlansResponseModelToJson(CoachPlansResponseModel data) =>
    json.encode(data.toJson());

class CoachPlansResponseModel {
  final String? message;
  final List<CoachPlanModel> data;

  CoachPlansResponseModel({
    this.message,
    required this.data,
  });

  factory CoachPlansResponseModel.fromJson(Map<String, dynamic> json) {
    return CoachPlansResponseModel(
      message: json["message"],
      data: (json["data"] as List?)
              ?.map((e) => CoachPlanModel.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        "message": message,
        "data": data.map((e) => e.toJson()).toList(),
      };
}

class CoachPlanModel {
  final int? id;
  final TraineeUserModel? user;
  final CoachModel? coach;
  final String? goal;
  final DateTime? createdAt;
  final int? durationMonths;
  final int? daysCount;
  final bool? isSelfMade;

  CoachPlanModel({
    this.id,
    this.user,
    this.coach,
    this.goal,
    this.createdAt,
    this.durationMonths,
    this.daysCount,
    this.isSelfMade,
  });

  factory CoachPlanModel.fromJson(Map<String, dynamic> json) {
    return CoachPlanModel(
      id: json["id"],
      user: json["user"] == null
          ? null
          : TraineeUserModel.fromJson(json["user"]),
      coach: json["coach"] == null
          ? null
          : CoachModel.fromJson(json["coach"]),
      goal: json["goal"],
      createdAt: json["created_at"] != null
          ? DateTime.tryParse(json["created_at"])
          : null,
      durationMonths: json["duration_months"],
      daysCount: json["days_count"],
      isSelfMade: json["is_self_made"],
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "user": user?.toJson(),
        "coach": coach?.toJson(),
        "goal": goal,
        "created_at": createdAt?.toIso8601String(),
        "duration_months": durationMonths,
        "days_count": daysCount,
        "is_self_made": isSelfMade,
      };
}

class TraineeUserModel {
  final int? id;
  final String firstName;
  final String lastName;
  final String? email;
  final String? phone;
  final DateTime? dateOfBirth;
  final bool gender;
  final String? role;
  final double height;
  final double weight;
  final int? isActive;
  final bool? isVerified;
  final String? profilePic;
  final dynamic hasPlan;

  TraineeUserModel({
    this.id,
    required this.firstName,
    required this.lastName,
    this.email,
    this.phone,
    this.dateOfBirth,
    required this.gender,
    this.role,
    required this.height,
    required this.weight,
    this.isActive,
    this.isVerified,
    this.profilePic,
    this.hasPlan,
  });

  factory TraineeUserModel.fromJson(Map<String, dynamic> json) {
    return TraineeUserModel(
      id: json["id"],
      firstName: json["first_name"] ?? "",
      lastName: json["last_name"] ?? "",
      email: json["email"],
      phone: json["phone"],
      dateOfBirth: json["date_of_birth"] != null
          ? DateTime.tryParse(json["date_of_birth"])
          : null,
      gender: json["gender"] == 1,
      role: json["role"],
      height: (json["height"] ?? 0).toDouble(),
      weight: (json["weight"] ?? 0).toDouble(),
      isActive: json["is_active"],
      isVerified: json["is_verified"],
      profilePic: json["profile_pic"],
      hasPlan: json["has_plan"],
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "first_name": firstName,
        "last_name": lastName,
        "email": email,
        "phone": phone,
        "date_of_birth": dateOfBirth?.toIso8601String(),
        "gender": gender ? 1 : 0,
        "role": role,
        "height": height,
        "weight": weight,
        "is_active": isActive,
        "is_verified": isVerified,
        "profile_pic": profilePic,
        "has_plan": hasPlan,
      };
}

class CoachModel {
  final int? id;
  final String? fullName;
  final String? description;
  final int? yearsOfExp;
  final DateTime? dateOfBirth;
  final bool? gender;
  final String? profilePic;

  CoachModel({
    this.id,
    this.fullName,
    this.description,
    this.yearsOfExp,
    this.dateOfBirth,
    this.gender,
    this.profilePic,
  });

  factory CoachModel.fromJson(Map<String, dynamic> json) {
    return CoachModel(
      id: json["id"],
      fullName: json["full_name"],
      description: json["description"],
      yearsOfExp: json["years_of_exp"],
      dateOfBirth: json["date_of_birth"] != null
          ? DateTime.tryParse(json["date_of_birth"])
          : null,
      gender: json["gender"] == 1,
      profilePic: json["profile_pic"],
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "full_name": fullName,
        "description": description,
        "years_of_exp": yearsOfExp,
        "date_of_birth": dateOfBirth?.toIso8601String(),
        "gender": gender == true ? 1 : 0,
        "profile_pic": profilePic,
      };
}