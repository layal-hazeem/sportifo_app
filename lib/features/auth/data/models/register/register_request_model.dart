import 'dart:io';
import 'package:dio/dio.dart';

class RegisterRequestModel {
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String password;
  final String passwordConfirmation;
  final String otpMethod;
  final File? profilePic; // (optional)

  RegisterRequestModel({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.password,
    required this.passwordConfirmation,
    required this.otpMethod,
    this.profilePic,
  });


  Future<FormData> toFormData() async {
    Map<String, dynamic> map = {
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone': phone,
      'password': password,
      'password_confirmation': passwordConfirmation,
      'otp_method': otpMethod,
    };

    if (profilePic != null) {
      map['profile_pic'] = await MultipartFile.fromFile(profilePic!.path);
    }

    return FormData.fromMap(map);
  }
}