import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sportifo_app/features/targets/data/models/target_model.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../profile/presentation/view_model/profile_cubit.dart';
import '../../../profile/presentation/view_model/profile_state.dart';
import '../view_model/target_cubit/target_cubit.dart'; // 🔥 أضفنا الـ Import للكوبيت
import 'goal_selector_bottom_sheet.dart'; // 🔥 أضفنا الـ Import للبوتوم شيت

class DailyNutritionCard extends StatelessWidget {
  final TargetModel target;

  const DailyNutritionCard({super.key, required this.target});

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Daily Nutrition Targets",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark),
              ),

              // 🔥 جمعنا التاغ مع زر القلم جّوا Row واحد أنيق
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBtn.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      target.goal.toUpperCase(),
                      style: const TextStyle(color: AppColors.primaryBtn, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // 🔥 أيقونة القلم لتعديل الهدف الحالي بكبسة واحدة فخمة
                  InkWell(
                    borderRadius: BorderRadius.circular(50),
                    // جّوا زر القلم في ملف daily_nutrition_card.dart:
                    onTap: () {
    // 🔥 لقطة برمجية ذكية: بنجيب وزن اليوزر الحالي المخزن بـ ProfileCubit
    final profileState = context.read<ProfileCubit>().state;
    double? userWeight;

    if (profileState is ProfileSuccess) {
    userWeight = profileState.profileModel.weight; // لقطنا الوزن من الموديل تَبَعِك بالظبط!
    }

    // مناداة البوتوم شيت وتمرير الوزن الحقيقي الطازج
    GoalSelectorBottomSheet.show(
    context,
    context.read<TargetCubit>(),
    initialGoal: target.goal,
    currentWeight: userWeight, // طلقة جّوا الجبهة! 🚀
    );
    },

                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.edit_rounded,
                        size: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              // Left Section: Calories Progress Ring
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 90,
                    height: 90,
                    child: CircularProgressIndicator(
                      value: 0.0,
                      strokeWidth: 8,
                      backgroundColor: Colors.grey.shade100,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryBtn),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "${target.calories}",
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark),
                      ),
                      Text(
                        "Kcal",
                        style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(width: 25),
              // Right Section: Macronutrients Progress Bars
              Expanded(
                child: Column(
                  children: [
                    _buildMacroRow("Protein", "${target.protein}g", 0.4, Colors.orange),
                    const SizedBox(height: 10),
                    _buildMacroRow("Carbs", "${target.carbs}g", 0.6, const Color(0xFFFF9F43)),
                    const SizedBox(height: 10),
                    _buildMacroRow("Fat", "${target.fat}g", 0.3, Colors.blueGrey.shade300),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMacroRow(String title, String value, double percent, Color color) {
    return Row(
      children: [
        SizedBox(width: 55, child: Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: percent,
              minHeight: 6,
              backgroundColor: Colors.grey.shade100,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(value, style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.bold)),
      ],
    );
  }
}