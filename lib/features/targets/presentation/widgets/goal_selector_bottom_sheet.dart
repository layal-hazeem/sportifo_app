import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sportifo_app/core/theme/app_theme_extensions.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../../l10n/app_localizations.dart'; // 🔥 استدعاء الترجمة
import '../view_model/target_cubit/target_cubit.dart';

class GoalSelectorBottomSheet extends StatefulWidget {
  final String? initialGoal;
  final double? currentWeight;

  const GoalSelectorBottomSheet({
    super.key,
    this.initialGoal,
    this.currentWeight,
  });

  static void show(
      BuildContext context,
      TargetCubit targetCubit, {
        String? initialGoal,
        double? currentWeight,
      }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.1),
      builder: (_) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: BlocProvider.value(
            value: targetCubit,
            child: GoalSelectorBottomSheet(
              initialGoal: initialGoal,
              currentWeight: currentWeight,
            ),
          ),
        );
      },
    );
  }

  @override
  State<GoalSelectorBottomSheet> createState() =>
      _GoalSelectorBottomSheetState();
}

class _GoalSelectorBottomSheetState extends State<GoalSelectorBottomSheet> {
  late String _selectedGoal;

  @override
  void initState() {
    super.initState();
    _selectedGoal = widget.initialGoal?.toLowerCase() ?? 'bulk';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenHeight = MediaQuery.of(context).size.height;

    return DraggableScrollableSheet(
      initialChildSize: 0.65,
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
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(30),
                  ),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 17, sigmaY: 17),
                    child: Container(color: Colors.black.withOpacity(0.13)),
                  ),
                ),
              ),

              ListView(
                controller: scrollController,
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.zero,
                children: [
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

                  const Center(
                    child: CircleAvatar(
                      radius: 35,
                      backgroundColor: Colors.white24,
                      child: Icon(
                        Icons.bolt,
                        color: AppColors.primaryBtn,
                        size: 40,
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),

                  Container(
                    width: double.infinity,
                    constraints: BoxConstraints(minHeight: screenHeight * 0.5),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(35),
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(24, 30, 24, 120),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "${l10n.currentWeight} ${widget.currentWeight ?? 0.0} ${l10n.kg}", // 🔥 ترجمة الوزن
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.grey,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.getProfile,
                                );
                              },
                              child: Text(
                                l10n.change, // 🔥 ترجمة تغيير
                                style: const TextStyle(
                                  color: AppColors.primaryBtn,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 10, thickness: 0.5),
                        const SizedBox(height: 15),

                        Center(
                          child: Text(
                            l10n.selectFitnessGoal, // 🔥 ترجمة العنوان
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: context.textColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Center(
                          child: Text(
                            l10n.goalSubtitle,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade500,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(height: 25),

                        _buildGoalCard(
                          title: l10n.bulkTitle,
                          subtitle: l10n.bulkSubtitle,
                          icon: Icons.fitness_center,
                          goalValue: "bulk",
                          context: context,
                        ),

                        _buildGoalCard(
                          title: l10n.cutTitle,
                          subtitle: l10n.cutSubtitle,
                          icon: Icons.local_fire_department,
                          goalValue: "cut",
                          context: context,
                        ),

                        _buildGoalCard(
                          title: l10n.maintainTitle,
                          subtitle: l10n.maintainSubtitle,
                          icon: Icons.scale,
                          goalValue: "maintain",
                          context: context,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(24, 15, 24, 30),
                  color: Colors.white,
                  child: ElevatedButton(
                    onPressed: () {
                      context.read<TargetCubit>().updateTargetGoal(
                        _selectedGoal,
                      );
                      Navigator.pop(context);
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
                    child: Text(
                      l10n.confirmAndComputePlan,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
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

  Widget _buildGoalCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required String goalValue,
    required BuildContext context,
  }) {
    bool isSelected = _selectedGoal == goalValue;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedGoal = goalValue;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryBtn.withOpacity(0.05)
              : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primaryBtn : Colors.grey.shade200,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primaryBtn : Colors.grey.shade400,
              size: 28,
            ),
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
                      color: isSelected
                          ? AppColors.primaryBtn
                          : context.textColor,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 11,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
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