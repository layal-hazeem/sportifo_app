import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:sportifo_app/core/helpers/app_image_picker.dart';
import 'package:sportifo_app/core/theme/app_colors.dart';
import 'package:sportifo_app/core/widgets/wave_app_bar.dart';
import 'package:sportifo_app/features/auth/presentation/view/complete_body_measurements.dart';
import 'package:sportifo_app/features/auth/presentation/view_model/complete_profile/complete_profile_cubit.dart';
import 'package:sportifo_app/features/auth/presentation/widgets/custom_neumorphic_field.dart';
import 'package:sportifo_app/features/home/presentation/view/home_page.dart';
import 'package:sportifo_app/l10n/app_localizations.dart';

import '../../../../core/helpers/snack_bar_utils.dart';

class CompleteProfileInfoView extends StatelessWidget {
  const CompleteProfileInfoView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: WaveAppBar(
        title: l10n.completeProfileInfo,
        showBackButton: false,
      ),
      body: BlocConsumer<CompleteProfileCubit, CompleteProfileState>(
        listener: (context, state) {
          if (state.status == ProfileStatus.success) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => HomePage()),
            );
          }

          if (state.status == ProfileStatus.error) {
            AppSnackBar.show(
              context,
              message: state.errorMessage ?? l10n.unexpectedError,
              type: SnackBarType.error,
            );
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.mainPadding,
            ),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 80,
                        backgroundColor: AppColors.background,
                        backgroundImage: state.imagePath != null
                            ? FileImage(File(state.imagePath!))
                            : const AssetImage(
                                    "assets/images/default_avatar.jpg",
                                  )
                                  as ImageProvider,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: CircleAvatar(
                          backgroundColor: AppColors.primaryBtn,
                          child: IconButton(
                            icon: const Icon(
                              Icons.camera_alt,
                              color: AppColors.background,
                            ),
                            onPressed: () async {
                              final File? image =
                                  await AppImagePicker.pickImageFromGallery();
                              if (image != null) {
                                context.read<CompleteProfileCubit>().setImage(
                                  image.path,
                                );
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                if (state.status == ProfileStatus.loading)
                  Container(
                    color: Colors.black.withOpacity(0.3),
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                Row(
                  children: [
                    Expanded(
                      child: CustomNeumorphicField(
                        hint: "${l10n.weight} (${l10n.kg})",
                        iconPath: "assets/icons/weight.svg",
                        keyboardType: TextInputType.number,
                        onChanged: (val) {
                          final cubit = context.read<CompleteProfileCubit>();

                          cubit.setWeight(double.tryParse(val));
                        },
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: CustomNeumorphicField(
                        hint: "${l10n.height} (${l10n.cm})",
                        iconPath: "assets/icons/height.svg",
                        keyboardType: TextInputType.number,
                        onChanged: (val) {
                          context.read<CompleteProfileCubit>().setHeight(
                            double.tryParse(val),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                GestureDetector(
                  onTap: () async {
                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime(2000),
                      firstDate: DateTime(1950),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      context.read<CompleteProfileCubit>().setBirthDate(
                        "${picked.year}-${picked.month}-${picked.day}",
                      );
                    }
                  },
                  child: Neumorphic(
                    style: NeumorphicStyle(
                      depth: -5,
                      boxShape: NeumorphicBoxShape.roundRect(
                        BorderRadius.circular(AppSizes.borderRadius),
                      ),
                      color: AppColors.background,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 15,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            state.birthDate == null
                                ? l10n.birthDate
                                : state.birthDate!,
                            style: TextStyle(
                              color: state.birthDate == null
                                  ? AppColors.hintText
                                  : AppColors.textDark,
                            ),
                          ),
                          const Icon(
                            Icons.calendar_month,
                            color: AppColors.hintText,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                Row(
                  children: [
                    _buildGenderCard(
                      label: l10n.male,
                      icon: Icons.male,
                      isSelected: state.gender == true,
                      onTap: () =>
                          context.read<CompleteProfileCubit>().setGender(true),
                    ),
                    const SizedBox(width: 15),
                    _buildGenderCard(
                      label: l10n.female,
                      icon: Icons.female,
                      isSelected: state.gender == false,
                      onTap: () =>
                          context.read<CompleteProfileCubit>().setGender(false),
                    ),
                  ],
                ),

                const SizedBox(height: 40),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBtn,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: context.read<CompleteProfileCubit>(),
                        child: CompleteBodyMeasurementsView(),
                      ),
                    ),
                  ),
                  child: Text(
                    l10n.next,
                    style: TextStyle(color: AppColors.background),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildGenderCard({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Neumorphic(
          style: NeumorphicStyle(
            depth: isSelected ? -10 : 5,
            color: isSelected
                ? AppColors.primaryBtn.withOpacity(0.1)
                : AppColors.background,
            boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              children: [
                Icon(
                  icon,
                  color: isSelected ? AppColors.primaryBtn : Colors.grey,
                  size: 30,
                ),
                const SizedBox(height: 10),
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? AppColors.primaryBtn : Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
