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

    // Resolve the truly-active subscription once (source of truth),
    // then decide which one this specific card should render.
    final activeSubscription = _getActiveSubscription(subscriptions);

    final subscription = isHistory
        ? _getHistorySubscription(subscriptions)
        : activeSubscription;

    // Don't blindly trust userModel.hasPlan — derive it from the actual
    // subscription data so the badge always matches what's on screen.
    // Fall back to the model flag only if there's simply no subscription
    // data to check against.
    final hasPlan = subscriptions.isEmpty
        ? (userModel.hasPlan ?? false)
        : activeSubscription != null;

    final plan = subscription?.subscription;

    final planType = plan?.type?.trim().toLowerCase() ?? "bronze";

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

                // History cards describe a finished period, so they get a
                // neutral badge instead of the live active/needs-plan status.
                isHistory ? _historyBadge() : _planStatusBadge(hasPlan),
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

  Widget _historyBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        "History",
        style: TextStyle(
          color: Colors.grey.shade700,
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

  /// Single source of truth for "is this subscription's status flag valid",
  /// used by BOTH active and history resolution so the two never disagree
  /// on what counts as a genuinely active record.
  /// Trims + lower-cases defensively against backend inconsistencies like
  /// "Active " or "ACTIVE".
  bool _hasValidActiveStatus(UserSubscription sub) {
    final status = sub.status?.trim().toLowerCase();
    return status == "active" && (sub.isActive ?? 0) == 1;
  }

  /// True if [sub] is genuinely active right now: valid status flag,
  /// already started (or no start date recorded), and not yet ended.
  /// The end-of-day boundary (`isAtSameMomentAs`) is included here and
  /// excluded from the "finished" check in history, so a subscription
  /// can never fall into a gap where it matches neither list.
  bool _isCurrentlyActive(UserSubscription sub, DateTime now) {
    final start = sub.startDate;
    final end = sub.endDate;

    if (end == null) return false;
    if (!_hasValidActiveStatus(sub)) return false;

    final hasStarted = start == null || !start.isAfter(now);
    final hasNotEnded = end.isAfter(now) || end.isAtSameMomentAs(now);

    return hasStarted && hasNotEnded;
  }

  /// Among all currently-active subscriptions (there should only ever be
  /// one, but we defend against dirty/overlapping backend data), pick the
  /// one with the latest start date rather than just the first match.
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

      // Prefer the one that started more recently; treat a missing
      // start date as "always started" so it doesn't win by default.
      if (subStart != null &&
          (bestStart == null || subStart.isAfter(bestStart))) {
        best = sub;
      }
    }

    return best;
  }

  /// Among subscriptions that are NOT currently active (finished, by the
  /// exact same definition _isCurrentlyActive uses) and ended within the
  /// last 30 days, return the most recently ended one.
  UserSubscription? _getHistorySubscription(
    List<UserSubscription> subscriptions,
  ) {
    final now = DateTime.now();

    // Fixed 30-day window instead of naive month subtraction, which could
    // roll over into an invalid day-of-month (e.g. "31 Feb") and silently
    // produce a wrong cutoff date.
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
  final Color background;
  final IconData icon;

  _PlanColors({
    required this.primary,
    required this.background,
    required this.icon,
  });
}
