import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sportifo_app/core/theme/app_theme_extensions.dart';
import 'package:sportifo_app/features/nutrition/presentation/view/food_logs_screen.dart';
import 'package:sportifo_app/features/nutrition/presentation/view/manual_meal_entry_screen.dart';
import 'package:sportifo_app/features/targets/data/models/target_model.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../profile/presentation/view_model/profile_cubit.dart';
import '../../../profile/presentation/view_model/profile_state.dart';
import '../view_model/target_cubit/target_cubit.dart';
import 'goal_selector_bottom_sheet.dart';
import '../../../nutrition/data/models/food_log_model.dart';

class DailyNutritionCard extends StatelessWidget {
  final TargetModel target;
  final TotalMacros? consumedToday;

  const DailyNutritionCard({
    super.key,
    required this.target,
    this.consumedToday,
  });

  @override
  Widget build(BuildContext context) {
    // 🔥 حساب النسب الخام (قد تتجاوز 1.0) والمرئية (مقصورة عند 1.0)
    final double caloriesRaw = target.calories > 0
        ? ((consumedToday?.calories ?? 0) / target.calories).toDouble()
        : 0.0;
    final double caloriesVisual = caloriesRaw.clamp(0.0, 1.0);
    final bool caloriesExceeded = caloriesRaw > 1.0;

    final double proteinRaw = target.protein > 0
        ? ((consumedToday?.protein ?? 0) / target.protein).toDouble()
        : 0.0;
    final double proteinVisual = proteinRaw.clamp(0.0, 1.0);
    final bool proteinExceeded = proteinRaw > 1.0;

    final double carbsRaw = target.carbs > 0
        ? ((consumedToday?.carbs ?? 0) / target.carbs).toDouble()
        : 0.0;
    final double carbsVisual = carbsRaw.clamp(0.0, 1.0);
    final bool carbsExceeded = carbsRaw > 1.0;

    final double fatRaw = target.fat > 0
        ? ((consumedToday?.fat ?? 0) / target.fat).toDouble()
        : 0.0;
    final double fatVisual = fatRaw.clamp(0.0, 1.0);
    final bool fatExceeded = fatRaw > 1.0;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (_, animation, __) => const FoodLogsScreen(),
            transitionsBuilder: (_, animation, __, child) {
              const begin = Offset(0.0, 0.25);
              const end = Offset.zero;
              final tween = Tween(
                begin: begin,
                end: end,
              ).chain(CurveTween(curve: Curves.easeOutCubic));
              return SlideTransition(
                position: animation.drive(tween),
                child: FadeTransition(opacity: animation, child: child),
              );
            },
            transitionDuration: const Duration(milliseconds: 350),
          ),
        );
      },
      child: Container(
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
                Text(
                  "Daily Nutrition Targets",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: context.textColor,
                  ),
                ),
                Row(
                  children: [
                    // 🔥 زر الزائد
                    InkWell(
                      borderRadius: BorderRadius.circular(50),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ManualMealEntryScreen(),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBtn.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.add,
                          size: 16,
                          color: AppColors.primaryBtn,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBtn.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        target.goal.toUpperCase(),
                        style: const TextStyle(
                          color: AppColors.primaryBtn,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      borderRadius: BorderRadius.circular(50),
                      onTap: () {
                        final profileState = context.read<ProfileCubit>().state;
                        double? userWeight;
                        if (profileState is ProfileSuccess) {
                          userWeight = profileState.profileModel.weight;
                        }
                        GoalSelectorBottomSheet.show(
                          context,
                          context.read<TargetCubit>(),
                          initialGoal: target.goal,
                          currentWeight: userWeight,
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
                // 🔥 الدائرة: نسبة حقيقية + لون تنبيهي عند التجاوز
                Column(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 90,
                          height: 90,
                          child: CircularProgressIndicator(
                            value: caloriesVisual,
                            strokeWidth: 8,
                            backgroundColor: Colors.grey.shade100,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              caloriesExceeded
                                  ? Colors.red
                                  : AppColors.primaryBtn,
                            ),
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "${consumedToday?.calories ?? 0}",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: context.textColor,
                              ),
                            ),
                            Text(
                              "Kcal",
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // 🔥 عرض النسبة المئوية الحقيقية (قد تتجاوز 100%)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: caloriesExceeded
                            ? Colors.red.withOpacity(0.1)
                            : AppColors.primaryBtn.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "${(caloriesRaw * 100).toInt()}%"
                        "${caloriesExceeded ? ' ' : ''}",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: caloriesExceeded
                              ? Colors.red
                              : AppColors.primaryBtn,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 25),
                // 🔥 البارات: نسب حقيقية + لون تنبيهي عند التجاوز
                Expanded(
                  child: Column(
                    children: [
                      _buildMacroRow(
                        "Protein",
                        "${consumedToday?.protein ?? 0} / ${target.protein}g",
                        proteinVisual,
                        proteinExceeded ? Colors.red : Colors.orange,
                        proteinExceeded,
                      ),
                      const SizedBox(height: 10),
                      _buildMacroRow(
                        "Carbs",
                        "${consumedToday?.carbs ?? 0} / ${target.carbs}g",
                        carbsVisual,
                        carbsExceeded ? Colors.red : const Color(0xFFFF9F43),
                        carbsExceeded,
                      ),
                      const SizedBox(height: 10),
                      _buildMacroRow(
                        "Fat",
                        "${consumedToday?.fat ?? 0} / ${target.fat}g",
                        fatVisual,
                        fatExceeded ? Colors.red : Colors.blueGrey.shade300,
                        fatExceeded,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroRow(
    String title,
    String value,
    double percentVisual,
    Color color,
    bool exceeded,
  ) {
    return Row(
      children: [
        SizedBox(
          width: 55,
          child: Text(
            title,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: percentVisual,
              minHeight: 6,
              backgroundColor: Colors.grey.shade100,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          exceeded ? "$value" : value,
          style: TextStyle(
            fontSize: 12,
            color: exceeded ? Colors.red : Colors.grey.shade600,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
