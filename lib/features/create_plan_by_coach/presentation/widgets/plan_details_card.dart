import 'package:flutter/material.dart';
import 'package:sportifo_app/core/theme/app_colors.dart';
import 'package:sportifo_app/core/theme/app_theme_extensions.dart';
import 'package:sportifo_app/l10n/app_localizations.dart';

class PlanDetailsCard extends StatelessWidget {
  final String? selectedGoal;
  final int durationMonths;

  final ValueChanged<String> onGoalChanged;
  final ValueChanged<int> onDurationChanged;

  const PlanDetailsCard({
    super.key,
    required this.selectedGoal,
    required this.durationMonths,
    required this.onGoalChanged,
    required this.onDurationChanged,
  });

  static const List<_GoalOption> _goals = [
    _GoalOption(value: 'cut', icon: Icons.local_fire_department_rounded),
    _GoalOption(value: 'bulk', icon: Icons.fitness_center_rounded),
    _GoalOption(value: 'maintain', icon: Icons.balance_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBtn.withOpacity(.10),
            blurRadius: 30,
            spreadRadius: -6,
            offset: const Offset(0, 14),
          ),
          BoxShadow(
            color: AppColors.hintText,
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [context.backgroundColor, context.backgroundColor],
            ),
            border: Border.all(color: context.backgroundColor, width: 1),
          ),
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildGoalSection(context),
              const SizedBox(height: 15),
              _buildDivider(context),
              const SizedBox(height: 20),
              _buildDurationSection(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGoalSection(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
          icon: Icons.track_changes_rounded,
          title: l10n.mainGoalQuestion,
        ),

        const SizedBox(height: 16),

        Column(
          children: _goals.map((goal) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: SizedBox(
                width: double.infinity,
                child: _GoalCard(
                  option: goal,
                  title: _getGoalTitle(l10n, goal.value),
                  subtitle: _getGoalSubtitle(l10n, goal.value),
                  selected: selectedGoal == goal.value,
                  onTap: () => onGoalChanged(goal.value),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  String _getGoalTitle(AppLocalizations l10n, String value) {
    switch (value) {
      case 'cut':
        return l10n.cutGoal;

      case 'bulk':
        return l10n.bulkGoal;

      case 'maintain':
        return l10n.maintainGoal;

      default:
        return value;
    }
  }

  String _getGoalSubtitle(AppLocalizations l10n, String value) {
    switch (value) {
      case 'cut':
        return l10n.cutGoalSubtitle;

      case 'bulk':
        return l10n.bulkGoalSubtitle;

      case 'maintain':
        return l10n.maintainGoalSubtitle;

      default:
        return '';
    }
  }

  Widget _buildDurationSection(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
          icon: Icons.calendar_month_rounded,
          title: l10n.duration,
        ),

        const SizedBox(height: 15),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primaryBtn.withOpacity(.07),
                AppColors.primaryBtn.withOpacity(.02),
              ],
            ),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.primaryBtn.withOpacity(.14)),
          ),
          child: Row(
            children: [
              _buildStepperButton(
                icon: Icons.remove_rounded,
                enabled: durationMonths > 1,
                onTap: () {
                  if (durationMonths > 1) {
                    onDurationChanged(durationMonths - 1);
                  }
                },
                context: context,
              ),

              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: ScaleTransition(
                        scale: Tween<double>(
                          begin: .9,
                          end: 1,
                        ).animate(animation),
                        child: child,
                      ),
                    );
                  },
                  child: Column(
                    key: ValueKey(durationMonths),
                    children: [
                      ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          colors: [
                            AppColors.primaryBtn,
                            AppColors.primaryBtn.withOpacity(.7),
                          ],
                        ).createShader(bounds),
                        child: Text(
                          '$durationMonths',
                          style: TextStyle(
                            color: context.textColor,
                            fontSize: 30,
                            fontWeight: FontWeight.w900,
                            height: 1,
                          ),
                        ),
                      ),

                      const SizedBox(height: 3),

                      Text(
                        durationMonths == 1
                            ? l10n.month.toUpperCase()
                            : l10n.months.toUpperCase(),
                        style: TextStyle(
                          color: context.textColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              _buildStepperButton(
                icon: Icons.add_rounded,
                enabled: durationMonths < 12,
                onTap: () {
                  if (durationMonths < 12) {
                    onDurationChanged(durationMonths + 1);
                  }
                },
                context: context,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStepperButton({
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
    required BuildContext context,
  }) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 150),
      opacity: enabled ? 1.0 : 0.45,
      child: Material(
        color: context.backgroundColor,
        borderRadius: BorderRadius.circular(16),
        elevation: enabled ? 3 : 0,
        shadowColor: AppColors.primaryBtn.withOpacity(0.18),
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(16),
          splashColor: AppColors.primaryBtn.withOpacity(0.10),
          highlightColor: AppColors.primaryBtn.withOpacity(0.05),
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: enabled
                  ? AppColors.primaryBtn.withOpacity(0.08)
                  : context.backgroundColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: enabled
                    ? AppColors.primaryBtn.withOpacity(0.35)
                    : AppColors.hintText.withOpacity(0.35),
                width: 1.2,
              ),
            ),
            child: Icon(
              icon,
              size: 22,
              color: enabled ? AppColors.primaryBtn : AppColors.hintText,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle({required IconData icon, required String title}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.primaryBtn.withOpacity(.10),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(icon, size: 16, color: AppColors.primaryBtn),
        ),

        const SizedBox(width: 10),

        Text(
          title,
          style: const TextStyle(
            fontSize: 15.5,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Container(
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            context.textColor.withOpacity(0),
            context.textColor,
            context.textColor.withOpacity(0),
          ],
        ),
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  final _GoalOption option;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _GoalCard({
    required this.option,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            gradient: selected
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primaryBtn.withOpacity(.12),
                      AppColors.primaryBtn.withOpacity(.03),
                    ],
                  )
                : null,
            color: selected ? null : context.backgroundColor,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: selected
                  ? AppColors.primaryBtn.withOpacity(.55)
                  : context.backgroundColor,
              width: selected ? 1.3 : 1,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: AppColors.primaryBtn.withOpacity(.14),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ]
                : [],
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  gradient: selected
                      ? LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.primaryBtn,
                            AppColors.primaryBtn.withOpacity(.75),
                          ],
                        )
                      : null,
                  color: selected ? null : context.backgroundColor,
                  borderRadius: BorderRadius.circular(12),
                  border: selected
                      ? null
                      : Border.all(color: AppColors.primaryBtn),
                ),
                child: Icon(
                  option.icon,
                  size: 18,
                  color: selected ? Colors.white : AppColors.primaryBtn,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.1,
                        color: selected
                            ? AppColors.primaryBtn
                            : context.textColor,
                      ),
                    ),

                    const SizedBox(height: 2),

                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 11.5,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              AnimatedScale(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutBack,
                scale: selected ? 1 : 0,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: AppColors.primaryBtn,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    size: 12,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GoalOption {
  final String value;
  final IconData icon;

  const _GoalOption({required this.value, required this.icon});
}
