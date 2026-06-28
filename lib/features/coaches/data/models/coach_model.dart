// lib/features/coaches/data/models/coach_model.dart

class CoachModel {
  final int id;
  final String fullName;
  final String description;
  final int yearsOfExp;
  final String dateOfBirth;
  final int gender;
  final String profilePic;

  CoachModel({
    required this.id,
    required this.fullName,
    required this.description,
    required this.yearsOfExp,
    required this.dateOfBirth,
    required this.gender,
    required this.profilePic,
  });

  factory CoachModel.fromJson(Map<String, dynamic> json) {
    return CoachModel(
      id: json['id'] ?? 0,
      fullName: json['full_name'] ?? '',
      description: json['description'] ?? '',
      yearsOfExp: json['years_of_exp'] ?? 0,
      dateOfBirth: json['date_of_birth'] ?? '',
      gender: json['gender'] ?? 0,
      profilePic: json['profile_pic'] ?? '',
    );
  }
}