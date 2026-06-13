import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:sportifo_app/core/helpers/app_image_picker.dart';
import 'package:sportifo_app/core/helpers/dialog_helper.dart';
import 'package:sportifo_app/core/routes/app_routes.dart';
import 'package:sportifo_app/features/auth/presentation/view_model/logout/logout_cubit.dart';
import 'package:sportifo_app/features/auth/presentation/widgets/custom_button.dart';
import 'package:sportifo_app/features/profile/presentation/widgets/coach_tabs_section.dart';
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
  void initState() {
    super.initState();

    final cubit = context.read<ProfileCubit>();
    cubit.getProfile();
  }

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

            if (state is ProfileFailure) {
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

                      ProfileTabsSection(userProfile: user, role: user.role!),

                      const SizedBox(height: 230),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Center(
                          child: SizedBox(
                            width: 220,
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

                              onPressed: () async {
                                final result = await Navigator.pushNamed(
                                  context,
                                  AppRoutes.editProfile,
                                  arguments: user,
                                );

                                if (result == true) {
                                  context.read<ProfileCubit>().getProfile();
                                }
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.edit, color: Colors.white),
                                  const SizedBox(width: 8),
                                  Text(
                                    l10n.editProfile,
                                    style: const TextStyle(
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
