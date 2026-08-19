// lib/features/chat/data/models/participant_model.dart

class ParticipantModel {
  final int userId;
  final String name;
  final String? profilePic;

  ParticipantModel({
    required this.userId,
    required this.name,
    required this.profilePic,
  });

  factory ParticipantModel.fromJson(Map<String, dynamic> json) {
    return ParticipantModel(
      userId: json['user_id'] ?? 0,
      name: json['name'] ?? '',
      profilePic: json['profile_pic'],
    );
  }



  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'name': name,
      'profile_pic': profilePic,
    };
  }
}