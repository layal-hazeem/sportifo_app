import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sportifo_app/core/routes/app_routes.dart';
import 'package:sportifo_app/core/theme/app_colors.dart';
import '../../data/models/users_subscribed_model.dart';

class SubscriptionCard extends StatelessWidget {
  final UsersSubscribedModel userModel;

  const SubscriptionCard({super.key, required this.userModel});

  @override
  Widget build(BuildContext context) {
    final hasSubscriptions =
        userModel.userSubscriptions != null &&
        userModel.userSubscriptions!.isNotEmpty;
    final subscriptionsList = userModel.userSubscriptions ?? [];
    final bool hasActivePlan = userModel.hasPlan ?? false;
    final bool showCreatePlanButton = hasSubscriptions && !hasActivePlan;

    Color mainAccentColor = hasActivePlan ? Colors.green : AppColors.primaryBtn;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border(left: BorderSide(color: mainAccentColor, width: 6)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.all(14.0),
          childrenPadding: const EdgeInsets.only(
            left: 14.0,
            right: 14.0,
            bottom: 14.0,
          ),

          title: Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: mainAccentColor.withOpacity(0.2),
                backgroundImage: userModel.profilePic != null
                    ? NetworkImage(userModel.profilePic!)
                    : null,
                child: userModel.profilePic == null
                    ? Icon(Icons.person, color: mainAccentColor, size: 26)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${userModel.firstName ?? ""} ${userModel.lastName ?? ""}'
                          .trim(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3142),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Total Subs: ${subscriptionsList.length}",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: hasActivePlan
                      ? Colors.green.shade50
                      : Colors.deepOrange.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: hasActivePlan
                        ? Colors.green.shade200
                        : Colors.deepOrange.shade200,
                    width: 0.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      hasActivePlan
                          ? Icons.check_circle_rounded
                          : Icons.error_outline_rounded,
                      size: 13,
                      color: hasActivePlan
                          ? Colors.green
                          : AppColors.primaryBtn,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      hasActivePlan ? "Plan Active" : "Needs Plan",
                      style: TextStyle(
                        color: hasActivePlan
                            ? Colors.green.shade700
                            : AppColors.primaryBtn,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          children: [
            const Divider(color: Colors.grey, height: 1, thickness: 0.5),
            const SizedBox(height: 10),
            if (!hasSubscriptions)
              const Text("No subscriptions found for this user.")
            else
              ...subscriptionsList.map((sub) {
                final plan = sub.subscription;
                final String planType = plan?.type?.toLowerCase() ?? 'bronze';

                Color subAccentColor;
                IconData subBadgeIcon;
                switch (planType) {
                  case 'gold':
                    subAccentColor = const Color(0xFFFFB300);
                    subBadgeIcon = Icons.stars_rounded;
                    break;
                  case 'silver':
                    subAccentColor = const Color(0xFF78909C);
                    subBadgeIcon = Icons.workspace_premium_rounded;
                    break;
                  case 'bronze':
                  default:
                    subAccentColor = const Color(0xffa87c43);
                    subBadgeIcon = Icons.emoji_events_rounded;
                    break;
                }

                String formattedStartDate = sub.startDate != null
                    ? DateFormat('yyyy-MM-dd').format(sub.startDate!)
                    : 'N/A';
                String formattedEndDate = sub.endDate != null
                    ? DateFormat('yyyy-MM-dd').format(sub.endDate!)
                    : 'N/A';

                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: subAccentColor.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: subAccentColor.withOpacity(0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                subBadgeIcon,
                                color: subAccentColor,
                                size: 18,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${plan?.title ?? "No Plan"}',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: subAccentColor,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '${plan?.price ?? 0} ${plan?.currency ?? 'SYP'}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D3142),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildSubDetailsItem(
                            Icons.calendar_month_outlined,
                            "Starts",
                            formattedStartDate,
                          ),
                          _buildSubDetailsItem(
                            Icons.event_busy_outlined,
                            "Ends",
                            formattedEndDate,
                          ),
                          _buildSubDetailsItem(
                            Icons.timelapse_rounded,
                            "Duration",
                            '${plan?.months ?? 1} M',
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),
            if (showCreatePlanButton) ...[
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.createPlan,
                      arguments: userModel,
                    );
                  },
                  icon: const Icon(Icons.add_task_rounded, size: 18),
                  label: const Text(
                    "Create Training Plan Now",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBtn,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
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

  Widget _buildSubDetailsItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                color: Colors.grey[500],
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4F5D75),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
