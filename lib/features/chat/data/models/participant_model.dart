// lib/features/chat/data/models/participant_model.dart

class ParticipantModel {
  final int userId;
  final String name;
  final int gender;
  final String? profilePic;

  ParticipantModel({
    required this.userId,
    required this.name,
    required this.gender,
    required this.profilePic,
  });

  factory ParticipantModel.fromJson(Map<String, dynamic> json) {
    return ParticipantModel(
      userId: json['user_id'] ?? 0,
      name: json['name'] ?? '',
      gender:json['gender']?? 0,
      profilePic: json['profile_pic'],
    );
  }



  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'name': name,
      'gender': gender,
      'profile_pic': profilePic,
    };
  }
}