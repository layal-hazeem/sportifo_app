

class CoachProfileResponse {
  final String message;
  final CoachProfileModel data;

  CoachProfileResponse({required this.message, required this.data});

  factory CoachProfileResponse.fromJson(Map<String, dynamic> json) {
    return CoachProfileResponse(
      message: json['message'] ?? '',
      data: CoachProfileModel.fromJson(json['data'] ?? {}),
    );
  }
}

class CoachProfileModel {
  final int id;
  final String fullName;
  final String description;
  final int yearsOfExp;
  final String dateOfBirth;
  final bool gender;
  final String profilePic;
  final List<dynamic> subscriptions;
  final List<CoachCertificateModel> certificates;

  CoachProfileModel({
    required this.id,
    required this.fullName,
    required this.description,
    required this.yearsOfExp,
    required this.dateOfBirth,
    required this.gender,
    required this.profilePic,
    required this.subscriptions,
    required this.certificates,
  });

  factory CoachProfileModel.fromJson(Map<String, dynamic> json) {
    return CoachProfileModel(
      id: json['id'] ?? 0,
      fullName: json['full_name'] ?? '',
      description: json['description'] ?? '',
      yearsOfExp: json['years_of_exp'] ?? 0,
      dateOfBirth: json['date_of_birth'] ?? '',
      gender: json['gender'] ?? 1,
      profilePic: json['profile_pic'] ?? '',
      subscriptions: json['subscriptions'] ?? [],
      certificates: (json['pics'] as List? ?? [])
          .map((e) => CoachCertificateModel.fromJson(e))
          .toList(),
    );
  }
}

class CoachCertificateModel {
  final int id;
  final String type;
  final String name;
  final String url;

  CoachCertificateModel({
    required this.id,
    required this.type,
    required this.name,
    required this.url,
  });

  factory CoachCertificateModel.fromJson(Map<String, dynamic> json) {
    return CoachCertificateModel(
      id: json['id'] ?? 0,
      type: json['type'] ?? '',
      name: json['name'] ?? '',
      url: json['url'] ?? '',
    );
  }
}
