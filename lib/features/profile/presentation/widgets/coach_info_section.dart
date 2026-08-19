import 'package:flutter/material.dart';
import 'package:sportifo_app/core/theme/app_theme_extensions.dart';
import 'package:sportifo_app/features/profile/data/models/get_profile_response.dart';
import 'package:sportifo_app/features/profile/presentation/widgets/basic_info_section.dart';
import 'package:sportifo_app/l10n/app_localizations.dart';

class CoachInfoSection extends StatelessWidget {
  final ProfileResponseModel profile;

  const CoachInfoSection({super.key, required this.profile});

  Coach? get coach => profile.coach;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.backgroundColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: context.textColor.withOpacity(.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BasicInfoSection(
            email: profile.email,
            phone: profile.phone,
            birth: profile.dateOfBirth,
          ),

          const Divider(height: 32),

          _item("Years of Experience", "${coach?.yearsOfExp ?? "-"}"),

          const SizedBox(height: 18),

           Text(
            l10n.description,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),

          const SizedBox(height: 10),

          Text(
            coach?.description ?? "-",
            style: TextStyle(color: context.textColor, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _item(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        Text(value),
      ],
    );
  }
}
