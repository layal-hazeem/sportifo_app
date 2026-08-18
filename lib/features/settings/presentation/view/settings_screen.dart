import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:sportifo_app/core/localization/locale_cubit.dart';
import 'package:sportifo_app/core/routes/app_routes.dart';
import 'package:sportifo_app/core/theme/app_colors.dart';
import 'package:sportifo_app/core/theme/app_theme_extensions.dart'; // 👈 استدعاء الـ Extension
import 'package:sportifo_app/core/theme/theme_cubit.dart'; // 👈 استدعاء الـ ThemeCubit
import 'package:sportifo_app/core/widgets/wave_app_bar.dart';
import 'package:sportifo_app/l10n/app_localizations.dart';
import '../widgets/settings_section.dart';
import '../widgets/settings_tile.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: context
          .backgroundColor, // 👈 استخدام الـ Extension لتغيير الخلفية تلقائياً

      appBar: WaveAppBar(title: l10n.settings, showBackButton: true),

      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          SettingsSection(
            title: l10n.general,
            children: [
              SettingsTile(
                icon: Icons.language,
                title: l10n.language,
                onTap: () {
                  _showLanguageDialog(context);
                },
              ),

              // 🔥 زر الثيم مع جلب الحالة الحالية لعرضها
              BlocBuilder<ThemeCubit, ThemeMode>(
                builder: (context, themeMode) {
                  bool isDark = themeMode == ThemeMode.dark;
                  return SettingsTile(
                    icon: isDark ? Icons.dark_mode : Icons.light_mode_outlined,
                    title: l10n.theme,
                    onTap: () {
                      _showThemeDialog(context); // 👈 إظهار حوار اختيار الثيم
                    },
                  );
                },
              ),

              SettingsTile(
                icon: Icons.notifications_none,
                title: l10n.notifications,
                onTap: () {},
              ),
            ],
          ),

          SettingsSection(
            title: l10n.account,
            children: [
              SettingsTile(
                icon: Icons.lock_outline,
                title: l10n.changePassword,
                onTap: () {},
              ),

              SettingsTile(
                icon: Icons.privacy_tip_outlined,
                title: l10n.privacyPolicy,
                onTap: () {},
              ),
            ],
          ),

          SettingsSection(
            title: "",
            children: [
              SettingsTile(
                icon: Icons.delete_forever,
                title: l10n.deleteAccount,
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

  // دالة حوار اختيار اللغة (كما هي لديك)
  void _showLanguageDialog(BuildContext context) {
    // ... محتوى دالة اللغة القديم
  }

  // 🔥 دالة حوار اختيار الثيم (شبيهة بدالة اللغة)
  void _showThemeDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final themeCubit = context.read<ThemeCubit>();
    final isDarkMode = themeCubit.state == ThemeMode.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 35),
          decoration: BoxDecoration(
            color: context.backgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(35)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 45,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              const SizedBox(height: 25),
              Container(
                height: 75,
                width: 75,
                decoration: BoxDecoration(
                  color: AppColors.primaryBtn.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.dark_mode_rounded,
                  size: 40,
                  color: AppColors.primaryBtn,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.theme,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.textColor,
                ),
              ),
              const SizedBox(height: 25),

              // خيار الوضع الفاتح
              _themeItem(
                context,
                title: "Light Mode",
                subtitle: "الوضع النهاري",
                icon: Icons.light_mode_outlined,
                selected: !isDarkMode,
                onTap: () {
                  themeCubit.toggleTheme(false);
                  Navigator.pop(context);
                },
              ),

              const SizedBox(height: 14),

              // خيار الوضع الليلي
              _themeItem(
                context,
                title: "Dark Mode",
                subtitle: "الوضع الليلي",
                icon: Icons.dark_mode_outlined,
                selected: isDarkMode,
                onTap: () {
                  themeCubit.toggleTheme(true);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _themeItem(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
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
              : Colors.grey.shade50.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.primaryBtn : Colors.grey.shade300,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              height: 55,
              width: 55,
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.primaryBtn
                    : Colors.grey.shade300.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: selected ? Colors.white : AppColors.primaryBtn,
                size: 26,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: context.textColor,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
            if (selected)
              Container(
                height: 28,
                width: 28,
                decoration: BoxDecoration(
                  color: AppColors.primaryBtn,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 18),
              ),
          ],
        ),
      ),
    );
  }
}
