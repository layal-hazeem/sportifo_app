import 'coach_image_model.dart';

class CoachDetailsModel {
  final int id;
  final String fullName;
  final String description;
  final int yearsOfExp;
  final String dateOfBirth;
  final int gender;
  final String profilePic;
  final List<CoachImageModel> pics;

  CoachDetailsModel({
    required this.id,
    required this.fullName,
    required this.description,
    required this.yearsOfExp,
    required this.dateOfBirth,
    required this.gender,
    required this.profilePic,
    required this.pics,
  });

  factory CoachDetailsModel.fromJson(Map<String, dynamic> json) {
    final picsList = json['pics'] as List? ?? [];
    return CoachDetailsModel(
      id: json['id'],
      fullName: json['full_name'],
      description: json['description'],
      yearsOfExp: json['years_of_exp'],
      dateOfBirth: json['date_of_birth'],
      gender: json['gender'],
      profilePic: json['profile_pic'],
      pics: picsList.map((e) => CoachImageModel.fromJson(e)).toList(),
    );
  }
}