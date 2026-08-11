import 'package:flutter/material.dart';
import 'package:sportifo_app/core/theme/app_colors.dart';
import 'package:sportifo_app/features/trainees/data/models/coach_plan_model.dart';

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
      duration: const Duration(milliseconds: 450),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );

    Future.delayed(
      Duration(milliseconds: 80 * widget.index),
      () {
        if (mounted) {
          _controller.forward();
        }
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String get fullName {
    final first = widget.plan.user?.firstName.trim() ?? '';
    final last = widget.plan.user?.lastName.trim() ?? '';

    return '$first $last'.trim();
  }

  String get initials {
    final first = widget.plan.user?.firstName.trim() ?? '';
    final last = widget.plan.user?.lastName.trim() ?? '';

    if (first.isEmpty && last.isEmpty) {
      return '?';
    }

    final firstInitial = first.isNotEmpty ? first[0] : '';
    final lastInitial = last.isNotEmpty ? last[0] : '';

    return '$firstInitial$lastInitial'.toUpperCase();
  }

  String get firstName {
    final first = widget.plan.user?.firstName.trim() ?? '';
    return first.isEmpty ? 'Trainee' : first;
  }

  IconData get goalIcon {
    final goal = widget.plan.goal?.toLowerCase() ?? '';

    if (goal.contains('strength')) {
      return Icons.fitness_center_rounded;
    }

    if (goal.contains('muscle') || goal.contains('bulk')) {
      return Icons.bolt_rounded;
    }

    if (goal.contains('weight') || goal.contains('loss')) {
      return Icons.monitor_weight_outlined;
    }

    if (goal.contains('fitness')) {
      return Icons.directions_run_rounded;
    }

    if (goal.contains('endurance')) {
      return Icons.speed_rounded;
    }

    return Icons.flag_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final profilePic = widget.plan.user?.profilePic;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                // Outer soft glow
                Container(
                  width: 112,
                  height: 112,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryBtn.withOpacity(0.18),
                        blurRadius: 22,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                ),

                // Orange ring
                Container(
                  width: 112,
                  height: 112,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primaryBtn,
                        AppColors.primaryBtn.withOpacity(0.45),
                      ],
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: ClipOval(
                      child: profilePic != null && profilePic.isNotEmpty
                          ? Image.network(
                              profilePic,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) {
                                return _InitialsAvatar(
                                  initials: initials,
                                );
                              },
                            )
                          : _InitialsAvatar(
                              initials: initials,
                            ),
                    ),
                  ),
                ),

                // Goal badge
                Positioned(
                  right: -3,
                  top: 3,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(
                        color: AppColors.primaryBtn.withOpacity(0.2),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      goalIcon,
                      size: 16,
                      color: AppColors.primaryBtn,
                    ),
                  ),
                ),

                // Plan indicator
                Positioned(
                  bottom: 1,
                  left: 1,
                  child: Container(
                    width: 27,
                    height: 27,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFFFFBF5),
                      border: Border.all(
                        color: Colors.white,
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      size: 14,
                      color: AppColors.primaryBtn,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            SizedBox(
              width: 125,
              child: Text(
                firstName,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF242424),
                  letterSpacing: 0.1,
                ),
              ),
            ),

            const SizedBox(height: 3),

            Text(
              _durationText,
              style: TextStyle(
                fontSize: 11,
                color: Colors.black.withOpacity(0.45),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String get _durationText {
    final duration = widget.plan.durationMonths;

    if (duration == null) {
      return 'Plan active';
    }

    return duration == 1 ? '1 month plan' : '$duration months plan';
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
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryBtn.withOpacity(0.18),
            AppColors.primaryBtn.withOpacity(0.05),
          ],
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(
          fontSize: 27,
          fontWeight: FontWeight.w700,
          color: AppColors.primaryBtn,
          letterSpacing: 1,
        ),
      ),
    );
  }
}