import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:sportifo_app/core/theme/app_colors.dart';
import 'package:sportifo_app/features/auth/presentation/view_model/complete_profile_view_model.dart';
import 'package:sportifo_app/features/auth/presentation/widgets/custom_button.dart';
import 'package:sportifo_app/features/auth/presentation/widgets/custom_neumorphic_field.dart';
import 'package:sportifo_app/features/home/presentation/view/home_page.dart';
import 'package:sportifo_app/l10n/app_localizations.dart';

class CompleteBodyMeasurementsView extends StatelessWidget {
  final CompleteProfileViewModel viewModel;

  const CompleteBodyMeasurementsView({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: NeumorphicAppBar(
        title: Text(l10n.bodyMeasurements),
        actions: [
          Padding(
            padding: const EdgeInsets.all(0.0),
            child: TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const HomePage()),
                );
              },
              child: Text(
                l10n.skip,
                softWrap: false,
                maxLines: 1,
                style: TextStyle(color: AppColors.linkColor),
              ),
            ),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: viewModel,
        builder: (context, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Image.asset(
                    'assets/images/Fitness_tracker.jpg',
                    height: 300,
                    fit: BoxFit.contain,
                  ),
                ),
                Center(
                  child: Text(
                    l10n.measuermentsHint,
                    style: TextStyle(color: AppColors.hintText, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 20),

                _buildMeasurementRow(
                  label1: l10n.shoulders,
                  icon1: Icons.horizontal_rule,
                  onChanged1: (v) => viewModel.shoulders = double.tryParse(v),
                  label2: l10n.chestCircumference,
                  icon2: Icons.architecture,
                  onChanged2: (v) =>
                      viewModel.chestCircumference = double.tryParse(v),
                ),
                const SizedBox(height: 20),

                _buildMeasurementRow(
                  label1: l10n.belly,
                  icon1: Icons.straighten,
                  onChanged1: (v) => viewModel.belly = double.tryParse(v),
                  label2: l10n.hipCircumference,
                  icon2: Icons.accessibility_new,
                  onChanged2: (v) =>
                      viewModel.hipCircumference = double.tryParse(v),
                ),
                const SizedBox(height: 20),

                _buildMeasurementRow(
                  label1: l10n.thighCircumference,
                  icon1: Icons.boy_rounded,
                  onChanged1: (v) =>
                      viewModel.thighCircumference = double.tryParse(v),
                  label2: l10n.handCircumference,
                  icon2: Icons.front_hand_outlined,
                  onChanged2: (v) =>
                      viewModel.handCircumference = double.tryParse(v),
                ),

                const SizedBox(height: 20),

                CustomAuthButton(
                  text: viewModel.isLoading
                      ? l10n.saving
                      : l10n.startingTheSportsJourney,
                  onPressed: viewModel.isLoading
                      ? () {}
                      : () => viewModel.submitProfile(context),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMeasurementRow({
    required String label1,
    required IconData icon1,
    required Function(String) onChanged1,
    required String label2,
    required IconData icon2,
    required Function(String) onChanged2,
  }) {
    return Row(
      children: [
        Expanded(
          child: CustomNeumorphicField(
            hint: label1,
            icon: icon1,
            keyboardType: TextInputType.number,
            onChanged: onChanged1,
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: CustomNeumorphicField(
            hint: label2,
            icon: icon2,
            keyboardType: TextInputType.number,
            onChanged: onChanged2,
          ),
        ),
      ],
    );
  }
}
