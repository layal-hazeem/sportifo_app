// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class CompleteProfileRequestModel {
  String? first_name;
  String? last_name;
  String? email;
  String? phone;
  String? date_of_birth;
  String? gender;
  double? height;
  double? weight;
  bool? update_pic;
  String? profile_pic;
  double? shoulders_width;
  double? chest_perimeter;
  double? waist_perimeter;
  double? thigh_perimeter;
  double? hip_perimeter;
  double? arm_perimeter;

  CompleteProfileRequestModel({
    this.first_name,
    this.last_name,
    this.email,
    this.phone,
    this.date_of_birth,
    this.gender,
    this.height,
    this.weight,
    this.update_pic,
    this.profile_pic,
    this.shoulders_width,
    this.chest_perimeter,
    this.waist_perimeter,
    this.thigh_perimeter,
    this.hip_perimeter,
    this.arm_perimeter,
  });

  CompleteProfileRequestModel copyWith({
    String? first_name,
    String? last_name,
    String? email,
    String? phone,
    String? date_of_birth,
    String? gender,
    double? height,
    double? weight,
    bool? update_pic,
    String? profile_pic,
    double? shoulders_width,
    double? chest_perimeter,
    double? waist_perimeter,
    double? thigh_perimeter,
    double? hip_perimeter,
    double? arm_perimeter,
  }) {
    return CompleteProfileRequestModel(
      first_name: first_name ?? this.first_name,
      last_name: last_name ?? this.last_name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      date_of_birth: date_of_birth ?? this.date_of_birth,
      gender: gender ?? this.gender,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      update_pic: update_pic ?? this.update_pic,
      profile_pic: profile_pic ?? this.profile_pic,
      shoulders_width: shoulders_width ?? this.shoulders_width,
      chest_perimeter: chest_perimeter ?? this.chest_perimeter,
      waist_perimeter: waist_perimeter ?? this.waist_perimeter,
      thigh_perimeter: thigh_perimeter ?? this.thigh_perimeter,
      hip_perimeter: hip_perimeter ?? this.hip_perimeter,
      arm_perimeter: arm_perimeter ?? this.arm_perimeter,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'first_name': first_name,
      'last_name': last_name,
      'email': email,
      'phone': phone,
      'date_of_birth': date_of_birth,
      'gender': gender,
      'height': height ?? 0,
      'weight': weight ?? 0,
      'update_pic': update_pic,
      'profile_pic': profile_pic,
      'shoulders_width': shoulders_width,
      'chest_perimeter': chest_perimeter,
      'waist_perimeter': waist_perimeter,
      'thigh_perimeter': thigh_perimeter,
      'hip_perimeter': hip_perimeter,
      'arm_perimeter': arm_perimeter,
    };
  }

  factory CompleteProfileRequestModel.fromMap(Map<String, dynamic> map) {
    return CompleteProfileRequestModel(
      first_name: map['first_name'] != null
          ? map['first_name'] as String
          : null,
      last_name: map['last_name'] != null ? map['last_name'] as String : null,
      email: map['email'] != null ? map['email'] as String : null,
      phone: map['phone'] != null ? map['phone'] as String : null,
      date_of_birth: map['date_of_birth'] != null
          ? map['date_of_birth'] as String
          : null,
      gender: map['gender'] != null ? map['gender'] as String : null,
      height: map['height'] != null ? (map['height'] as num).toDouble() : null,
      weight: map['weight'] != null ? (map['weight'] as num).toDouble() : null,
      update_pic: map['update_pic'] != null ? map['update_pic'] as bool : null,
      profile_pic: map['profile_pic'] != null
          ? map['profile_pic'] as String
          : null,

      shoulders_width: map['shoulders_width'] != null
          ? map['shoulders_width'] as double
          : null,
      chest_perimeter: map['chest_perimeter'] != null
          ? (map['chest_perimeter'] as num).toDouble()
          : null,
      waist_perimeter: map['waist_perimeter'] != null
          ? (map['waist_perimeter'] as num).toDouble()
          : null,
      thigh_perimeter: map['thigh_perimeter'] != null
          ? (map['thigh_perimeter'] as num).toDouble()
          : null,
      hip_perimeter: map['hip_perimeter'] != null
          ? (map['hip_perimeter'] as num).toDouble()
          : null,
      arm_perimeter: map['arm_perimeter'] != null
          ? (map['arm_perimeter'] as num).toDouble()
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory CompleteProfileRequestModel.fromJson(String source) =>
      CompleteProfileRequestModel.fromMap(
        json.decode(source) as Map<String, dynamic>,
      );

  @override
  String toString() {
    return 'CompleteProfileRequestModel(first_name: $first_name, last_name: $last_name, email: $email, phone: $phone, date_of_birth: $date_of_birth, gender: $gender, height: $height, weight: $weight, update_pic: $update_pic, profile_pic: $profile_pic, shoulders_width: $shoulders_width, chest_perimeter: $chest_perimeter, waist_perimeter: $waist_perimeter, thigh_perimeter: $thigh_perimeter, hip_perimeter: $hip_perimeter, arm_perimeter: $arm_perimeter)';
  }

  @override
  bool operator ==(covariant CompleteProfileRequestModel other) {
    if (identical(this, other)) return true;

    return other.first_name == first_name &&
        other.last_name == last_name &&
        other.email == email &&
        other.phone == phone &&
        other.date_of_birth == date_of_birth &&
        other.gender == gender &&
        other.height == height &&
        other.weight == weight &&
        other.update_pic == update_pic &&
        other.profile_pic == profile_pic &&
        other.shoulders_width == shoulders_width &&
        other.chest_perimeter == chest_perimeter &&
        other.waist_perimeter == waist_perimeter &&
        other.thigh_perimeter == thigh_perimeter &&
        other.hip_perimeter == hip_perimeter &&
        other.arm_perimeter == arm_perimeter;
  }

  @override
  int get hashCode {
    return first_name.hashCode ^
        last_name.hashCode ^
        email.hashCode ^
        phone.hashCode ^
        date_of_birth.hashCode ^
        gender.hashCode ^
        height.hashCode ^
        weight.hashCode ^
        update_pic.hashCode ^
        profile_pic.hashCode ^
        shoulders_width.hashCode ^
        chest_perimeter.hashCode ^
        waist_perimeter.hashCode ^
        thigh_perimeter.hashCode ^
        hip_perimeter.hashCode ^
        arm_perimeter.hashCode;
  }
}
