import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:intl/intl.dart';
import 'package:sportifo_app/core/routes/app_routes.dart';
import 'package:sportifo_app/core/theme/app_colors.dart';
import 'package:sportifo_app/core/helpers/snack_bar_utils.dart';
import 'package:sportifo_app/features/auth/presentation/view_model/logout/logout_cubit.dart';
import 'package:sportifo_app/features/auth/presentation/widgets/custom_button.dart';
import 'package:sportifo_app/features/auth/presentation/widgets/custom_neumorphic_field.dart';
import 'package:sportifo_app/features/profile/data/models/edit_profile_request_model.dart';
import 'package:sportifo_app/features/profile/data/models/user_profile_response.dart';
import 'package:sportifo_app/features/profile/presentation/view_model/profile_cubit.dart';
import 'package:sportifo_app/features/profile/presentation/view_model/profile_state.dart';
import 'package:sportifo_app/l10n/app_localizations.dart';

class EditProfilePage extends StatefulWidget {
  final ProfileResponsModel profile;
  const EditProfilePage({super.key, required this.profile});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _dateOfBirthController;

  late TextEditingController _heightController;
  late TextEditingController _weightController;

  late TextEditingController _shouldersWidthController;
  late TextEditingController _chestPerimeterController;
  late TextEditingController _waistPerimeterController;
  late TextEditingController _thighPerimeterController;
  late TextEditingController _hipPerimeterController;
  late TextEditingController _armPerimeterController;
  int selectedTab = 0;

  @override
  void initState() {
    super.initState();

    _firstNameController = TextEditingController(
      text: widget.profile.firstName,
    );
    _lastNameController = TextEditingController(text: widget.profile.lastName);

    _dateOfBirthController = TextEditingController(
      text: widget.profile.dateOfBirth == null
          ? ''
          : DateFormat('yyyy-MM-dd').format(widget.profile.dateOfBirth!),
    );

    _heightController = TextEditingController(
      text: widget.profile.height?.toString() ?? '',
    );
    _weightController = TextEditingController(
      text: widget.profile.weight?.toString() ?? '',
    );

    final s = widget.profile.sizes;

    _shouldersWidthController = TextEditingController(
      text: s?.shouldersWidth?.toString() ?? '',
    );
    _chestPerimeterController = TextEditingController(
      text: s?.chestPerimeter?.toString() ?? '',
    );
    _waistPerimeterController = TextEditingController(
      text: s?.waistPerimeter?.toString() ?? '',
    );
    _thighPerimeterController = TextEditingController(
      text: s?.thighPerimeter?.toString() ?? '',
    );
    _hipPerimeterController = TextEditingController(
      text: s?.hipPerimeter?.toString() ?? '',
    );
    _armPerimeterController = TextEditingController(
      text: s?.armPerimeter?.toString() ?? '',
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: NeumorphicAppBar(
        title: Text(
          l10n.editProfile,
          style: TextStyle(color: AppColors.textDark),
        ),
        color: AppColors.background,
      ),
      body: BlocConsumer<ProfileCubit, ProfileState>(
        listener: (context, state) {
          if (state is ProfileSuccess) {
            AppSnackBar.show(
              context,
              message: "Profile updated successfully",
              type: SnackBarType.success,
            );
            Navigator.pop(context);
          }

          if (state is ProfileFailure) {
            AppSnackBar.show(
              context,
              message: state.message,
              type: SnackBarType.error,
            );
          }
        },

        builder: (context, state) {
          final isLoading = state is ProfileLoading;

          return Stack(
            children: [
              _buildPageContent(context, state),

              if (isLoading)
                Container(
                  color: Colors.black.withOpacity(0.2),
                  child: const Center(child: CircularProgressIndicator()),
                ),
            ],
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();

    _dateOfBirthController.dispose();

    _heightController.dispose();
    _weightController.dispose();

    _shouldersWidthController.dispose();
    _chestPerimeterController.dispose();
    _waistPerimeterController.dispose();
    _thighPerimeterController.dispose();
    _hipPerimeterController.dispose();
    _armPerimeterController.dispose();

    super.dispose();
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
            color: isSelected ? AppColors.primaryBtn : Colors.transparent,
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

  Widget _buildInfoTab(ProfileState state) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            buildField(
              l10n.firstName,
              l10n.firstName,
              Icons.person_outline,
              controller: _firstNameController,
            ),

            const SizedBox(height: 20),

            buildField(
              l10n.lastName,
              l10n.lastName,
              Icons.person_outline,
              controller: _lastNameController,
            ),

            const SizedBox(height: 20),

            GestureDetector(
              onTap: () async {
                final pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime(2000),
                  firstDate: DateTime(1950),
                  lastDate: DateTime.now(),
                );

                if (pickedDate != null) {
                  final formattedDate = DateFormat(
                    'yyyy-MM-dd',
                  ).format(pickedDate);

                  _dateOfBirthController.text = formattedDate;
                }
              },
              child: AbsorbPointer(
                child: buildField(
                  "Date of Birth",
                  "YYYY-MM-DD",
                  Icons.calendar_today_outlined,
                  controller: _dateOfBirthController,
                ),
              ),
            ),

            const Spacer(),

            CustomAuthButton(
              text: state is ProfileLoading ? "Saving..." : "Save Changes",
              onPressed: state is ProfileLoading
                  ? null
                  : () {
                      if (_formKey.currentState!.validate()) {
                        context.read<ProfileCubit>().updateProfile(
                          EditProfileRequestModel(
                            first_name: _firstNameController.text,
                            last_name: _lastNameController.text,
                            date_of_birth: _dateOfBirthController.text,
                            height: _heightController.text.isEmpty
                                ? null
                                : double.tryParse(_heightController.text),
                            weight: _weightController.text.isEmpty
                                ? null
                                : double.tryParse(_weightController.text),
                            shoulders_width: double.tryParse(
                              _shouldersWidthController.text,
                            ),
                            chest_perimeter: double.tryParse(
                              _chestPerimeterController.text,
                            ),
                            waist_perimeter: double.tryParse(
                              _waistPerimeterController.text,
                            ),
                            thigh_perimeter: double.tryParse(
                              _thighPerimeterController.text,
                            ),
                            hip_perimeter: double.tryParse(
                              _hipPerimeterController.text,
                            ),
                            arm_perimeter: double.tryParse(
                              _armPerimeterController.text,
                            ),
                          ),
                        );
                      }
                    },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMeasurementsTab(ProfileState state) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  buildField(
                    l10n.height,
                    l10n.height,
                    Icons.height,
                    keyboardType: TextInputType.number,
                    controller: _heightController,
                  ),

                  const SizedBox(height: 20),

                  buildField(
                    l10n.weight,
                    l10n.weight,
                    Icons.monitor_weight_outlined,
                    keyboardType: TextInputType.number,
                    controller: _weightController,
                  ),

                  const SizedBox(height: 40),

                  buildField(
                    l10n.shoulders,
                    l10n.shoulders,
                    Icons.accessibility_new,
                    keyboardType: TextInputType.number,
                    controller: _shouldersWidthController,
                  ),

                  const SizedBox(height: 20),

                  buildField(
                    l10n.chestCircumference,
                    l10n.chestCircumference,
                    Icons.fitness_center,
                    keyboardType: TextInputType.number,
                    controller: _chestPerimeterController,
                  ),

                  const SizedBox(height: 20),

                  buildField(
                    l10n.waist,
                    l10n.waist,
                    Icons.radio_button_unchecked,
                    keyboardType: TextInputType.number,
                    controller: _waistPerimeterController,
                  ),

                  const SizedBox(height: 20),

                  buildField(
                    l10n.thighCircumference,
                    l10n.thighCircumference,
                    Icons.accessibility,
                    keyboardType: TextInputType.number,
                    controller: _thighPerimeterController,
                  ),

                  const SizedBox(height: 20),

                  buildField(
                    l10n.hipCircumference,
                    l10n.hipCircumference,
                    Icons.self_improvement,
                    keyboardType: TextInputType.number,
                    controller: _hipPerimeterController,
                  ),

                  const SizedBox(height: 20),

                  buildField(
                    l10n.armCircumference,
                    l10n.armCircumference,
                    Icons.fitness_center,
                    keyboardType: TextInputType.number,
                    controller: _armPerimeterController,
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          CustomAuthButton(
            text: state is ProfileLoading ? "Saving..." : "Save Changes",
            onPressed: state is ProfileLoading
                ? null
                : () {
                    if (_formKey.currentState!.validate()) {
                      context.read<ProfileCubit>().updateProfile(
                        EditProfileRequestModel(
                          first_name: _firstNameController.text,
                          last_name: _lastNameController.text,
                          date_of_birth: _dateOfBirthController.text,
                          height: _heightController.text.isEmpty
                              ? null
                              : double.tryParse(_heightController.text),
                          weight: _weightController.text.isEmpty
                              ? null
                              : double.tryParse(_weightController.text),
                          shoulders_width: double.tryParse(
                            _shouldersWidthController.text,
                          ),
                          chest_perimeter: double.tryParse(
                            _chestPerimeterController.text,
                          ),
                          waist_perimeter: double.tryParse(
                            _waistPerimeterController.text,
                          ),
                          thigh_perimeter: double.tryParse(
                            _thighPerimeterController.text,
                          ),
                          hip_perimeter: double.tryParse(
                            _hipPerimeterController.text,
                          ),
                          arm_perimeter: double.tryParse(
                            _armPerimeterController.text,
                          ),
                        ),
                      );
                    }
                  },
          ),
        ],
      ),
    );
  }

  Widget _buildPageContent(BuildContext context, ProfileState state) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        // Tabs
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            children: [
              _tabButton(l10n.information, 0),
              _tabButton(l10n.bodyMeasurements, 1),
            ],
          ),
        ),

        // Content
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: selectedTab == 0
                ? _buildInfoTab(state)
                : _buildMeasurementsTab(state),
          ),
        ),
      ],
    );
  }

  Widget buildField(
    String label,
    String hint,
    IconData icon, {
    bool isPassword = false,
    TextInputType? keyboardType,
    required TextEditingController controller,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),

        const SizedBox(height: 10),

        CustomNeumorphicField(
          hint: hint,
          icon: icon,
          isPassword: isPassword,
          keyboardType: keyboardType,
          controller: controller,
          validator: validator,
        ),
      ],
    );
  }
}
