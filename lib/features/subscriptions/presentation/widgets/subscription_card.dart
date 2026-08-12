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

    final hasPlan = userModel.hasPlan ?? false;
    final plan = subscription?.subscription;
    final planType = plan?.type?.trim().toLowerCase() ?? "bronze";
    final colors = _getPlanColors(planType);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: !isHistory && !hasPlan
              ? Colors.amber.shade400.withOpacity(0.6)
              : Colors.grey.shade200,
          width: !isHistory && !hasPlan ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
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
              colors: [Colors.white, colors.primary.withOpacity(0.02)],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// USER HEADER INFO
                Row(
                  children: [
                    Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                colors.primary,
                                colors.primary.withOpacity(0.5),
                              ],
                            ),
                          ),
                          padding: const EdgeInsets.all(2),
                          child: CircleAvatar(
                            radius: 28,
                            backgroundColor: Colors.white,
                            backgroundImage: userModel.profilePic != null
                                ? NetworkImage(userModel.profilePic!)
                                : null,
                            child: userModel.profilePic == null
                                ? Icon(
                                    Icons.person,
                                    size: 28,
                                    color: colors.primary,
                                  )
                                : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${userModel.firstName ?? ""} ${userModel.lastName ?? ""}",
                            style: const TextStyle(
                              fontSize: 16.5,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              Icon(
                                colors.icon,
                                size: 14,
                                color: colors.primary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "${plan?.title ?? "Default Plan"} (${planType.toUpperCase()})",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: colors.primary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    isHistory ? _historyBadge() : _planStatusBadge(hasPlan),
                  ],
                ),

                const SizedBox(height: 16),
                Divider(color: Colors.grey.shade100, height: 1),
                const SizedBox(height: 16),

                /// DATES CONTAINER (Modern Pill Style)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.grey.shade200.withOpacity(0.8),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _infoItem(
                        Icons.calendar_today_rounded,
                        "Start Date",
                        _formatDate(subscription?.startDate),
                      ),
                      Container(
                        height: 24,
                        width: 1,
                        color: Colors.grey.shade300,
                      ),
                      _infoItem(
                        Icons.event_available_rounded,
                        "End Date",
                        _formatDate(subscription?.endDate),
                      ),
                    ],
                  ),
                ),

                /// CREATE PLAN BUTTON
                if (!isHistory && !hasPlan) ...[
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryBtn.withOpacity(0.25),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: onCreatePlan,
                        icon: const Icon(Icons.auto_awesome_rounded, size: 18),
                        label: const Text(
                          "Create Training Plan",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13.5,
                            letterSpacing: 0.2,
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
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _planStatusBadge(bool hasPlan) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: hasPlan
            ? Colors.green.withOpacity(0.1)
            : Colors.amber.withOpacity(0.15),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: hasPlan
              ? Colors.green.withOpacity(0.3)
              : Colors.amber.withOpacity(0.5),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            hasPlan ? Icons.check_circle_rounded : Icons.warning_rounded,
            size: 12,
            color: hasPlan ? Colors.green.shade700 : Colors.amber.shade800,
          ),
          const SizedBox(width: 4),
          Text(
            hasPlan ? "Active Plan" : "Needs Plan",
            style: TextStyle(
              color: hasPlan ? Colors.green.shade700 : Colors.amber.shade800,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _historyBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(30),
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
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4),
            ],
          ),
          child: Icon(icon, size: 14, color: Colors.grey.shade600),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 1),
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
          primary: const Color(0xFFF59E0B),
          icon: Icons.workspace_premium_rounded,
        );
      case "silver":
        return _PlanColors(
          primary: const Color(0xFF64748B),
          icon: Icons.star_rounded,
        );
      default:
        return _PlanColors(
          primary: const Color(0xFFB45309),
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
