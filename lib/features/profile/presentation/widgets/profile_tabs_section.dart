import 'package:flutter/material.dart';
import 'package:sportifo_app/features/profile/data/models/get_profile_response.dart';
import 'package:sportifo_app/features/profile/presentation/widgets/coach_tabs_section.dart';
import 'package:sportifo_app/features/profile/presentation/widgets/user_tabs_section.dart';

class ProfileTabsSection extends StatelessWidget {
  final ProfileResponseModel userProfile;
  final String role;

  const ProfileTabsSection({
    super.key,
    required this.userProfile,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    if (role == "coach") {
      return CoachTabsSection(userProfile: userProfile);
    }

    return UserTabsSection(userProfile: userProfile);
  }
}