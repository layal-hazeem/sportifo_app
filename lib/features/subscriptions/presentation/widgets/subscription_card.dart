import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sportifo_app/core/theme/app_colors.dart';
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
    final subscriptions = userModel.userSubscriptions ?? [];
    final activeSubscription = _getActiveSubscription(subscriptions);
    final subscription = isHistory
        ? _getHistorySubscription(subscriptions)
        : activeSubscription;

    final hasPlan = userModel.hasPlan;

    final plan = subscription?.subscription;
    final planType = plan?.type?.trim().toLowerCase() ?? "bronze";
    final colors = _getPlanColors(planType);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: !isHistory && !hasPlan!
              ? Colors.amber.shade600.withOpacity(0.5)
              : Colors.grey.shade200,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: colors.primary.withOpacity(0.5),
                        width: 2,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 26,
                      backgroundColor: colors.primary.withOpacity(0.1),
                      backgroundImage: userModel.profilePic != null
                          ? NetworkImage(userModel.profilePic!)
                          : null,
                      child: userModel.profilePic == null
                          ? Icon(Icons.person, size: 24, color: colors.primary)
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${userModel.firstName ?? ""} ${userModel.lastName ?? ""}",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  isHistory ? _historyBadge() : _planStatusBadge(hasPlan!),
                ],
              ),

              const SizedBox(height: 14),
              Divider(color: Colors.grey.shade100, height: 1),
              const SizedBox(height: 14),

              /// PLAN INFO MINI BANNER
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colors.primary.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Icon(colors.icon, color: colors.primary, size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            plan?.title ?? "Default Plan",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: colors.primary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            planType.toUpperCase(),
                            style: TextStyle(
                              fontSize: 11,
                              color: colors.primary.withOpacity(0.8),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              /// DATES (Start & End Date)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _infoItem(
                    Icons.calendar_today_rounded,
                    "Start Date",
                    _formatDate(subscription?.startDate),
                  ),
                  _infoItem(
                    Icons.event_available_rounded,
                    "End Date",
                    _formatDate(subscription?.endDate),
                  ),
                ],
              ),

              /// CREATE PLAN BUTTON
              if (!isHistory && !hasPlan!) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onCreatePlan,
                    icon: const Icon(Icons.auto_awesome_rounded, size: 18),
                    label: const Text(
                      "✨ Create Training Plan Now",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBtn,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _planStatusBadge(bool hasPlan) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: hasPlan
            ? Colors.green.withOpacity(0.1)
            : Colors.amber.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: hasPlan
              ? Colors.green.withOpacity(0.3)
              : Colors.amber.withOpacity(0.4),
        ),
      ),
      child: Text(
        hasPlan ? "Active Plan" : "⚠️ Needs Plan",
        style: TextStyle(
          color: hasPlan ? Colors.green.shade700 : Colors.amber.shade800,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _historyBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text(
        "Expired",
        style: TextStyle(
          color: Colors.grey,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _infoItem(IconData icon, String title, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade500),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
            ),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: Color(0xFF1E293B),
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

  _PlanColors _getPlanColors(String type) {
    switch (type) {
      case "gold":
        return _PlanColors(
          primary: const Color(0xFFFFA500),
          icon: Icons.workspace_premium_rounded,
        );
      case "silver":
        return _PlanColors(
          primary: const Color(0xFF94A3B8),
          icon: Icons.star_rounded,
        );
      default:
        return _PlanColors(
          primary: const Color(0xFFCD7F32),
          icon: Icons.emoji_events_rounded,
        );
    }
  }

  bool _hasValidActiveStatus(UserSubscription sub) {
    final status = sub.status?.trim().toLowerCase();
    return status == "active" && (sub.isActive ?? 0) == 1;
  }

  bool _isCurrentlyActive(UserSubscription sub, DateTime now) {
    final start = sub.startDate;
    final end = sub.endDate;
    if (end == null) return false;
    if (!_hasValidActiveStatus(sub)) return false;
    final hasStarted = start == null || !start.isAfter(now);
    final hasNotEnded = end.isAfter(now) || end.isAtSameMomentAs(now);
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
}

class _PlanColors {
  final Color primary;
  final IconData icon;

  _PlanColors({required this.primary, required this.icon});
}
