import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_cached_image.dart';
import '../../data/models/my_plan_model.dart';

class WorkoutPlanCard extends StatelessWidget {
  final PlanModel plan;

  const WorkoutPlanCard({super.key, required this.plan});

  @override
  Widget build(BuildContext context) {
    const String defaultCoverImage =
        'https://img.freepik.com/free-photo/dumbbells-floor-gym-ai-generative_123827-23744.jpg';

    // 🔥 حسابات شريط التقدم والأسابيع
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
        // تجاهل الخطأ في حال كان التاريخ غير صالح
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1️⃣ البانر العلوي للكارد
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(25),
              topRight: Radius.circular(25),
            ),
            child: Stack(
              children: [
                // 🔥 التعديل هنا: نستخدم صورة الخطة إذا موجودة، وإلا الصورة الافتراضية
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
                // 🔥 التعديل هنا: شارة تعرض الـ Type إذا كان موجود (للخطط المحفوظة)
                if (plan.type != null && plan.type!.isNotEmpty)
                  Positioned(
                    top: 16,
                    left: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBtn, // لون برتقالي مميز
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
                // التاريخ فوق الصورة
                Positioned(
                  top: 16,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      plan.createdAt ?? 'New',
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                // اسم الهدف
                Positioned(
                  bottom: 16,
                  left: 20,
                  child: Text(
                    plan.goal?.toUpperCase() ?? 'WORKOUT PLAN',
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

          // 2️⃣ المحتوى الداخلي للكارد
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // معلومات الكوتش (بتظهر بس إذا الخطة مو شخصية وفي كوتش)
                if (!plan.isSelfMade && plan.coach != null) ...[
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: AppColors.background,
                        backgroundImage: CachedNetworkImageProvider(plan.coach!.profilePic), // 🔥 كاش عالـ disk بدل NetworkImage
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            plan.coach!.fullName,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textDark),
                          ),
                          const Text(
                            'Your Personal Coach',
                            style: TextStyle(color: AppColors.hintText, fontSize: 12, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Divider(height: 24, color: AppColors.background),
                ],

                // 📊 3️⃣ الإحصائيات والدائرة
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // الإحصائيات (اليسار)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildCompactStat(
                            Icons.timer_outlined,
                            plan.durationMonths != null ? '${plan.durationMonths} Months' : 'Open Duration'
                        ),
                        const SizedBox(height: 14),
                        _buildCompactStat(
                            Icons.view_day_outlined,
                            '${plan.daysCount ?? 0} Days / Week'
                        ),
                      ],
                    ),

                    // الدائرة (اليمين)
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
                                    style: const TextStyle(
                                      color: AppColors.textDark,
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
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primaryBtn.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '$currentWeek / $totalWeeks Wks',
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

                // 🔥 الزر الرئيسي
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
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text(
                      'View Days',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
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

  Widget _buildCompactStat(IconData icon, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppColors.hintText, size: 18),
        const SizedBox(width: 8),
        Text(
          value,
          style: const TextStyle(color: AppColors.textDark, fontSize: 14, fontWeight: FontWeight.w800),
        ),
      ],
    );
  }
}