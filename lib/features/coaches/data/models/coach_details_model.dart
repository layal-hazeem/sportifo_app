// lib/features/coaches/data/models/coach_details_model.dart

import 'coach_image_model.dart';
import 'subscription_model.dart'; // 👈 استيراد المودل الجديد

class CoachDetailsModel {
  final int id;
  final String fullName;
  final String description;
  final int yearsOfExp;
  final String dateOfBirth;
  final int gender;
  final String profilePic;
  final List<CoachImageModel> pics;
  final List<SubscriptionModel> subscriptions; // 👈 إضافة ليستة الاشتراكات

  CoachDetailsModel({
    required this.id,
    required this.fullName,
    required this.description,
    required this.yearsOfExp,
    required this.dateOfBirth,
    required this.gender,
    required this.profilePic,
    required this.pics,
    required this.subscriptions, // 👈 إضافتها للكونستركتور
  });

  factory CoachDetailsModel.fromJson(Map<String, dynamic> json) {
    final picsList = json['pics'] as List? ?? [];
    final subscriptionsList = json['subscriptions'] as List? ?? []; // 👈 جلب الاشتراكات من الـ JSON

    return CoachDetailsModel(
      id: json['id'] ?? 0,
      fullName: json['full_name'] ?? '',
      description: json['description'] ?? '',
      yearsOfExp: json['years_of_exp'] ?? 0,
      dateOfBirth: json['date_of_birth'] ?? '',
      gender: json['gender'] ?? 0,
      profilePic: json['profile_pic'] ?? '',
      pics: picsList.map((e) => CoachImageModel.fromJson(e)).toList(),
      // 👈 تحويل الـ JSON إلى ليستة من المودل
      subscriptions: subscriptionsList.map((e) => SubscriptionModel.fromJson(e)).toList(),
    );
  }
}