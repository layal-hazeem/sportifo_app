import 'package:flutter/material.dart';
import 'package:sportifo_app/core/theme/app_colors.dart';
import 'package:sportifo_app/features/trainees/data/models/coach_plan_model.dart';
import 'package:sportifo_app/l10n/app_localizations.dart';

class TraineeCircle extends StatefulWidget {
  final CoachPlanModel plan;
  final VoidCallback onTap;
  final int index;

  const TraineeCircle({
    super.key,
    required this.plan,
    required this.onTap,
    required this.index,
  });

  @override
  State<TraineeCircle> createState() => _TraineeCircleState();
}

class _TraineeCircleState extends State<TraineeCircle>
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

    Future.delayed(Duration(milliseconds: 60 * widget.index), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _fullName(AppLocalizations l10n) {
    final first = widget.plan.user?.firstName.trim() ?? '';
    final last = widget.plan.user?.lastName.trim() ?? '';

    if (first.isEmpty && last.isEmpty) {
      return l10n.trainee;
    }

    return '$first $last'.trim();
  }

  String get initials {
    final first = widget.plan.user?.firstName.trim() ?? '';
    final last = widget.plan.user?.lastName.trim() ?? '';

    if (first.isEmpty && last.isEmpty) {
      return '?';
    }

    return '${first.isNotEmpty ? first[0] : ''}'
            '${last.isNotEmpty ? last[0] : ''}'
        .toUpperCase();
  }

  String _firstName(AppLocalizations l10n) {
    final first = widget.plan.user?.firstName.trim() ?? '';

    return first.isEmpty ? l10n.trainee : first;
  }

  String _durationText(AppLocalizations l10n) {
    final duration = widget.plan.durationMonths;

    if (duration == null) {
      return l10n.hasAnActivePlan;
    }

    if (duration == 1) {
      return l10n.oneMonthProgram;
    }

    return l10n.monthsProgram(duration);
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
    final l10n = AppLocalizations.of(context)!;
    final profilePic = widget.plan.user?.profilePic;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(24),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.grey.shade100,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.primaryBtn,
                            AppColors.primaryBtn.withOpacity(0.3),
                          ],
                        ),
                      ),
                      child: Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        child: ClipOval(
                          child: profilePic != null &&
                                  profilePic.isNotEmpty
                              ? Image.network(
                                  profilePic,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      _InitialsAvatar(
                                    initials: initials,
                                  ),
                                )
                              : _InitialsAvatar(
                                  initials: initials,
                                ),
                        ),
                      ),
                    ),

                    // Goal icon
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: Border.all(
                            color: AppColors.primaryBtn.withOpacity(0.3),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          goalIcon,
                          size: 12,
                          color: AppColors.primaryBtn,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Trainee name
                Text(
                  _firstName(l10n),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                  ),
                ),

                const SizedBox(height: 4),

                // Plan duration
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBtn.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _durationText(l10n),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryBtn,
                    ),
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

  const _InitialsAvatar({
    required this.initials,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primaryBtn.withOpacity(0.1),
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryBtn,
        ),
      ),
    );
  }
}