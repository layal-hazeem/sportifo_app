import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/routes/app_routes.dart'; // 👈 ضروري للـ AppRoutes.home
import '../../../../core/di/service_locator.dart';
import '../../../my_plans(user)/data/models/my_plan_model.dart';
import '../../../my_plans(user)/presentation/view/my_plans_screen.dart'; // 👈 لـ activeTabNotifier
import '../../../home/presentation/view/home_page.dart'; // 👈 لـ homeViewModel
import '../view_model/platform_plans_cubit.dart';

class PlatformPlanCard extends StatefulWidget {
  final PlanModel plan;
  final VoidCallback onTap;

  const PlatformPlanCard({
    super.key,
    required this.plan,
    required this.onTap,
  });

  @override
  State<PlatformPlanCard> createState() => _PlatformPlanCardState();
}

class _PlatformPlanCardState extends State<PlatformPlanCard> {
  late bool _isSaved;

  @override
  void initState() {
    super.initState();
    // 1️⃣ أخذ الحالة الابتدائية من المودل (اللي جابها من السيرفر)
    _isSaved = widget.plan.isSaved;
  }

  // 2️⃣ المراقبة والتحديث عند تغير البيانات من خارج الكارد
  @override
  void didUpdateWidget(covariant PlatformPlanCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 🔥 السحر هون: شلنا الـ if الشرطية، لحتى نجبر الواجهة تاخد التحديث دايماً
    // وهيك مستحيل الهوم يعرضلك شي مختلف عن الفيو أول أو السيف!
    _isSaved = widget.plan.isSaved;
  }

  // 3️⃣ دالة الكبس على زر الحفظ (سريعة وتفاعلية)
  void _toggleSave() async {
    final wasSaved = _isSaved;

    // تغيير فوري للواجهة لتبدو متجاوبة
    setState(() {
      _isSaved = !_isSaved;
    });

    // انتظار رد الباك إند
    final message = await getIt<PlatformPlansCubit>().toggleSave(widget.plan.id);

    if (message != null && mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      if (!wasSaved) {
        // 🔥 تم الحفظ: إظهار سناك بار مع خيار النقل
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            action: SnackBarAction(
              label: 'View Saved',
              textColor: Colors.white,
              onPressed: () {
                // 1. تغيير تاب الـ Navigation Bar الأساسي لـ My Plans (رقم 1)
                homeViewModel.changeTab(1);

                // 2. أمر الشاشة لتنتقل لتاب Saved (رقم 2)
                MyPlansScreen.activeTabNotifier.value = 2;

                // 3. 🔥 الرجوع للصفحة الرئيسية بأمان تاااام (يمنع الشاشة السوداء)
                Navigator.popUntil(context, (route) => route.isFirst || route.settings.name == AppRoutes.home);
              },
            ),
            backgroundColor: AppColors.primaryBtn,
            duration: const Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      } else {
        // تم الإلغاء: سناك بار بسيط بدون زر
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.black87,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } else if (mounted) {
      // ❌ في حال فشل النت بنرجع لون الزر متل ما كان
      setState(() {
        _isSaved = wasSaved;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        width: 270,
        margin: const EdgeInsets.only(right: 14, top: 4, bottom: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: CachedNetworkImage(
                    imageUrl: widget.plan.image ?? '',
                    height: 135,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      height: 135,
                      color: Colors.grey.shade100,
                      child: const Center(
                        child: CircularProgressIndicator(color: AppColors.primaryBtn, strokeWidth: 2),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 135,
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.fitness_center, color: Colors.grey, size: 40),
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBtn,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'FREE',
                      style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800),
                    ),
                  ),
                ),

                // 🔖 زر السيف التفاعلي
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: _toggleSave,
                    child: Container(
                      padding: const EdgeInsets.all(7),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
                      ),
                      child: Icon(
                        _isSaved ? Icons.bookmark : Icons.bookmark_border,
                        color: AppColors.primaryBtn,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          (widget.plan.goal ?? 'Free Plan').toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.textDark),
                        ),
                      ),
                      if (widget.plan.type != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primaryBtn.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            widget.plan.type!.toUpperCase(),
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primaryBtn),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.calendar_month, size: 15, color: AppColors.primaryBtn),
                      const SizedBox(width: 4),
                      Text(
                        '${widget.plan.durationMonths ?? 1} Months',
                        style: const TextStyle(fontSize: 12, color: AppColors.hintText, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 14),
                      const Icon(Icons.fitness_center_rounded, size: 15, color: AppColors.primaryBtn),
                      const SizedBox(width: 4),
                      Text(
                        '${widget.plan.daysCount ?? 0} Days/W',
                        style: const TextStyle(fontSize: 12, color: AppColors.hintText, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}