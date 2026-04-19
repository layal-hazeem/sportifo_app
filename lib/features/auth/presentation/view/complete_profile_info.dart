import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:sportifo_app/core/theme/app_colors.dart';
import 'package:sportifo_app/features/auth/presentation/view/complete_body_measurements.dart';
import 'package:sportifo_app/features/auth/presentation/view_model/complete_profile_view_model.dart';
import 'package:sportifo_app/features/auth/presentation/widgets/custom_neumorphic_field.dart';
import 'package:sportifo_app/features/home/presentation/view/home_page.dart';
import 'package:sportifo_app/l10n/app_localizations.dart';

class CompleteProfileInfoView extends StatelessWidget {
  final CompleteProfileViewModel viewModel = CompleteProfileViewModel();

  CompleteProfileInfoView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.completeProfileInfo,
          style: TextStyle(fontSize: AppSizes.labelFontSize),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomePage()),
              );
            },
            child: Text(
              l10n.skip,
              style: TextStyle(
                color: AppColors.linkColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 10), // مسافة بسيطة عن حافة الشاشة
        ],
      ),
      body: ListenableBuilder(
        listenable: viewModel,
        builder: (context, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.mainPadding,
            ),
            child: Column(
              children: [
                const SizedBox(height: 60),
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: AppColors.background,
                        backgroundImage: viewModel.userImagePath != null
                            ? AssetImage(viewModel.userImagePath!)
                                  as ImageProvider
                            : null,
                        child: viewModel.userImagePath == null
                            ? const Icon(
                                Icons.person,
                                size: 60,
                                color: AppColors.hintText,
                              )
                            : null,
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
                            onPressed: () {
                              /* منطق اختيار صورة من الاستوديو */
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                Row(
                  children: [
                    Expanded(
                      child: CustomNeumorphicField(
                        hint: "${l10n.weight} (${l10n.kg})",
                        icon: Icons.monitor_weight_outlined,
                        keyboardType: TextInputType.number,
                        onChanged: (val) => viewModel.updateWeight(val),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: CustomNeumorphicField(
                        hint: "${l10n.length} (${l10n.cm})",
                        icon: Icons.height,
                        keyboardType: TextInputType.number,
                        onChanged: (val) => viewModel.updateHeight(val),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                GestureDetector(
                  onTap: () async {
                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(1950),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) viewModel.updateBirthDate(picked);
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
                            viewModel.birthDate == null
                                ? l10n.birthDate
                                : "${viewModel.birthDate!.day}/${viewModel.birthDate!.month}/${viewModel.birthDate!.year}",
                            style: TextStyle(
                              color: viewModel.birthDate == null
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
                Text(l10n.gender),
                Row(
                  children: [
                    _buildGenderCard(
                      label: l10n.male,
                      icon: Icons.male,
                      isSelected: viewModel.gender == 'male',
                      onTap: () => viewModel.updateGender('male'),
                    ),
                    const SizedBox(width: 15),
                    _buildGenderCard(
                      label: l10n.female,
                      icon: Icons.female,
                      isSelected: viewModel.gender == 'female',
                      onTap: () => viewModel.updateGender('female'),
                    ),
                  ],
                ),

                const SizedBox(height: 40),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBtn,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  onPressed: () {
                    if (viewModel.isDataComplete) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CompleteBodyMeasurementsView(
                            viewModel: viewModel,
                          ),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l10n.messageOfIncompleteInfo),
                          backgroundColor: Colors.red,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
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
