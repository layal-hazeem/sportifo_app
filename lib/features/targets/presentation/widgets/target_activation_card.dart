import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sportifo_app/core/theme/app_theme_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../view_model/target_cubit/target_cubit.dart';
import 'goal_selector_bottom_sheet.dart';
// 🔥 أضفنا استدعاءات البروفايل هنا لحتى نقدر نقرأ الوزن
import '../../../profile/presentation/view_model/profile_cubit.dart';
import '../../../profile/presentation/view_model/profile_state.dart';

class TargetActivationCard extends StatelessWidget {
  const TargetActivationCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 25,
                backgroundColor: Color(0xFFFFF5EC),
                child: Icon(Icons.bolt, color: AppColors.primaryBtn, size: 30),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Activate Your Smart Plan ",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: context.textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Set your main physical target now to dynamically evaluate your necessary daily calories and macronutrients.",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                        height: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            height: 45,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBtn,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              onPressed: () {
                // 🔥 التعديل السحري هنا: جلبنا الوزن من البروفايل قبل فتح الشيت
                final profileState = context.read<ProfileCubit>().state;
                double? userWeight;
                if (profileState is ProfileSuccess) {
                  userWeight = profileState
                      .profileModel
                      .weight; // تأكد من اسم المتغير في موديلك
                }

                GoalSelectorBottomSheet.show(
                  context,
                  context.read<TargetCubit>(),
                  currentWeight: userWeight, // 🔥 مررنا الوزن هنا!
                );
              },
              child: const Text(
                "Set My Goal Now",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
