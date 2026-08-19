import 'package:flutter/material.dart';
import 'package:sportifo_app/core/theme/app_colors.dart';
import 'package:sportifo_app/core/theme/app_theme_extensions.dart';
import 'package:sportifo_app/features/profile/data/models/get_profile_response.dart';
import 'package:sportifo_app/features/profile/presentation/widgets/coach_certificates_section.dart';
import 'package:sportifo_app/features/profile/presentation/widgets/coach_info_section.dart';
import 'package:sportifo_app/l10n/app_localizations.dart';

class CoachTabsSection extends StatefulWidget {
  final ProfileResponseModel userProfile;

  const CoachTabsSection({super.key, required this.userProfile});

  @override
  State<CoachTabsSection> createState() => _CoachTabsSectionState();
}

class _CoachTabsSectionState extends State<CoachTabsSection> {
  int selectedTab = 0;

  Coach? get coach => widget.userProfile.coach;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(6),
          decoration: _tabDecoration(),
          child: Row(
            children: [
              _tabButton(l10n.information, 0),
              _tabButton(l10n.certificates, 1),
            ],
          ),
        ),

        const SizedBox(height: 20),

        TweenAnimationBuilder<double>(
          key: ValueKey(selectedTab),
          duration: const Duration(milliseconds: 380),
          curve: Curves.easeOutCubic,
          tween: Tween(begin: 0.97, end: 1),
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.scale(
                scale: value,
                alignment: Alignment.topCenter,
                child: child,
              ),
            );
          },
          child: selectedTab == 0
              ? CoachInfoSection(profile: widget.userProfile)
              : CoachCertificatesSection(certificates: coach?.pics ?? []),
        ),
      ],
    );
  }

  Widget _tabButton(String title, int index) {
    final isSelected = selectedTab == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedTab = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryBtn : context.backgroundColor,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  BoxDecoration _tabDecoration() {
    return BoxDecoration(
      color: context.backgroundColor,
      borderRadius: BorderRadius.circular(30),
      boxShadow: [
        BoxShadow(
          color: AppColors.primaryBtn.withValues(alpha: 0.2),
          blurRadius: 10,
        ),
      ],
    );
  }
}
