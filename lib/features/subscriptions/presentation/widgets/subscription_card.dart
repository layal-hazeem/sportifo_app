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

    final subscription = isHistory
        ? _getHistorySubscription(subscriptions)
        : _getActiveSubscription(subscriptions);

    final hasPlan = userModel.hasPlan ?? false;

    final plan = subscription?.subscription;

    final planType = plan?.type?.toLowerCase() ?? "bronze";

    final colors = _getPlanColors(planType);

    return Container(
      margin: const EdgeInsets.only(bottom: 18),

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),

        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, colors.background],
        ),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),

      child: Padding(
        padding: const EdgeInsets.all(18),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            /// HEADER
            Row(
              children: [
                 CircleAvatar(
                    radius: 30,

                    backgroundColor: colors.primary.withOpacity(.15),

                    backgroundImage: userModel.profilePic != null
                        ? NetworkImage(userModel.profilePic!)
                        : null,

                    child: userModel.profilePic == null
                        ? Icon(Icons.person, size: 30, color: colors.primary)
                        : null,
                  ),
                

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Text(
                        "${userModel.firstName ?? ""} ${userModel.lastName ?? ""}",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Text(
                        userModel.phone ?? "",
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),

                _planStatusBadge(hasPlan),
              ],
            ),

            const SizedBox(height: 20),

            /// PLAN CARD
            Container(
              padding: const EdgeInsets.all(14),

              decoration: BoxDecoration(
                color: colors.primary.withOpacity(.08),

                borderRadius: BorderRadius.circular(18),
              ),

              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),

                    decoration: BoxDecoration(
                      color: colors.primary,

                      shape: BoxShape.circle,
                    ),

                    child: Icon(colors.icon, color: Colors.white),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Text(
                          plan?.title ?? "No Plan",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: colors.primary,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          planType.toUpperCase(),

                          style: TextStyle(
                            fontSize: 12,
                            color: colors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            /// DATES
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,

              children: [
                _infoItem(
                  Icons.calendar_month,
                  "Start",
                  _formatDate(subscription?.startDate),
                ),

                _infoItem(
                  Icons.event,
                  "End",
                  _formatDate(subscription?.endDate),
                ),
              ],
            ),

            const SizedBox(height: 18),

            if (!isHistory && !hasPlan) ...[
              const SizedBox(height: 18),

              SizedBox(
                width: double.infinity,

                child: ElevatedButton.icon(
                  onPressed: onCreatePlan,

                  icon: const Icon(Icons.fitness_center),

                  label: const Text(
                    "Create Training Plan",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),

                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBtn,

                    foregroundColor: Colors.white,

                    padding: const EdgeInsets.symmetric(vertical: 14),

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _planStatusBadge(bool hasPlan) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),

      decoration: BoxDecoration(
        color: hasPlan ? Colors.green.shade50 : Colors.orange.shade50,

        borderRadius: BorderRadius.circular(20),
      ),

      child: Text(
        hasPlan ? "Plan Active" : "Needs Plan",

        style: TextStyle(
          color: hasPlan ? Colors.green : Colors.orange,

          fontSize: 11,

          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _infoItem(IconData icon, String title, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey),

        const SizedBox(width: 6),

        Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),

            Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) {
      return "-";
    }

    return DateFormat("dd MMM yyyy").format(date);
  }

  _PlanColors _getPlanColors(String type) {
    switch (type) {
      case "gold":
        return _PlanColors(
          primary: const Color(0xffD99A00),
          background: const Color(0xfffff7dc),
          icon: Icons.workspace_premium,
        );

      case "silver":
        return _PlanColors(
          primary: const Color(0xff78909C),
          background: const Color(0xfff1f5f8),
          icon: Icons.star,
        );

      default:
        return _PlanColors(
          primary: const Color(0xffa87c43),
          background: const Color(0xfffaf1e8),
          icon: Icons.emoji_events,
        );
    }
  }

  UserSubscription? _getActiveSubscription(
    List<UserSubscription> subscriptions,
  ) {
    final now = DateTime.now();

    for (final sub in subscriptions) {
      final endDate = sub.endDate;

      if (sub.status?.toLowerCase() == "active" &&
          (sub.isActive ?? 0) == 1 &&
          endDate != null &&
          !endDate.isBefore(now)) {
        return sub;
      }
    }

    return null;
  }

  UserSubscription? _getHistorySubscription(
    List<UserSubscription> subscriptions,
  ) {
    final now = DateTime.now();

    final oneMonthAgo = DateTime(
      now.year,
      now.month - 1,
      now.day,
      now.hour,
      now.minute,
      now.second,
    );

    UserSubscription? latest;

    for (final sub in subscriptions) {
      final endDate = sub.endDate;

      if (endDate == null) {
        continue;
      }

      final isFinished =
          sub.status?.toLowerCase() != "active" || endDate.isBefore(now);

      final isRecent = endDate.isAfter(oneMonthAgo);

      if (isFinished && isRecent) {
        if (latest == null || endDate.isAfter(latest.endDate!)) {
          latest = sub;
        }
      }
    }

    return latest;
  }
}

class _PlanColors {
  final Color primary;
  final Color background;
  final IconData icon;

  _PlanColors({
    required this.primary,
    required this.background,
    required this.icon,
  });
}
