import 'package:flutter/material.dart';
import 'package:sportifo_app/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';

class QuickAction {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isPrimary;

  const QuickAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isPrimary = false,
  });
}

class QuickActionCard extends StatelessWidget {
  final QuickAction action;

  const QuickActionCard({super.key, required this.action});

  @override
  Widget build(BuildContext context) {
    final isPrimary = action.isPrimary;
    return Semantics(
      button: true,
      label: '${action.title}. ${action.subtitle}',
      child: InkWell(
        onTap: action.onTap,
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: isPrimary ? AppColors.primaryBtn : Colors.white,
            borderRadius: BorderRadius.circular(AppSizes.borderRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isPrimary
                      ? Colors.white.withOpacity(0.2)
                      : AppColors.primaryBtn.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  action.icon,
                  color: isPrimary ? Colors.white : AppColors.primaryBtn,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      action.title,
                      style: TextStyle(
                        fontSize: AppSizes.labelFontSize,
                        fontWeight: FontWeight.bold,
                        color: isPrimary ? Colors.white : AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      action.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: AppSizes.hintFontSize,
                        color: isPrimary
                            ? Colors.white.withOpacity(0.85)
                            : AppColors.hintText,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: isPrimary ? Colors.white : AppColors.hintText,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class QuickActionsSection extends StatelessWidget {
  final VoidCallback onSubscriptionsTap;
  final VoidCallback? onAddTraineeTap;
  final VoidCallback? onCreatePlanTap;

  const QuickActionsSection({
    super.key,
    required this.onSubscriptionsTap,
    this.onAddTraineeTap,
    this.onCreatePlanTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final actions = <QuickAction>[
      QuickAction(
        icon: Icons.card_membership_rounded,
        title: l10n.sub,
        subtitle: l10n.seeWhoNeedsANewTrainingPlan,
        isPrimary: true,
        onTap: onSubscriptionsTap,
      ),
      if (onAddTraineeTap != null)
        QuickAction(
          icon: Icons.person_add_alt_1_rounded,
          title: l10n.trainees,
          subtitle: l10n.waitANewTrainee,
          onTap: onAddTraineeTap!,
        ),
      if (onCreatePlanTap != null)
        QuickAction(
          icon: Icons.fitness_center_rounded,
          title: l10n.createPlan,
          subtitle: l10n.hintForCreatePlan,
          onTap: onCreatePlanTap!,
        ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.quickActions,
          style: TextStyle(
            fontSize: AppSizes.labelFontSize + 2,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 14),
        for (int i = 0; i < actions.length; i++) ...[
          if (i > 0) const SizedBox(height: 12),
          QuickActionCard(action: actions[i]),
        ],
      ],
    );
  }
}
