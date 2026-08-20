import 'package:flutter/material.dart';
import 'package:sportifo_app/core/theme/app_colors.dart';
import 'package:sportifo_app/core/theme/app_theme_extensions.dart';
import 'package:sportifo_app/features/trainees/data/models/coach_plan_model.dart';
import 'package:sportifo_app/l10n/app_localizations.dart';

class TraineeCardHorizontal extends StatefulWidget {
  final CoachPlanModel plan;
  final VoidCallback onTap;
  final int index;

  const TraineeCardHorizontal({
    super.key,
    required this.plan,
    required this.onTap,
    required this.index,
  });

  @override
  State<TraineeCardHorizontal> createState() => _TraineeCardHorizontalState();
}

class _TraineeCardHorizontalState extends State<TraineeCardHorizontal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );

    Future.delayed(Duration(milliseconds: 50 * widget.index), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String get fullName {
    final first = widget.plan.user?.firstName.trim() ?? '';
    final last = widget.plan.user?.lastName.trim() ?? '';
    if (first.isEmpty && last.isEmpty) return 'Trainee';
    return '$first $last'.trim();
  }

  String get initials {
    final first = widget.plan.user?.firstName.trim() ?? '';
    final last = widget.plan.user?.lastName.trim() ?? '';
    if (first.isEmpty && last.isEmpty) return '?';
    return '${first.isNotEmpty ? first[0] : ''}${last.isNotEmpty ? last[0] : ''}'
        .toUpperCase();
  }

  String _durationText(AppLocalizations l10n) {
    final duration = widget.plan.durationMonths;

    if (duration == null) {
      return l10n.planActive;
    }

    if (duration == 1) {
      return l10n.oneMonthPlan;
    }

    return l10n.monthsPlan(duration);
  }

  IconData get goalIcon {
    final goal = widget.plan.goal?.toLowerCase() ?? '';
    if (goal.contains('muscle') || goal.contains('bulk')) {
      return Icons.fitness_center_rounded;
    }
    if (goal.contains('weight') || goal.contains('loss')) {
      return Icons.local_fire_department_rounded;
    }
    return Icons.bolt_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final profilePic = widget.plan.user?.profilePic;
    final l10n = AppLocalizations.of(context)!;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: context.backgroundColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: context.backgroundColor, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: context.backgroundColor,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Stack(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primaryBtn,
                            AppColors.primaryBtn.withOpacity(0.3),
                          ],
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(2),
                        child: ClipOval(
                          child: profilePic != null && profilePic.isNotEmpty
                              ? Image.network(
                                  profilePic,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      _InitialsAvatar(initials: initials),
                                )
                              : _InitialsAvatar(initials: initials),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: context.backgroundColor,
                          border: Border.all(
                            color: AppColors.primaryBtn.withOpacity(0.4),
                          ),
                        ),
                        child: Icon(
                          goalIcon,
                          size: 9,
                          color: AppColors.primaryBtn,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        fullName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: context.textColor,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBtn.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _durationText(l10n),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryBtn,
                          ),
                        ),
                      ),
                    ],
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

class _InitialsAvatar extends StatelessWidget {
  final String initials;

  const _InitialsAvatar({required this.initials});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primaryBtn.withOpacity(0.1),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryBtn,
        ),
      ),
    );
  }
}
