import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:sportifo_app/core/helpers/app_image_picker.dart';
import 'package:sportifo_app/core/routes/app_routes.dart';
import 'package:sportifo_app/features/auth/presentation/view_model/logout/logout_cubit.dart';
import 'package:sportifo_app/features/profile/presentation/view/profile_image_view.dart';
import 'package:sportifo_app/features/profile/presentation/view_model/profile_cubit.dart';
import 'package:sportifo_app/features/profile/presentation/view_model/profile_state.dart';
import 'package:sportifo_app/features/profile/presentation/widgets/profile_tabs_section.dart';
import 'package:sportifo_app/features/profile/presentation/widgets/profile_top_section.dart';
import '../../../../core/theme/app_colors.dart';
import 'package:sportifo_app/l10n/app_localizations.dart';
import 'package:sportifo_app/features/targets/presentation/view_model/target_cubit/target_cubit.dart';

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
                  await context.read<ProfileCubit>().getProfile(forceRefresh: true);                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      ProfileTopSection(
                        imageUrl: user.profilePic,
                        localImage: selectedImage,
                        firstName: user.firstName,
                        gender: user.gender,

                        onOpenImage: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ProfileImageView(
                                imageUrl: user.profilePic,
                                localImage: selectedImage != null
                                    ? FileImage(selectedImage!)
                                    : null,
                              ),
                            ),
                          );
                        },

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
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      ProfileTabsSection(userProfile: user, role: user.role!),
                    ],
                  ),
                ),
              );
            }
            return const SizedBox();
          },
        ),
      ),
      bottomNavigationBar: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          if (state is! ProfileSuccess) return const SizedBox();

          final user = state.profileModel;

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              child: SizedBox(
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBtn,
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

                    if (result == true && context.mounted) {
                      context.read<ProfileCubit>().getProfile();
                      context.read<TargetCubit>().fetchLatestTarget();
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
          );
        },
      ),
    );
  }
}
