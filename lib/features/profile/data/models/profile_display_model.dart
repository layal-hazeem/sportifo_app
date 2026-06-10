import 'package:sportifo_app/features/profile/data/models/coach_profile_response.dart';
import 'package:sportifo_app/features/profile/data/models/user_profile_response.dart';

class ProfileDisplayModel {
  final String id;
  final String name;
  final String imageUrl;
  final String role;

  final String? description;
  final int? yearsOfExp;
  final List<String> gallery;

  ProfileDisplayModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.role,
    this.description,
    this.yearsOfExp,
    this.gallery = const [],
  });


}