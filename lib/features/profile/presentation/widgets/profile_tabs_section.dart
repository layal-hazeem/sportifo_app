import 'package:flutter/material.dart';
import 'package:sportifo_app/core/theme/app_colors.dart';
import 'package:sportifo_app/features/profile/data/models/profile_response.dart';
import 'package:sportifo_app/l10n/app_localizations.dart';
import 'basic_info_section.dart';

class ProfileTabsSection extends StatefulWidget {
  final ProfileResponsModel profile;

  const ProfileTabsSection({super.key, required this.profile});

  @override
  State<ProfileTabsSection> createState() => _ProfileTabsSectionState();
}

class _ProfileTabsSectionState extends State<ProfileTabsSection> {
  int selectedTab = 0;

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
            children: [
              _tabButton(l10n.information, 0),
              _tabButton(l10n.bodyMeasurements, 1),
            ],
          ),
        ),

        const SizedBox(height: 20),

        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: selectedTab == 0 ? _buildInfoTab() : _buildBodyTab(),
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
    final p = widget.profile;

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

    final s = widget.profile.sizes;

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
