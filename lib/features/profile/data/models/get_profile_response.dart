// To parse this JSON data, do
//
//     final ProfileResponseModel = ProfileResponseModelFromJson(jsonString);

import 'dart:convert';

ProfileResponseModel ProfileResponseModelFromJson(String str) =>
    ProfileResponseModel.fromJson(json.decode(str));

String ProfileResponseModelToJson(ProfileResponseModel data) =>
    json.encode(data.toJson());

class ProfileResponseModel {
  final int? id;
  final String firstName;
  final String lastName;
  final String? email;
  final String? phone;
  final DateTime dateOfBirth;
  final bool gender;
  final String? role;
  final double height;
  final double weight;
  final int? isActive;
  final bool? isVerified;
  final String? profilePic;
  final Sizes? sizes;
  final Coach? coach;

  ProfileResponseModel({
    this.id,
    required this.firstName,
    required this.lastName,
    this.email,
    this.phone,
    required this.dateOfBirth,
    required this.gender,
    this.role,
    required this.height,
    required this.weight,
    this.isActive,
    this.isVerified,
    this.profilePic,
    this.sizes,
    this.coach,
  });

  factory ProfileResponseModel.fromJson(Map<String, dynamic> json) =>
      ProfileResponseModel(
        id: json["id"],
        firstName: json["first_name"] ?? "",
        lastName: json["last_name"] ?? "",
        email: json["email"],
        phone: json["phone"],
        dateOfBirth: json["date_of_birth"] != null
            ? DateTime.parse(json["date_of_birth"])
            : DateTime.fromMillisecondsSinceEpoch(0),
        gender: json["gender"] == 1,
        role: json["role"],
        height: (json["height"] ?? 0).toDouble(),
        weight: (json["weight"] ?? 0).toDouble(),
        isActive: json["is_active"],
        isVerified: json["is_verified"],
        profilePic: json["profile_pic"],
        sizes: json["sizes"] == null ? null : Sizes.fromJson(json["sizes"]),
        coach: json["coach"] == null ? null : Coach.fromJson(json["coach"]),
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "first_name": firstName,
    "last_name": lastName,
    "email": email,
    "phone": phone,
    "date_of_birth":
        "${dateOfBirth.year.toString().padLeft(4, '0')}-${dateOfBirth.month.toString().padLeft(2, '0')}-${dateOfBirth.day.toString().padLeft(2, '0')}",
    "gender": gender ? 1 : 0,
    "role": role,
    "height": height,
    "weight": weight,
    "is_active": isActive,
    "is_verified": isVerified,
    "profile_pic": profilePic,
    "sizes": sizes?.toJson(),
    "coach": coach?.toJson(),
  };
}

class Sizes {
  final int? id;
  final double? height;
  final double? weight;
  final double? shouldersWidth;
  final double? chestPerimeter;
  final double? stomachPerimeter;
  final double? waistPerimeter;
  final double? thighPerimeter;
  final double? hipPerimeter;
  final double? armPerimeter;

  Sizes({
    this.id,
    this.height,
    this.weight,
    this.shouldersWidth,
    this.chestPerimeter,
    this.stomachPerimeter,
    this.waistPerimeter,
    this.thighPerimeter,
    this.hipPerimeter,
    this.armPerimeter,
  });

  factory Sizes.fromJson(Map<String, dynamic> json) => Sizes(
    id: json["id"],
    height: json["height"]?.toDouble(),
    weight: json["weight"]?.toDouble(),
    shouldersWidth: json["shoulders_width"]?.toDouble(),
    chestPerimeter: json["chest_perimeter"]?.toDouble(),
    stomachPerimeter: json["stomach_perimeter"]?.toDouble(),
    waistPerimeter: json["waist_perimeter"]?.toDouble(),
    thighPerimeter: json["thigh_perimeter"]?.toDouble(),
    hipPerimeter: json["hip_perimeter"]?.toDouble(),
    armPerimeter: json["arm_perimeter"]?.toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "height": height,
    "weight": weight,
    "shoulders_width": shouldersWidth,
    "chest_perimeter": chestPerimeter,
    "stomach_perimeter": stomachPerimeter,
    "waist_perimeter": waistPerimeter,
    "thigh_perimeter": thighPerimeter,
    "hip_perimeter": hipPerimeter,
    "arm_perimeter": armPerimeter,
  };
}

class Coach {
  final int? id;
  final String? fullName;
  final String? description;
  final int? yearsOfExp;
  final List<CoachImage>? pics;

  Coach({this.id, this.fullName, this.description, this.yearsOfExp, this.pics});

  factory Coach.fromJson(Map<String, dynamic> json) => Coach(
    id: json["id"],
    fullName: json["full_name"],
    description: json["description"],
    yearsOfExp: json["years_of_exp"],
    pics:
        (json["pics"] as List?)?.map((e) => CoachImage.fromJson(e)).toList() ??
        [],
  );

  Map<String, dynamic> toJson() => {
    "full_name": fullName,
    "description": description,
    "years_of_exp": yearsOfExp,
    "pics": pics,
  };
}

class CoachImage {
  final int id;
  final String type;
  final String name;
  final String url;

  CoachImage({
    required this.id,
    required this.type,
    required this.name,
    required this.url,
  });

  factory CoachImage.fromJson(Map<String, dynamic> json) {
    return CoachImage(
      id: json["id"],
      type: json["type"] ?? "",
      name: json["name"] ?? "",
      url: json["url"] ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "type": type,
    "name": name,
    "url": url,
  };
}
