class CoachModel {
  final int id;
  final String fullName;
  final String description;
  final int yearsOfExp;
  final String dateOfBirth;
  final int gender;
  final String profilePic;

  CoachModel({required this.id, required this.fullName, required this.description, required this.yearsOfExp, required this.dateOfBirth, required this.gender, required this.profilePic});

  factory CoachModel.fromJson(Map<String, dynamic> json) {
    return CoachModel(
      id: json['id'],
      fullName: json['full_name'],
      description: json['description'],
      yearsOfExp: json['years_of_exp'],
      dateOfBirth: json['date_of_birth'],
      gender: json['gender'],
      profilePic: json['profile_pic'],
    );
  }
}