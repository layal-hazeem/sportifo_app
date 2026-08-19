import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sportifo_app/core/theme/app_colors.dart';
import 'package:sportifo_app/core/theme/app_theme_extensions.dart';
import 'package:sportifo_app/features/profile/data/models/get_profile_response.dart';
import 'package:sportifo_app/features/profile/presentation/widgets/basic_info_section.dart';
import 'package:sportifo_app/l10n/app_localizations.dart';

class UserTabsSection extends StatefulWidget {
  final ProfileResponseModel userProfile;

  const UserTabsSection({super.key, required this.userProfile});

  @override
  State<UserTabsSection> createState() => _UserTabsSectionState();
}

class _UserTabsSectionState extends State<UserTabsSection> {
  int selectedTab = 0;

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
              _tabButton(l10n.bodyMeasurements, 1),
            ],
          ),
        ),

        const SizedBox(height: 20),

        TweenAnimationBuilder<double>(
          key: ValueKey(selectedTab),
          duration: const Duration(milliseconds: 280),
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
              ? _buildInfoTab()
              : _buildBodyMeasurementsTab(),
        ),
      ],
    );
  }

  Widget _buildInfoTab() {
    return Container(
      key: const ValueKey("info"),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: BasicInfoSection(
        email: widget.userProfile.email,
        phone: widget.userProfile.phone,
        birth: widget.userProfile.dateOfBirth,
      ),
    );
  }

  Widget _buildBodyMeasurementsTab() {
    final l10n = AppLocalizations.of(context)!;
    final s = widget.userProfile.sizes;

    if (s == null) {
      return Container(
        key: const ValueKey("empty"),
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(16),
        decoration: _cardDecoration(),
        child: Center(child: Text(l10n.noBodyMeasurements)),
      );
    }

    return Container(
      key: const ValueKey("body"),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          _measurementRow(
            l10n.height,
            "${s.height ?? "-"} cm",
            "assets/icons/height.svg",
          ),
          _measurementRow(
            l10n.weight,
            "${s.weight ?? "-"} kg",
            "assets/icons/weight.svg",
          ),
          _measurementRow(
            l10n.shoulders,
            s.shouldersWidth?.toString() ?? "-",
            "assets/icons/shoulders.svg",
          ),
          _measurementRow(
            l10n.chestCircumference,
            s.chestPerimeter?.toString() ?? "-",
            "assets/icons/chest.svg",
          ),
          _measurementRow(
            l10n.waist,
            s.waistPerimeter?.toString() ?? "-",
            "assets/icons/waist.svg",
          ),
          _measurementRow(
            l10n.thighCircumference,
            s.thighPerimeter?.toString() ?? "-",
            "assets/icons/leg.svg",
          ),
          _measurementRow(
            l10n.hipCircumference,
            s.hipPerimeter?.toString() ?? "-",
            "assets/icons/chest.svg",
          ),
          _measurementRow(
            l10n.armCircumference,
            s.armPerimeter?.toString() ?? "-",
            "assets/icons/hand.svg",
          ),
        ],
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

  Widget _measurementRow(String title, String value, String iconPath) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SvgPicture.asset(
            iconPath,
            width: 28,
            height: 28,
            colorFilter: const ColorFilter.mode(
              AppColors.primaryBtn,
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(title)),
          Text(value),
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: context.backgroundColor,
      borderRadius: BorderRadius.circular(18),
      boxShadow: [
        BoxShadow(
          color: AppColors.primaryBtn.withOpacity(.05),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  BoxDecoration _tabDecoration() {
    return BoxDecoration(
     color: context.backgroundColor,
      borderRadius: BorderRadius.circular(30),
      boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(.05), blurRadius: 10),
      ],
    );
  }
}
