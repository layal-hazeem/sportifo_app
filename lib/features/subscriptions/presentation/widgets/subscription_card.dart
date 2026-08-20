import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sportifo_app/core/theme/app_colors.dart';
import 'package:sportifo_app/core/theme/app_theme_extensions.dart';
import 'package:sportifo_app/l10n/app_localizations.dart';
import '../../data/models/users_subscribed_model.dart';

class SubscriptionCard extends StatelessWidget {
  final UsersSubscribedModel userModel;
  final VoidCallback onCreatePlan;
  final bool isHistory;

  const SubscriptionCard({
    super.key,
    required this.userModel,
    required this.onCreatePlan,
    this.isHistory = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final subscriptions = userModel.userSubscriptions ?? [];
    final activeSubscription = _getActiveSubscription(subscriptions);

    final subscription = isHistory
        ? _getHistorySubscription(subscriptions)
        : activeSubscription;

    final plan = subscription?.subscription;
    final countPlan = subscription?.countPlan ?? 0;
    final hasPlans = countPlan > 0;

    final planType = plan?.type?.trim().toLowerCase() ?? "bronze";
    final planColors = _getPlanColors(planType);

    final backgroundColor = context.backgroundColor;
    final textColor = context.textColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: !isHistory && !hasPlans
              ? AppColors.primaryBtn.withOpacity(0.45)
              : AppColors.hintText.withOpacity(0.15),
          width: !isHistory && !hasPlans ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: planColors.primary.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: textColor.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [backgroundColor, planColors.primary.withOpacity(0.03)],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ─────────────────────────────
                // USER HEADER
                // ─────────────────────────────
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            planColors.primary,
                            planColors.primary.withOpacity(0.5),
                          ],
                        ),
                      ),
                      padding: const EdgeInsets.all(2),
                      child: CircleAvatar(
                        radius: 28,
                        backgroundColor: backgroundColor,
                        backgroundImage: userModel.profilePic != null
                            ? NetworkImage(userModel.profilePic!)
                            : null,
                        child: userModel.profilePic == null
                            ? Icon(
                                Icons.person,
                                size: 28,
                                color: planColors.primary,
                              )
                            : null,
                      ),
                    ),

                    const SizedBox(width: 14),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${userModel.firstName ?? ""} "
                            "${userModel.lastName ?? ""}",
                            style: TextStyle(
                              fontSize: 16.5,
                              fontWeight: FontWeight.w800,
                              color: textColor,
                              letterSpacing: -0.3,
                            ),
                          ),

                          const SizedBox(height: 3),

                          Row(
                            children: [
                              Icon(
                                planColors.icon,
                                size: 14,
                                color: planColors.primary,
                              ),

                              const SizedBox(width: 4),

                              Text(
                                "${plan?.title ?? l10n.defaultPlan} "
                                "(${planType.toUpperCase()})",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: planColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    isHistory
                        ? _historyBadge(context, l10n)
                        : _planCountBadge(context, countPlan),
                  ],
                ),

                const SizedBox(height: 16),

                Divider(color: AppColors.hintText.withOpacity(0.12), height: 1),

                const SizedBox(height: 16),

                // ─────────────────────────────
                // DATES
                // ─────────────────────────────
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.hintText.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.hintText.withOpacity(0.12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _infoItem(
                        context,
                        Icons.calendar_today_rounded,
                        l10n.startDate,
                        _formatDate(subscription?.startDate),
                      ),

                      Container(
                        height: 24,
                        width: 1,
                        color: AppColors.hintText.withOpacity(0.25),
                      ),

                      _infoItem(
                        context,
                        Icons.event_available_rounded,
                        l10n.endDate,
                        _formatDate(subscription?.endDate),
                      ),
                    ],
                  ),
                ),

                // ─────────────────────────────
                // CREATE PLAN BUTTON
                // ─────────────────────────────
                if (!isHistory) ...[
                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: onCreatePlan,
                      icon: Icon(
                        hasPlans
                            ? Icons.add_circle_outline_rounded
                            : Icons.auto_awesome_rounded,
                        size: 18,
                      ),
                      label: Text(
                        hasPlans
                            ? l10n.createAdditionalPlan
                            : l10n.createTrainingPlan,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13.5,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBtn,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────
  // PLAN STATUS
  // ─────────────────────────────────────────

  Widget _planStatusBadge(
    BuildContext context,
    bool hasPlan,
    AppLocalizations l10n,
  ) {
    final color = hasPlan ? Colors.green : AppColors.primaryBtn;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            hasPlan ? Icons.check_circle_rounded : Icons.warning_rounded,
            size: 12,
            color: color,
          ),

          const SizedBox(width: 4),

          Text(
            hasPlan ? l10n.activePlan : l10n.needs_a_plan,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────
  // HISTORY BADGE
  // ─────────────────────────────────────────

  Widget _historyBadge(BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.hintText.withOpacity(0.10),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.hintText.withOpacity(0.18)),
      ),
      child: Text(
        l10n.expired,
        style: const TextStyle(
          color: AppColors.hintText,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ─────────────────────────────────────────
  // INFO ITEM
  // ─────────────────────────────────────────

  Widget _infoItem(
    BuildContext context,
    IconData icon,
    String title,
    String value,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: context.backgroundColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: context.textColor.withOpacity(0.04),
                blurRadius: 4,
              ),
            ],
          ),
          child: Icon(icon, size: 14, color: AppColors.primaryBtn),
        ),

        const SizedBox(width: 8),

        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.hintText,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 1),

            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: context.textColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return "-";
    return DateFormat("dd MMM yyyy").format(date);
  }

  // ─────────────────────────────────────────
  // PLAN COLORS
  // ─────────────────────────────────────────

  _PlanColors _getPlanColors(String type) {
    switch (type) {
      case "gold":
        return _PlanColors(
          primary: AppColors.primaryBtn,
          icon: Icons.workspace_premium_rounded,
        );

      case "silver":
        return _PlanColors(
          primary: AppColors.hintText,
          icon: Icons.star_rounded,
        );

      default:
        return _PlanColors(
          primary: AppColors.primaryBtn,
          icon: Icons.emoji_events_rounded,
        );
    }
  }

  // ─────────────────────────────────────────
  // SUBSCRIPTION LOGIC
  // ─────────────────────────────────────────

  bool _isCurrentlyActive(UserSubscription sub, DateTime now) {
    final status = sub.status?.trim().toLowerCase();

    final start = sub.startDate;
    final end = sub.endDate;

    if (status != 'active') return false;
    if (start == null || end == null) return false;

    final hasStarted = !start.isAfter(now);
    final hasNotEnded = !end.isBefore(now);

    return hasStarted && hasNotEnded;
  }

  UserSubscription? _getActiveSubscription(
    List<UserSubscription> subscriptions,
  ) {
    final now = DateTime.now();

    UserSubscription? best;

    for (final sub in subscriptions) {
      if (!_isCurrentlyActive(sub, now)) continue;

      if (best == null) {
        best = sub;
        continue;
      }

      final bestStart = best.startDate;
      final subStart = sub.startDate;

      if (subStart != null &&
          (bestStart == null || subStart.isAfter(bestStart))) {
        best = sub;
      }
    }

    return best;
  }

  UserSubscription? _getHistorySubscription(
    List<UserSubscription> subscriptions,
  ) {
    final now = DateTime.now();
    final windowStart = now.subtract(const Duration(days: 30));

    UserSubscription? latest;

    for (final sub in subscriptions) {
      final endDate = sub.endDate;

      if (endDate == null) continue;

      final isFinished = !_isCurrentlyActive(sub, now);

      final isRecent = endDate.isAfter(windowStart);

      if (!isFinished || !isRecent) continue;

      if (latest == null || endDate.isAfter(latest.endDate!)) {
        latest = sub;
      }
    }

    return latest;
  }

  Widget _planCountBadge(BuildContext context, int countPlan) {
    final hasPlans = countPlan > 0;

    final color = hasPlans ? Colors.green : AppColors.primaryBtn;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            hasPlans
                ? Icons.check_circle_rounded
                : Icons.add_circle_outline_rounded,
            size: 12,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            '$countPlan ${countPlan == 1 ? 'Plan' : 'Plans'}',
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanColors {
  final Color primary;
  final IconData icon;

  _PlanColors({required this.primary, required this.icon});
}
