import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:sportifo_app/core/theme/app_colors.dart';
import 'package:sportifo_app/features/plan_details/data/models/plan_details_model.dart';

class PlanCommandCenter extends StatelessWidget {
  final PlanDetailsModel plan;

  const PlanCommandCenter({super.key, required this.plan});

  @override
  Widget build(BuildContext context) {
    final user = plan.user;

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 0),
      child: Container(
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(23),
          border: Border.all(color: AppColors.textDark.withOpacity(.07)),
          boxShadow: [
            BoxShadow(
              color: AppColors.textDark.withOpacity(.075),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [Expanded(child: _AthleteBlock(user: user))],
            ),

            const SizedBox(height: 17),

            Container(height: 1, color: AppColors.textDark.withOpacity(.07)),

            const SizedBox(height: 15),

            Row(
              children: [
                Expanded(
                  child: _PlanDuration(months: plan.durationMonths ?? 0),
                ),

                const SizedBox(width: 9),

                _GoalBadge(goal: plan.goal),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AthleteBlock extends StatelessWidget {
  final PlanUserModel? user;

  const _AthleteBlock({required this.user});

  @override
  Widget build(BuildContext context) {
    final name = user == null
        ? 'Unknown Athlete'
        : '${user!.firstName} ${user!.lastName}'.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ATHLETE',
          style: TextStyle(
            color: AppColors.hintText,
            fontSize: 9,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.8,
          ),
        ),

        const SizedBox(height: 6),

        Text(
          name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppColors.textDark,
            fontSize: 21,
            fontWeight: FontWeight.w900,
            letterSpacing: -.5,
          ),
        ),

        const SizedBox(height: 12),

        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            _MetricChip(
              icon: Icons.height_rounded,
              value: '${user?.height ?? 0} cm',
            ),
            _MetricChip(
              icon: Icons.monitor_weight_outlined,
              value: '${user?.weight ?? 0} kg',
            ),
          ],
        ),
      ],
    );
  }
}

class _MetricChip extends StatelessWidget {
  final IconData icon;
  final String value;

  const _MetricChip({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: AppColors.textDark.withOpacity(.06)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.hintText, size: 13),
          const SizedBox(width: 5),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textDark,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _GoalBadge extends StatelessWidget {
  final String? goal;

  const _GoalBadge({required this.goal});

  IconData _goalIcon() {
    switch (goal?.toLowerCase()) {
      case 'bulk':
        return Icons.trending_up_rounded;
      case 'cut':
        return Icons.local_fire_department_rounded;
      case 'maintain':
        return Icons.balance_rounded;
      default:
        return Icons.track_changes_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.primaryBtn.withOpacity(.10),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: AppColors.primaryBtn.withOpacity(.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_goalIcon(), color: AppColors.primaryBtn, size: 14),
          const SizedBox(width: 5),
          Text(
            (goal ?? 'GENERAL').toUpperCase(),
            style: const TextStyle(
              color: AppColors.primaryBtn,
              fontSize: 9,
              fontWeight: FontWeight.w900,
              letterSpacing: .7,
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanDuration extends StatelessWidget {
  final int months;

  const _PlanDuration({required this.months});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 34,
          height: 34,
          child: CustomPaint(
            painter: _RingPainter(progress: months > 0 ? 1 : 0),
            child: Center(
              child: Text(
                '$months',
                style: const TextStyle(
                  color: AppColors.textDark,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(width: 8),

        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'BLUEPRINT',
              style: TextStyle(
                color: AppColors.hintText,
                fontSize: 8,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.1,
              ),
            ),
            Text(
              '$months MONTH${months == 1 ? '' : 'S'}',
              style: const TextStyle(
                color: AppColors.textDark,
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatusIndicator extends StatelessWidget {
  final bool isSelfMade;

  const _StatusIndicator({required this.isSelfMade});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primaryBtn,
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryBtn.withOpacity(.35),
                blurRadius: 7,
                spreadRadius: 1,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;

  _RingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    final radius = size.width / 2 - 2;

    final backgroundPaint = Paint()
      ..color = AppColors.textDark.withOpacity(.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final progressPaint = Paint()
      ..color = AppColors.primaryBtn
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3;

    canvas.drawCircle(center, radius, backgroundPaint);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      math.pi * 2 * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
