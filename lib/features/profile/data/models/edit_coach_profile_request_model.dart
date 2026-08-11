import 'package:dio/dio.dart';

class EditCoachProfileRequestModel {
  final String firstName;
  final String lastName;
  final String dateOfBirth;

  EditCoachProfileRequestModel({
    required this.firstName,
    required this.lastName,
    required this.dateOfBirth,
  });

  Future<FormData> toFormData() async {
    return FormData.fromMap({
      'first_name': firstName,
      'last_name': lastName,
      'date_of_birth': dateOfBirth,
      'update_pic': 0,
      '_method': 'PUT',
    });
  }
}
