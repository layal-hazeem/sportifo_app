import 'package:flutter/material.dart';
import 'package:sportifo_app/core/theme/app_colors.dart';

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
    _GoalOption(
      value: 'cut',
      title: 'Cut',
      subtitle: 'Lose fat',
      icon: Icons.local_fire_department_rounded,
    ),
    _GoalOption(
      value: 'bulk',
      title: 'Bulk',
      subtitle: 'Build muscle',
      icon: Icons.fitness_center_rounded,
    ),
    _GoalOption(
      value: 'maintain',
      title: 'Maintain',
      subtitle: 'Stay balanced',
      icon: Icons.balance_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 18, 16, 10),
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
            color: Colors.black.withOpacity(.04),
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
              colors: [Colors.white, Colors.grey.shade50],
            ),
            border: Border.all(color: Colors.white, width: 1),
          ),
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 16),
              _buildGoalSection(),
              const SizedBox(height: 20),
              _buildDivider(),
              const SizedBox(height: 20),
              _buildDurationSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primaryBtn,
                AppColors.primaryBtn.withOpacity(.75),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryBtn.withOpacity(.35),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Icon(
            Icons.auto_awesome_rounded,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(width: 14),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'BUILD YOUR PLAN',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.6,
                ),
              ),
              SizedBox(height: 5),
              Text(
                'Create a personalized workout journey',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGoalSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
          icon: Icons.track_changes_rounded,
          title: "What's the main goal?",
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final itemWidth = (constraints.maxWidth - 12) / 2;
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _goals.map((goal) {
                return SizedBox(
                  width: itemWidth,
                  child: _GoalCard(
                    option: goal,
                    selected: selectedGoal == goal.value,
                    onTap: () => onGoalChanged(goal.value),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildDurationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
          icon: Icons.calendar_month_rounded,
          title: 'Plan duration',
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
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.w900,
                            height: 1,
                          ),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        durationMonths == 1 ? 'MONTH' : 'MONTHS',
                        style: TextStyle(
                          color: Colors.grey.shade600,
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
  }) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 150),
      opacity: enabled ? 1 : .3,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        elevation: enabled ? 3 : 0,
        shadowColor: AppColors.primaryBtn.withOpacity(.25),
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Icon(icon, size: 22, color: AppColors.primaryBtn),
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

  Widget _buildDivider() {
    return Container(
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.grey.shade200.withOpacity(0),
            Colors.grey.shade300,
            Colors.grey.shade200.withOpacity(0),
          ],
        ),
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  final _GoalOption option;
  final bool selected;
  final VoidCallback onTap;

  const _GoalCard({
    required this.option,
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
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
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
            color: selected ? null : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected
                  ? AppColors.primaryBtn.withOpacity(.55)
                  : Colors.grey.shade200,
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
                width: 32,
                height: 32,
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
                  color: selected ? null : Colors.white,
                  borderRadius: BorderRadius.circular(11),
                  border: selected
                      ? null
                      : Border.all(color: Colors.grey.shade200),
                ),
                child: Icon(
                  option.icon,
                  size: 16,
                  color: selected ? Colors.white : Colors.grey.shade600,
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      option.title,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.1,
                        color: selected ? AppColors.primaryBtn : Colors.black87,
                      ),
                    ),
                    Text(
                      option.subtitle,
                      style: TextStyle(
                        fontSize: 10.5,
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
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: AppColors.primaryBtn,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    size: 11,
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
  final String title;
  final String subtitle;
  final IconData icon;

  const _GoalOption({
    required this.value,
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}
