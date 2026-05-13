import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:sportifo_app/core/helpers/app_image_picker.dart';
import 'package:sportifo_app/core/helpers/dialog_helper.dart';
import 'package:sportifo_app/core/routes/app_routes.dart';
import 'package:sportifo_app/features/auth/presentation/view_model/logout/logout_cubit.dart';
import 'package:sportifo_app/features/auth/presentation/widgets/custom_button.dart';
import 'package:sportifo_app/features/profile/presentation/widgets/logout_button.dart';
import 'package:sportifo_app/features/profile/presentation/view/edit_profile_page.dart';
import 'package:sportifo_app/features/profile/presentation/view_model/profile_cubit.dart';
import 'package:sportifo_app/features/profile/presentation/view_model/profile_state.dart';
import 'package:sportifo_app/features/profile/presentation/widgets/basic_info_section.dart';
import 'package:sportifo_app/features/profile/presentation/widgets/profile_tabs_section.dart';
import 'package:sportifo_app/features/profile/presentation/widgets/profile_top_section.dart';
import '../../../../core/theme/app_colors.dart';
import 'package:sportifo_app/l10n/app_localizations.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  File? selectedImage;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: NeumorphicAppBar(
        title: Text(
          l10n.profile,
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: NeumorphicButton(
          padding: const EdgeInsets.all(8),
          style: NeumorphicStyle(
            boxShape: NeumorphicBoxShape.circle(),
            color: AppColors.primaryBtn,
          ),
          onPressed: () {
            Navigator.pushReplacementNamed(context, AppRoutes.home);
          },
          child: const Icon(Icons.arrow_back, color: AppColors.textDark),
        ),
        color: AppColors.primaryBtn,
      ),

      body: BlocListener<LogoutCubit, LogoutState>(
        listener: (context, state) {
          if (state is LogoutSuccess) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.login,
              (route) => false,
            );
          }
        },
        child: BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, state) {
            if (state is ProfileLoading) {
              return Center(
                child: CircularProgressIndicator(color: AppColors.primaryBtn),
              );
            }

            if (state is ProfileError) {
              return Center(child: Text(state.message));
            }

            if (state is ProfileSuccess) {
              final user = state.profileModel;

              return RefreshIndicator(
                color: AppColors.primaryBtn,
                onRefresh: () async {
                  await context.read<ProfileCubit>().getProfile();
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      ProfileTopSection(
                        imageUrl: user.profilePic,
                        localImage: selectedImage,
                        firstName: user.firstName,
                        gender: user.gender,
                        onEditImage: () async {
                          final file =
                              await AppImagePicker.showImageSourceDialog(
                                context,
                              );
                          if (file != null) {
                            setState(() {
                              selectedImage = file;
                            });

                            context.read<ProfileCubit>().updateProfileImage(
                              file,
                            );
                          }
                        },
                      ),

                      Center(
                        child: Text(
                          "${user.firstName} ${user.lastName}",
                          style: TextStyle(fontSize: AppSizes.labelFontSize),
                        ),
                      ),
                      const SizedBox(height: 20),

                      ProfileTabsSection(profile: user),

                      const SizedBox(height: 230),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryBtn,
                                    elevation: 5,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        AppSizes.borderRadius,
                                      ),
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.pushNamed(
                                      context,
                                      AppRoutes.editProfile,
                                      arguments: user,
                                    );
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.edit, color: Colors.white),
                                      SizedBox(width: 8),
                                      Text(
                                        l10n.editProfile,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: LogoutButton(
                                text: l10n.logout,
                                onPressed: () {
                                  final cubit = context.read<LogoutCubit>();

                                  DialogHelper.showCustomDialog(
                                    context: context,
                                    title: l10n.logout,
                                    message: l10n.confirmLogout,
                                    type: DialogType.warning,
                                    confirmBtnText: l10n.logoutApproval,
                                    onConfirm: () {
                                      cubit.logout();
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }
}
