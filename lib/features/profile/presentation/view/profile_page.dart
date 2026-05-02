import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:sportifo_app/core/routes/app_routes.dart';
import 'package:sportifo_app/features/auth/presentation/widgets/custom_neumorphic_field.dart';
import 'package:sportifo_app/features/profile/presentation/view_model/profile_cubit.dart';
import 'package:sportifo_app/features/profile/presentation/view_model/profile_state.dart';
import 'package:sportifo_app/features/profile/presentation/widgets/basic_info_section.dart';
import 'package:sportifo_app/features/profile/presentation/widgets/measuremants_chips.dart';
import 'package:sportifo_app/features/profile/presentation/widgets/metric_card.dart';
import 'package:sportifo_app/features/profile/presentation/widgets/profile_header.dart';
import '../../../../core/theme/app_colors.dart';
import 'package:sportifo_app/l10n/app_localizations.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: NeumorphicAppBar(
        title: Text(
          "Profile",
          style: const TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: NeumorphicButton(
          padding: const EdgeInsets.all(8),
          style: NeumorphicStyle(
            boxShape: NeumorphicBoxShape.circle(),
            color: AppColors.background,
          ),
          onPressed: () {
            Navigator.pushReplacementNamed(context, AppRoutes.home);
          },
          child: const Icon(Icons.arrow_back, color: AppColors.textDark),
        ),
        color: AppColors.background,
      ),

      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoading) {
            return Center(
              child: CircularProgressIndicator(color: AppColors.primaryBtn),
            );
          } else if (state is ProfileSuccess) {
            final user = state.profileModel;

            return RefreshIndicator(
              color: AppColors.primaryBtn,
              onRefresh: () async {
                await context.read<ProfileCubit>().getProfile();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    ProfileHeader(
                      image: user.profilePic,
                      firstName: user.firstName,
                      lastName: user.lastName,
                      email: user.email,
                      gender: user.gender,
                    ),
                    const SizedBox(height: 20),
                    BasicInfoSection(
                      email: user.email,
                      phone: user.phone,
                      birth: user.dateOfBirth,
                    ),
                    const SizedBox(height: 25),

                    Row(
                      children: [
                        Expanded(
                          child: MetricCard(
                            title: "Height",
                            value: "${user.height ?? "-"} cm",
                            icon: Icons.height,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: MetricCard(
                            title: "Weight",
                            value: "${user.weight ?? "-"} kg",
                            icon: Icons.monitor_weight,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    MeasurementsChips(sizes: user.sizes),
                  ],
                ),
              ),
            );
          } else if (state is ProfileError) {
            return Center(child: Text(state.message));
          }
          return const SizedBox();
        },
      ),
    );
  }
}
