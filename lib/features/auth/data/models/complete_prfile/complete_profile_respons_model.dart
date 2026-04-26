// To parse this JSON data, do
//
//     final completeProfileResponsModel = completeProfileResponsModelFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

CompleteProfileResponsModel completeProfileResponsModelFromJson(String str) => CompleteProfileResponsModel.fromJson(json.decode(str));

String completeProfileResponsModelToJson(CompleteProfileResponsModel data) => json.encode(data.toJson());

class CompleteProfileResponsModel {
    final int id;
    final String firstName;
    final String lastName;
    final String email;
    final String phone;
    final DateTime dateOfBirth;
    final bool gender;
    final int height;
    final int weight;
    final int isActive;
    final bool isVerified;
    final dynamic profilePic;
    final Sizes sizes;

    CompleteProfileResponsModel({
        required this.id,
        required this.firstName,
        required this.lastName,
        required this.email,
        required this.phone,
        required this.dateOfBirth,
        required this.gender,
        required this.height,
        required this.weight,
        required this.isActive,
        required this.isVerified,
        required this.profilePic,
        required this.sizes,
    });

    CompleteProfileResponsModel copyWith({
        int? id,
        String? firstName,
        String? lastName,
        String? email,
        String? phone,
        DateTime? dateOfBirth,
        bool? gender,
        int? height,
        int? weight,
        int? isActive,
        bool? isVerified,
        dynamic profilePic,
        Sizes? sizes,
    }) => 
        CompleteProfileResponsModel(
            id: id ?? this.id,
            firstName: firstName ?? this.firstName,
            lastName: lastName ?? this.lastName,
            email: email ?? this.email,
            phone: phone ?? this.phone,
            dateOfBirth: dateOfBirth ?? this.dateOfBirth,
            gender: gender ?? this.gender,
            height: height ?? this.height,
            weight: weight ?? this.weight,
            isActive: isActive ?? this.isActive,
            isVerified: isVerified ?? this.isVerified,
            profilePic: profilePic ?? this.profilePic,
            sizes: sizes ?? this.sizes,
        );

    factory CompleteProfileResponsModel.fromJson(Map<String, dynamic> json) => CompleteProfileResponsModel(
        id: json["id"],
        firstName: json["first_name"],
        lastName: json["last_name"],
        email: json["email"],
        phone: json["phone"],
        dateOfBirth: DateTime.parse(json["date_of_birth"]),
        gender: json["gender"],
        height: json["height"],
        weight: json["weight"],
        isActive: json["is_active"],
        isVerified: json["is_verified"],
        profilePic: json["profile_pic"],
        sizes: Sizes.fromJson(json["sizes"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "first_name": firstName,
        "last_name": lastName,
        "email": email,
        "phone": phone,
        "date_of_birth": "${dateOfBirth.year.toString().padLeft(4, '0')}-${dateOfBirth.month.toString().padLeft(2, '0')}-${dateOfBirth.day.toString().padLeft(2, '0')}",
        "gender": gender,
        "height": height,
        "weight": weight,
        "is_active": isActive,
        "is_verified": isVerified,
        "profile_pic": profilePic,
        "sizes": sizes.toJson(),
    };
}

class Sizes {
    final int id;
    final int height;
    final int weight;
    final int shouldersWidth;
    final int chestPerimeter;
    final int stomachPerimeter;
    final int waistPerimeter;
    final int thighPerimeter;
    final int hipPerimeter;
    final int armPerimeter;

    Sizes({
        required this.id,
        required this.height,
        required this.weight,
        required this.shouldersWidth,
        required this.chestPerimeter,
        required this.stomachPerimeter,
        required this.waistPerimeter,
        required this.thighPerimeter,
        required this.hipPerimeter,
        required this.armPerimeter,
    });

    Sizes copyWith({
        int? id,
        int? height,
        int? weight,
        int? shouldersWidth,
        int? chestPerimeter,
        int? stomachPerimeter,
        int? waistPerimeter,
        int? thighPerimeter,
        int? hipPerimeter,
        int? armPerimeter,
    }) => 
        Sizes(
            id: id ?? this.id,
            height: height ?? this.height,
            weight: weight ?? this.weight,
            shouldersWidth: shouldersWidth ?? this.shouldersWidth,
            chestPerimeter: chestPerimeter ?? this.chestPerimeter,
            stomachPerimeter: stomachPerimeter ?? this.stomachPerimeter,
            waistPerimeter: waistPerimeter ?? this.waistPerimeter,
            thighPerimeter: thighPerimeter ?? this.thighPerimeter,
            hipPerimeter: hipPerimeter ?? this.hipPerimeter,
            armPerimeter: armPerimeter ?? this.armPerimeter,
        );

    factory Sizes.fromJson(Map<String, dynamic> json) => Sizes(
        id: json["id"],
        height: json["height"],
        weight: json["weight"],
        shouldersWidth: json["shoulders_width"],
        chestPerimeter: json["chest_perimeter"],
        stomachPerimeter: json["stomach_perimeter"],
        waistPerimeter: json["waist_perimeter"],
        thighPerimeter: json["thigh_perimeter"],
        hipPerimeter: json["hip_perimeter"],
        armPerimeter: json["arm_perimeter"],
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
