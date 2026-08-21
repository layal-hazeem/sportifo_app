import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sportifo_app/core/theme/app_theme_extensions.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_cached_image.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/models/my_plan_model.dart';

class WorkoutPlanCard extends StatelessWidget {
  final PlanModel plan;

  const WorkoutPlanCard({super.key, required this.plan});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    const String coachDefaultCoverImage =
        'https://img.freepik.com/free-photo/dumbbells-floor-gym-ai-generative_123827-23744.jpg';

    const String selfMadeDefaultCoverImage =
        'https://images.unsplash.com/photo-1584735935682-2f2b69dff9d2?auto=format&fit=crop&w=1471&q=80';
    final String defaultCoverImage = plan.isSelfMade
        ? selfMadeDefaultCoverImage
        : coachDefaultCoverImage;

    // Progress and weeks calculations
    int durationMonths = plan.durationMonths ?? 1;
    int totalDays = durationMonths * 30;
    int daysElapsed = 0;
    double progress = 0.0;
    int currentWeek = 1;
    int totalWeeks = totalDays ~/ 7;

    if (plan.createdAt != null) {
      try {
        DateTime startDate = DateTime.parse(plan.createdAt!);
        daysElapsed = DateTime.now().difference(startDate).inDays;
        if (daysElapsed < 0) daysElapsed = 0;
        progress = totalDays > 0 ? daysElapsed / totalDays : 0.0;
        if (progress > 1.0) progress = 1.0;
        currentWeek = (daysElapsed ~/ 7) + 1;
        if (currentWeek > totalWeeks) currentWeek = totalWeeks;
      } catch (e) {
        // Ignore parsing errors for invalid dates
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: context.backgroundColor,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBtn.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1️⃣ Card Top Banner
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(25),
              topRight: Radius.circular(25),
            ),
            child: Stack(
              children: [
                // Use plan image if available, else fallback to default
                CustomCachedImage(
                  imageUrl: (plan.image != null && plan.image!.isNotEmpty)
                      ? plan.image!
                      : defaultCoverImage,
                  height: 140,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withOpacity(0.7),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                // Badge displaying Type if exists (for saved plans)
                if (plan.type != null && plan.type!.isNotEmpty)
                  Positioned(
                    top: 16,
                    left: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBtn,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        plan.type!.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                // Date overlay
                Positioned(
                  top: 16,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      plan.createdAt ?? l10n.new_word,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                // Goal Name
                Positioned(
                  bottom: 16,
                  left: 20,
                  child: Text(
                    plan.goal?.toUpperCase() ?? l10n.workoutSummary,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 2️⃣ Internal Card Content
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Coach Info (shows only if it has a coach)
                if (!plan.isSelfMade && plan.coach != null) ...[
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: context.backgroundColor,
                        backgroundImage: CachedNetworkImageProvider(
                          plan.coach!.profilePic,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            plan.coach!.fullName,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: context.textColor,
                            ),
                          ),
                          Text(
                            l10n.yourPersonalCoach,
                            style: const TextStyle(
                              color: AppColors.hintText,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Divider(height: 24, color: context.backgroundColor),
                ],

                // 📊 3️⃣ Stats and Circular Progress
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Stats (Left)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildCompactStat(
                          Icons.timer_outlined,

                          plan.durationMonths != null
                              ? '${plan.durationMonths} ${l10n.months}'
                              : l10n.openDuration,
                          context,
                        ),
                        const SizedBox(height: 14),
                        _buildCompactStat(
                          Icons.view_day_outlined,
                          '${plan.daysCount ?? 0} ${l10n.daysPerWeek}',
                          context,
                        ),
                      ],
                    ),

                    // Progress Circle (Right)
                    if (plan.createdAt != null && plan.durationMonths != null)
                      Column(
                        children: [
                          SizedBox(
                            width: 55,
                            height: 55,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                CircularProgressIndicator(
                                  value: progress,
                                  backgroundColor: const Color(0xFFF0F0F0),
                                  color: AppColors.primaryBtn,
                                  strokeWidth: 5,
                                ),
                                Center(
                                  child: Text(
                                    '${(progress * 100).toInt()}%',
                                    style: TextStyle(
                                      color: context.textColor,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primaryBtn.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '$currentWeek / $totalWeeks ${l10n.wks}',
                              style: const TextStyle(
                                color: AppColors.primaryBtn,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),

                const SizedBox(height: 24),

                // Main Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.planDays,
                        arguments: plan,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBtn,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      l10n.viewDays,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactStat(IconData icon, String value, BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppColors.hintText, size: 18),
        const SizedBox(width: 8),
        Text(
          value,
          style: TextStyle(
            color: context.textColor,
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}