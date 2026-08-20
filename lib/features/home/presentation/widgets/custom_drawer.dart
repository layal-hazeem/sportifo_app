import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:sportifo_app/core/enum/drawer_enum.dart';
import 'package:sportifo_app/core/helpers/dialog_helper.dart';
import 'package:sportifo_app/core/routes/app_routes.dart';
import 'package:sportifo_app/core/theme/app_colors.dart';
import 'package:sportifo_app/core/theme/app_theme_extensions.dart';
import 'package:sportifo_app/features/auth/presentation/view_model/logout/logout_cubit.dart';
import 'package:sportifo_app/features/home/presentation/view/home_page.dart';
import 'package:sportifo_app/features/profile/presentation/view_model/profile_cubit.dart';
import 'package:sportifo_app/features/profile/presentation/view_model/profile_state.dart';
import 'package:sportifo_app/l10n/app_localizations.dart';

class CustomDrawer extends StatelessWidget {
  final DrawerItem selectedItem;
  final Function(DrawerItem) onItemTap;

  const CustomDrawer({
    super.key,
    required this.selectedItem,
    required this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Drawer(
      backgroundColor: AppColors.primaryBtn,
      child: Stack(
        children: [
          Container(color: AppColors.primaryBtn),
          Positioned.fill(
            top: 120,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 80, 20, 20),
              decoration: BoxDecoration(
                color: context.backgroundColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(40),
                ),
              ),
              child: Column(
                children: [
                  BlocBuilder<ProfileCubit, ProfileState>(
                    builder: (context, state) {
                      if (state is ProfileSuccess) {
                        final user = state.profileModel;

                        return _buildUserInfo(
                          name: "${user.firstName} ${user.lastName}",
                          email: user.email ?? "",
                          imageUrl: user.profilePic,
                          context: context,
                        );
                      }

                      return const Center(child: CircularProgressIndicator());
                    },
                  ),
                  const SizedBox(height: 20),

                  _buildItem(
                    icon: Icons.person_outline,
                    text: l10n.profile,
                    item: DrawerItem.profile,
                    context: context,
                  ),
                  _buildItem(
                    icon: Icons.bookmark_border,
                    text: l10n.saved_exercises,
                    item: DrawerItem.saved,
                    context: context,
                  ),
                  _buildItem(
                    icon: Icons.settings,
                    text: l10n.settings,
                    item: DrawerItem.settings,
                    context: context,
                  ),
                  _buildItem(
                    icon: Icons.info_outline,
                    text: l10n.aboutUs,
                    item: DrawerItem.about,
                    context: context,
                  ),

                  const Spacer(),

                  _buildItem(
                    icon: Icons.logout,
                    text: l10n.logout,
                    item: DrawerItem.logout,
                    context: context,
                  ),
                ],
              ),
            ),
          ),

          // الصورة + الدائرة
          Positioned(
            top: 70,
            left: 0,
            right: 0,
            child: Center(
              child: Stack(
                children: [
                  Neumorphic(
                    style: NeumorphicStyle(
                      depth: 6,
                      boxShape: const NeumorphicBoxShape.circle(),
                      color: context.backgroundColor,
                    ),
                    child: BlocBuilder<ProfileCubit, ProfileState>(
                      builder: (context, state) {
                        ImageProvider? imageProvider;
                        int age = 0;

                        if (state is ProfileSuccess) {
                          final user = state.profileModel;

                          age = calculateAge(user.dateOfBirth);

                          if (user.profilePic != null &&
                              user.profilePic!.isNotEmpty) {
                            imageProvider = NetworkImage(user.profilePic!);
                          } else {
                            imageProvider = AssetImage(
                              user.gender == false
                                  ? "assets/images/female.jpg"
                                  : "assets/images/male.jpg",
                            );
                          }
                        }

                        return SizedBox(
                          width: 110,
                          height: 110,
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Center(
                                child: CircleAvatar(
                                  radius: 45,
                                  backgroundImage: imageProvider,
                                  onBackgroundImageError: (_, _) {},
                                  child: imageProvider == null
                                      ? const Icon(Icons.person, size: 40)
                                      : null,
                                ),
                              ),

                              Positioned(
                                right: 8,
                                bottom: 8,
                                child: Container(
                                  padding: const EdgeInsets.all(7),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryBtn,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                  ),
                                  child: Text(
                                    "$age",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfo({
    required String name,
    required String email,
    String? imageUrl,
    required BuildContext context,
  }) {
    return Column(
      children: [
        Text(
          name,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 5),

        Text(email, style: TextStyle(color: context.textColor)),
      ],
    );
  }

  Widget _buildItem({
    required IconData icon,
    required String text,
    required DrawerItem item,
    required BuildContext context,
  }) {
    final isSelected = homeViewModel.currentIndex == item;

    final backgroundColor = context.backgroundColor;

    final iconColor = item == DrawerItem.logout
        ? Colors.red
        : AppColors.primaryBtn;

    final textColor = item == DrawerItem.logout
        ? Colors.red
        : context.textColor;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: NeumorphicButton(
        onPressed: () {
          onItemTap(item);
          Navigator.pop(context);
          _navigateToPage(context, item);
        },
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        style: NeumorphicStyle(
          depth: isSelected ? 2 : -2,
          intensity: 0.4,
          boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(18)),
          color: backgroundColor,
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 23),

            const SizedBox(width: 16),

            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  color: textColor,
                ),
              ),
            ),

            Icon(
              Icons.arrow_forward_ios,
              size: 17,
              color: item == DrawerItem.logout
                  ? Colors.red
                  : context.textColor.withOpacity(.45),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToPage(BuildContext context, DrawerItem item) {
    switch (item) {
      case DrawerItem.profile:
        Navigator.pushNamed(context, AppRoutes.getProfile);
        break;

      case DrawerItem.saved:
        Navigator.pushNamed(context, AppRoutes.savedExercises);
        break;

      case DrawerItem.settings:
        Navigator.pushNamed(context, AppRoutes.settings);
        break;

      case DrawerItem.about:
        Navigator.pushNamed(context, AppRoutes.aboutUs); // 👈 توجيه إلى حول التطبيق
        break;
      case DrawerItem.logout:
        final logoutCubit = context.read<LogoutCubit>();
        final l10n = AppLocalizations.of(context)!;

        DialogHelper.showCustomDialog(
          context: context,
          title: l10n.logout,
          message: l10n.confirmLogout,
          type: DialogType.warning,
          confirmBtnText: l10n.logout,
          onConfirm: () => logoutCubit.logout(),
        );
        break;
    }
  }

  int calculateAge(DateTime birthDate) {
    final today = DateTime.now();

    int age = today.year - birthDate.year;

    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }

    return age;
  }
}
