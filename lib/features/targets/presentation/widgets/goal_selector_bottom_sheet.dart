import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/theme/app_colors.dart';
import '../view_model/target_cubit/target_cubit.dart';
import '../view_model/target_cubit/target_state.dart';

class GoalSelectorBottomSheet extends StatefulWidget {
  const GoalSelectorBottomSheet({super.key});

  // 🔥 تعديل الدالة لتستقبل الكوبيت وتمرره بأمان للبوتوم شيت
  static void show(BuildContext context, TargetCubit targetCubit) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.1),
      builder: (_) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          // الـسحر هنا: حقن الكوبيت الحالي جّوا سياق البوتوم شيت المنفصل
          child: BlocProvider.value(
            value: targetCubit,
            child: const GoalSelectorBottomSheet(),
          ),
        );
      },
    );
  }

  // باقي الكود تَبَع الشيت بضل متل ما هو بالظبط بدون أي تغيير...
  @override
  State<GoalSelectorBottomSheet> createState() => _GoalSelectorBottomSheetState();
}


class _GoalSelectorBottomSheetState extends State<GoalSelectorBottomSheet> {
  // Default goal selected locally before submitting (bulk, cut, maintain)
  String _selectedGoal = 'bulk';

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return DraggableScrollableSheet(
      initialChildSize: 0.65, // Appropriate size to safely hold the 3 goal cards without clutter
      minChildSize: 0.4,
      maxChildSize: 0.85,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Stack(
            children: [
              // 🌌 1. Premium Glassmorphism Overlay (Copied from Ad structure layout)
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 17, sigmaY: 17),
                    child: Container(
                      color: Colors.black.withOpacity(0.13),
                    ),
                  ),
                ),
              ),

              // 📜 2. Main Sheet Content wrapped inside a scrollController list
              ListView(
                controller: scrollController,
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.zero,
                children: [
                  // Gray drag handle indicator
                  const SizedBox(height: 12),
                  Center(
                    child: Container(
                      width: 45,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),

                  // Header Sparkle Icon
                  const Center(
                    child: CircleAvatar(
                      radius: 35,
                      backgroundColor: Colors.white24,
                      child: Icon(Icons.bolt, color: AppColors.primaryBtn, size: 40),
                    ),
                  ),
                  const SizedBox(height: 25),

                  // ⬜ 3. White bottom content sheet displaying the selection cards
                  Container(
                    width: double.infinity,
                    constraints: BoxConstraints(minHeight: screenHeight * 0.5),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(35)),
                    ),
                    padding: const EdgeInsets.fromLTRB(24, 30, 24, 120), // Spacious padding to avoid fixed button overlapping
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Center(
                          child: Text(
                            "Select Your Fitness Goal ⚡",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Center(
                          child: Text(
                            "The system will automatically compute your tailored daily metrics",
                            style: TextStyle(fontSize: 13, color: Colors.grey.shade500, fontWeight: FontWeight.w500),
                          ),
                        ),
                        const SizedBox(height: 25),

                        // 🔥 Bulk Card
                        _buildGoalCard(
                          title: "Bulk / Gain Muscle",
                          subtitle: "Increase calorie targets systematically to optimize lean muscle growth",
                          icon: Icons.fitness_center,
                          goalValue: "bulk",
                        ),

                        // 🔥 Cut Card
                        _buildGoalCard(
                          title: "Cut / Lose Fat",
                          subtitle: "Decrease calorie targets to accelerate smart fat burn and increase definition",
                          icon: Icons.local_fire_department,
                          goalValue: "cut",
                        ),

                        // 🔥 Maintain Card
                        _buildGoalCard(
                          title: "Maintain / Stay Fit",
                          subtitle: "Stabilize current weight while steadily optimizing athletic stamina and recovery",
                          icon: Icons.scale,
                          goalValue: "maintain",
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // 🧡 4. Fixed bottom Action Button (Linked directly with TargetCubit)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(24, 15, 24, 30),
                  color: Colors.white,
                  child: ElevatedButton(
                    onPressed: () {
                      // Dispatches selected goal value to server
                      context.read<TargetCubit>().updateTargetGoal(_selectedGoal);
                      Navigator.pop(context); // Instantly dismiss panel
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBtn,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: const Text(
                      "Confirm & Compute Plan",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Internal component helper to construct clean animated row cards
  Widget _buildGoalCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required String goalValue,
  }) {
    bool isSelected = _selectedGoal == goalValue;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedGoal = goalValue; // Updates selection index locally
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryBtn.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primaryBtn : Colors.grey.shade200,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? AppColors.primaryBtn : Colors.grey.shade400, size: 28),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: isSelected ? AppColors.primaryBtn : AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 11, height: 1.3),
                  ),
                ],
              ),
            ),
            // Check indicator radio button icon wrapper
            Icon(
              isSelected ? Icons.check_circle : Icons.radio_button_off,
              color: isSelected ? AppColors.primaryBtn : Colors.grey.shade300,
            ),
          ],
        ),
      ),
    );
  }
}