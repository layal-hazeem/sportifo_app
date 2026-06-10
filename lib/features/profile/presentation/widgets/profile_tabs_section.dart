import 'package:flutter/material.dart';
import 'package:sportifo_app/core/theme/app_colors.dart';
import 'package:sportifo_app/features/profile/data/models/coach_profile_response.dart';
import 'package:sportifo_app/features/profile/data/models/user_profile_response.dart';
import 'package:sportifo_app/l10n/app_localizations.dart';
import 'basic_info_section.dart';

class ProfileTabsSection extends StatefulWidget {
  final ProfileResponsModel userProfile;
  final CoachProfileModel? coachProfile;
  final String role;

  const ProfileTabsSection({
    super.key,
    required this.userProfile,
    this.coachProfile,
    required this.role,
  });

  @override
  State<ProfileTabsSection> createState() => _ProfileTabsSectionState();
}

class _ProfileTabsSectionState extends State<ProfileTabsSection> {
  int selectedTab = 0;
  bool get isCoach => widget.role == "coach";

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        // 🔘 Tabs
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
            ],
          ),
          child: Row(
            children: isCoach
                ? [_tabButton("Information", 0), _tabButton("Certificates", 1)]
                : [
                    _tabButton("Information", 0),
                    _tabButton("Body Measurements", 1),
                  ],
          ),
        ),

        const SizedBox(height: 20),

        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _buildContent(),
        ),
      ],
    );
  }

  Widget _buildContent() {
    if (isCoach) {
      return selectedTab == 0 ? _buildCoachInfo() : _buildCertificatesTab();
    } else {
      return selectedTab == 0 ? _buildUserInfo() : _buildBodyTab();
    }
  }

  Widget _buildUserInfo() {
    final p = widget.userProfile!;

    return Container(
      key: const ValueKey("user_info"),
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: BasicInfoSection(
        email: p.email,
        phone: p.phone,
        birth: p.dateOfBirth,
      ),
    );
  }

  Widget _buildCoachInfo() {
    final c = widget.coachProfile;

    if (c == null) {
      return const Center(child: Text("No coach data available"));
    }

    return Container(
      key: const ValueKey("coach_info"),
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: _cardStyle(),
      child: Column(
        children: [
          _row("Full Name", c.fullName),
          _row("Years of Experience", "${c.yearsOfExp}"),
          _row("Date of Birth", c.dateOfBirth),
          _row("Gender", c.gender ? "Male" : "Female"),

          const SizedBox(height: 16),

          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Description",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),

          const SizedBox(height: 8),

          Text(c.description, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildCertificatesTab() {
    final c = widget.coachProfile;

    if (c == null) {
      return const Center(child: Text("No certificates data"));
    }

    final certificates = c.certificates;

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: certificates.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemBuilder: (context, index) {
          final cert = certificates[index];

          return ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(cert.url, fit: BoxFit.cover),
          );
        },
      ),
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
            color: isSelected ? AppColors.primaryBtn : Colors.transparent,
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

  // 🧾 INFO TAB
  Widget _buildInfoTab() {
    final l10n = AppLocalizations.of(context)!;
    final p = widget.userProfile;

    return Container(
      key: ValueKey(l10n.information),
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: _cardStyle(),
      child: BasicInfoSection(
        email: p.email,
        phone: p.phone,
        birth: p.dateOfBirth,
      ),
    );
  }

  // 📏 BODY TAB
  Widget _buildBodyTab() {
    final l10n = AppLocalizations.of(context)!;

    final s = widget.userProfile.sizes;

    // 🔥 إذا ما في بيانات
    if (s == null) {
      return Container(
        key: ValueKey(l10n.bodyMeasurements),
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: _cardStyle(),
        child: Center(
          child: Text(
            l10n.noBodyMeasurements,
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return Container(
      key: ValueKey(l10n.bodyMeasurements),
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: _cardStyle(),
      child: Column(
        children: [
          _row(l10n.height, "${s.height ?? "-"} cm"),
          _row(l10n.weight, "${s.weight ?? "-"} kg"),
          _row(l10n.shoulders, s.shouldersWidth?.toString() ?? "-"),
          _row(l10n.chestCircumference, s.chestPerimeter?.toString() ?? "-"),
          _row(l10n.waist, s.waistPerimeter?.toString() ?? "-"),
          _row(l10n.thighCircumference, s.thighPerimeter?.toString() ?? "-"),
          _row(l10n.hipCircumference, s.hipPerimeter?.toString() ?? "-"),
          _row(l10n.armCircumference, s.armPerimeter?.toString() ?? "-"),
        ],
      ),
    );
  }

  Widget _row(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  BoxDecoration _cardStyle() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
}
