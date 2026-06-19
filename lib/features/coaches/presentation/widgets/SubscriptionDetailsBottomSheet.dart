// lib/features/coaches/presentation/widgets/subscription_details_bottom_sheet.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import '../../data/models/subscription_model.dart';

class SubscriptionDetailsBottomSheet extends StatelessWidget {
  final SubscriptionModel subscription;

  const SubscriptionDetailsBottomSheet({super.key, required this.subscription});

  // دالة الاستدعاء الذكية السريعة من أي مكان بكود تفاصيل الكوتش
  static void show(BuildContext context, SubscriptionModel subscription) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.15),
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: SubscriptionDetailsBottomSheet(subscription: subscription),
        );
      },
    );
  }

  // تدرجات ألوان الباقات بنسخة Light ناعمة ومتناسقة
  List<Color> _getTypeGradients(String type) {
    switch (type.toLowerCase()) {
      case 'gold':
        return [const Color(0xFFFFD700), const Color(0xFFFFB300)];
      case 'silver':
        return [const Color(0xFFE0E0E0), const Color(0xFFB8B8B8)];
      case 'bronze':
        return [const Color(0xFFE5A65D), const Color(0xFFCD7F32)];
      default:
        return [const Color(0xFFFF8A65), const Color(0xFFFF6B35)];
    }
  }

  @override
  Widget build(BuildContext context) {
    final planColors = _getTypeGradients(subscription.type);
    const mainAppColor = Color(0xFFFF6B35); // لون تطبيق سبورتيفو الأساسي
    final screenHeight = MediaQuery.of(context).size.height;

    return DraggableScrollableSheet(
      initialChildSize: 0.65, // يفتح على 65% من الشاشة بشكل متناسق ومريح
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Stack(
            children: [
              // 🌌 1. الخلفية الضبابية العلوية (Glassmorphic Top)
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                    child: Container(
                      color: Colors.black.withOpacity(0.08),
                    ),
                  ),
                ),
              ),

              // 📜 2. محتوى الـ Sheet بالكامل
              ListView(
                controller: scrollController,
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.zero,
                children: [
                  // مقبض السحب العلوي الأنيق
                  const SizedBox(height: 12),
                  Center(
                    child: Container(
                      width: 45,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // 💎 شارة نوع الباقة تطفو بشكل فخم فوق الجزء الشفاف
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: planColors),
                        borderRadius: BorderRadius.circular(50),
                        boxShadow: [
                          BoxShadow(
                            color: planColors[0].withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.workspace_premium, color: Colors.white, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            subscription.type.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 12,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ⬜ 3. الحاوية البيضاء المريحة للعين (Light Premium Body)
                  Container(
                    width: double.infinity,
                    constraints: BoxConstraints(minHeight: screenHeight * 0.5),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF9FAFC), // درجة رمادي ناعمة جداً
                      borderRadius: BorderRadius.vertical(top: Radius.circular(35)),
                    ),
                    padding: const EdgeInsets.fromLTRB(24, 30, 24, 120), // بدينج مريح مع مساحة للزر السفلي
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // اسم وعنوان الباقة
                        Center(
                          child: Text(
                            subscription.title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // عرض السعر والعملة بشكل واضح وبطل بصرياً
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              "${subscription.price}",
                              style: const TextStyle(
                                fontSize: 44,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF1A1A1A),
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              subscription.currency,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: mainAppColor,
                              ),
                            ),
                          ],
                        ),

                        // مدة صلاحية الباقة تحت السعر مباشرة
                        Center(
                          child: Text(
                            "VALID FOR ${subscription.months} MONTH(S)",
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.black.withOpacity(0.35),
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                        const SizedBox(height: 35),

                        // مؤشر مميزات الباقة (Plan Benefits)
                        Row(
                          children: [
                            Container(
                              width: 4,
                              height: 16,
                              decoration: BoxDecoration(
                                color: mainAppColor,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              "Plan Benefits",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A1A1A),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // كارد الوصف والنقاط
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.black.withOpacity(0.02),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.01),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.check_circle,
                                color: Color(0xFF00C853),
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  subscription.description.isNotEmpty
                                      ? subscription.description
                                      : "This premium plan includes fully customized workouts, direct chat with the coach, and weekly progress tracking.",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF4A4A4A),
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // 💳 4. زر المتابعة للاشتراك المثبت بالأسفل تماماً
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(24, 15, 24, 30),
                  color: const Color(0xFFF9FAFC), // نفس لون الحاوية لدمج متناسق
                  child: Container(
                    width: double.infinity,
                    height: 54,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [mainAppColor, Color(0xFFFF5216)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: mainAppColor.withOpacity(0.25),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context); // نغلق الـ Sheet
                        // هنا ننتقل لواجهة تحديد الشهور وحساب التكلفة 🚀
                      },
                      child: const Text(
                        "Proceed to Subscription",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}