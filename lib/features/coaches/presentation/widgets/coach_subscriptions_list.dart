// lib/features/coaches/presentation/widgets/coach_subscriptions_list.dart

import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/subscription_model.dart';
// 👇 قمنا بإضافة هذا الـ import لنستدعي الـ BottomSheet الجديد
import 'SubscriptionDetailsBottomSheet.dart';

class CoachSubscriptionsList extends StatelessWidget {
  final List<SubscriptionModel> subscriptions;

  const CoachSubscriptionsList({super.key, required this.subscriptions});

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'gold':
        return const Color(0xFFFFD700);
      case 'silver':
        return const Color(0xFFC0C0C0);
      case 'bronze':
        return const Color(0xFFCD7F32);
      default:
        return AppColors.primaryBtn;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (subscriptions.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            "Available Subscriptions",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
              letterSpacing: 0.3,
            ),
          ),
        ),
        const SizedBox(height: 15),
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: subscriptions.length,
            itemBuilder: (context, index) {
              final sub = subscriptions[index];
              return Padding(
                padding: const EdgeInsets.only(right: 15),
                child: GestureDetector(
                  // 🎯 التعديل السحري هنا عند الضغط على الكارد 🎯
                  onTap: () {
                    // 👇 استدعاء الـ BottomSheet لعرض التفاصيل بشكل ضبابي احترافي دون مغادرة الصفحة
                    SubscriptionDetailsBottomSheet.show(context, sub);
                  },
                  child: Neumorphic(
                    style: NeumorphicStyle(
                      depth: 4,
                      boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(15)),
                      color: const Color(0xFFF7F7F7),
                      lightSource: LightSource.topLeft,
                    ),
                    child: Container(
                      width: 140,
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.workspace_premium, color: _getTypeColor(sub.type), size: 30),
                          const SizedBox(height: 8),
                          Text(
                            sub.title,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            "${sub.price} ${sub.currency}",
                            style: TextStyle(color: AppColors.primaryBtn, fontWeight: FontWeight.w600, fontSize: 14),
                          ),
                          Text(
                            "${sub.months} Month(s)",
                            style: const TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}