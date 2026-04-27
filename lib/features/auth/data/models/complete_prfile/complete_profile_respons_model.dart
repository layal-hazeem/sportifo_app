// To parse this JSON data, do
//
//     final completeProfileResponsModel = completeProfileResponsModelFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

CompleteProfileResponsModel completeProfileResponsModelFromJson(String str) => 
    CompleteProfileResponsModel.fromJson(json.decode(str));

String completeProfileResponsModelToJson(CompleteProfileResponsModel data) => 
    json.encode(data.toJson());

class CompleteProfileResponsModel {
    final int? id;
    final String? firstName;
    final String? lastName;
    final String? email;
    final String? phone; // جعلتهnullable
    final DateTime? dateOfBirth;
    final bool? gender;
    final int? isActive;
    final bool? isVerified;
    final dynamic profilePic;
    final Sizes? sizes;

    CompleteProfileResponsModel({
        this.id,
        this.firstName,
        this.lastName,
        this.email,
        this.phone,
        this.dateOfBirth,
        this.gender,
        this.isActive,
        this.isVerified,
        this.profilePic,
        this.sizes,
    });

CompleteProfileResponsModel copyWith({
        int? id,
        String? firstName,
        String? lastName,
        String? email,
        String? phone,
        DateTime? dateOfBirth,
        bool? gender,
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
        phone: json["phone"], // سيقبل null الآن
        dateOfBirth: json["date_of_birth"] == null ? null : DateTime.parse(json["date_of_birth"]),
        gender: json["gender"] is int ? (json["gender"] == 1) : json["gender"],
        isActive: json["is_active"],
        isVerified: json["is_verified"] is int ? (json["is_verified"] == 1) : json["is_verified"],
        profilePic: json["profile_pic"],
        sizes: json["sizes"] == null ? null : Sizes.fromJson(json["sizes"]),
    );

Map<String, dynamic> toJson() => {
        "id": id,
        "first_name": firstName,
        "last_name": lastName,
        "email": email,
        "phone": phone,
        "date_of_birth": dateOfBirth?.toIso8601String(), // طريقة أسهل وأضمن للتحويل
        "gender": gender,
        "is_active": isActive,
        "is_verified": isVerified,
        "profile_pic": profilePic,
        "sizes": sizes?.toJson(),
    };
}

class Sizes {
    final int? id;
    final double? height; // حولتها لـ double لتناسب الـ UI والـ JSON
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

 Sizes copyWith({
        int? id,
        double? height,
        double? weight,
        double? shouldersWidth,
        double? chestPerimeter,
        double? stomachPerimeter,
        double? waistPerimeter,
        double? thighPerimeter,
        double? hipPerimeter,
        double? armPerimeter,
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
        // استخدام num ثم toDouble يضمن عدم الخطأ سواء جاء الرقم 55 أو 55.5
        height: (json["height"] as num?)?.toDouble(),
        weight: (json["weight"] as num?)?.toDouble(),
        shouldersWidth: (json["shoulders_width"] as num?)?.toDouble(),
        chestPerimeter: (json["chest_perimeter"] as num?)?.toDouble(),
        stomachPerimeter: (json["stomach_perimeter"] as num?)?.toDouble(),
        waistPerimeter: (json["waist_perimeter"] as num?)?.toDouble(),
        thighPerimeter: (json["thigh_perimeter"] as num?)?.toDouble(),
        hipPerimeter: (json["hip_perimeter"] as num?)?.toDouble(),
        armPerimeter: (json["arm_perimeter"] as num?)?.toDouble(),
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
