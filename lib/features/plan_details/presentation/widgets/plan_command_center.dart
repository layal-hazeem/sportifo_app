import 'package:flutter/material.dart';
import 'package:sportifo_app/core/theme/app_colors.dart';
import 'package:sportifo_app/core/theme/app_theme_extensions.dart';
import 'package:sportifo_app/features/plan_details/data/models/plan_details_model.dart';
import 'package:sportifo_app/l10n/app_localizations.dart';

class PlanCommandCenter extends StatelessWidget {
  final PlanDetailsModel plan;

  const PlanCommandCenter({super.key, required this.plan});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final user = plan.user;
    final months = plan.durationMonths ?? 0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: context.textColor.withOpacity(.06)),
          boxShadow: [
            BoxShadow(
              color: context.textColor.withOpacity(.06),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _AthleteBlock(user: user)),
                const SizedBox(width: 10),
                _GoalBadge(goal: plan.goal),
              ],
            ),
            const SizedBox(height: 18),
            Container(height: 1, color: context.textColor.withOpacity(.06)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _StatTile(
                    icon: Icons.calendar_month_rounded,
                    label: l10n.duration,
                    value:
                        '$months ${months == 1 ? '${l10n.month}' : '${l10n.months}'}',
                  ),
                ),
                _Divider(),
                Expanded(
                  child: _StatTile(
                    icon: Icons.height_rounded,
                    label: l10n.height,
                    value: '${user?.height ?? '-'} ${l10n.cm}',
                  ),
                ),
                _Divider(),
                Expanded(
                  child: _StatTile(
                    icon: Icons.monitor_weight_outlined,
                    label: l10n.weight,
                    value: '${user?.weight ?? '-'} ${l10n.kg}',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 34,
      color: context.textColor.withOpacity(.06),
    );
  }
}

class _AthleteBlock extends StatelessWidget {
  final PlanUserModel? user;

  const _AthleteBlock({required this.user});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final name = user == null
        ? l10n.unknownAthlete
        : '${user!.firstName} ${user!.lastName}'.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.athlete,
          style: TextStyle(
            color: AppColors.hintText,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: context.textColor,
            fontSize: 22,
            fontWeight: FontWeight.w900,
            letterSpacing: -.5,
          ),
        ),
      ],
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
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primaryBtn.withOpacity(.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primaryBtn.withOpacity(.20)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_goalIcon(), color: AppColors.primaryBtn, size: 16),
          const SizedBox(width: 6),
          Text(
            goal ?? l10n.general,
            style: const TextStyle(
              color: AppColors.primaryBtn,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppColors.primaryBtn, size: 15),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                color: AppColors.hintText,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: context.textColor,
            fontSize: 14,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}
