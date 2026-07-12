import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:sportifo_app/core/localization/locale_cubit.dart';
import 'package:sportifo_app/core/routes/app_routes.dart';
import 'package:sportifo_app/core/theme/app_colors.dart';
import 'package:sportifo_app/core/widgets/wave_app_bar.dart';
import '../widgets/settings_section.dart';
import '../widgets/settings_tile.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: WaveAppBar(title: 'Settings', showBackButton: true),

      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          SettingsSection(
            title: "General",
            children: [
              SettingsTile(
                icon: Icons.language,
                title: "Language",
                onTap: () {
                  _showLanguageDialog(context);
                },
              ),

              SettingsTile(
                icon: Icons.dark_mode_outlined,
                title: "Theme",
                onTap: () {},
              ),

              SettingsTile(
                icon: Icons.notifications_none,
                title: "Notifications",
                onTap: () {},
              ),
            ],
          ),

          SettingsSection(
            title: "Account",
            children: [
              SettingsTile(
                icon: Icons.lock_outline,
                title: "Change Password",
                onTap: () {},
              ),

              SettingsTile(
                icon: Icons.privacy_tip_outlined,
                title: "Privacy Policy",
                onTap: () {},
              ),
            ],
          ),

          SettingsSection(
            title: "Danger Zone",
            children: [
              SettingsTile(
                icon: Icons.delete_forever,
                title: "Delete Account",
                isDanger: true,
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.deleteAccount);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    final localeCubit = context.read<LocaleCubit>();
    final currentLocale = Localizations.localeOf(context).languageCode;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 35),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(35)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                width: 45,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),

              const SizedBox(height: 25),

              // Icon
              Container(
                height: 75,
                width: 75,
                decoration: BoxDecoration(
                  color: AppColors.primaryBtn.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.language_rounded,
                  size: 40,
                  color: AppColors.primaryBtn,
                ),
              ),

              const SizedBox(height: 16),

              Text(
                "Choose Language",
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              Text(
                "Select your preferred app language",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              ),

              const SizedBox(height: 25),

              _languageItem(
                context,
                title: "English",
                subtitle: "English",
                languageIcon: "EN",
                selected: currentLocale == "en",
                onTap: () {
                  localeCubit.changeLanguage("en");
                  Navigator.pop(context);
                },
              ),

              const SizedBox(height: 14),

              _languageItem(
                context,
                title: "العربية",
                subtitle: "Arabic",
                languageIcon: "ع",
                selected: currentLocale == "ar",
                onTap: () {
                  localeCubit.changeLanguage("ar");
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _languageItem(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String languageIcon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primaryBtn.withOpacity(0.12)
              : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.primaryBtn : Colors.grey.shade200,
            width: selected ? 1.5 : 1,
          ),
        ),

        child: Row(
          children: [
            Container(
              height: 55,
              width: 55,
              decoration: BoxDecoration(
                color: selected ? AppColors.primaryBtn : Colors.grey.shade200,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  languageIcon,
                  style: TextStyle(
                    color: selected ? Colors.white : AppColors.primaryBtn,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 3),

                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),

            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: selected
                  ? Container(
                      key: const ValueKey("selected"),
                      height: 28,
                      width: 28,
                      decoration: BoxDecoration(
                        color: AppColors.primaryBtn,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 18,
                      ),
                    )
                  : const SizedBox(
                      key: ValueKey("empty"),
                      height: 28,
                      width: 28,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
