import 'package:flutter/material.dart';
import '../../data/models/users_subscribed_model.dart'; // تأكد من مطابقة مسار الموديل لديك

class PendingCard extends StatelessWidget {
  final UsersSubscribedModel user;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const PendingCard({
    super.key,
    required this.user,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    // استخراج الاشتراك الذي حالته pending و isActive == 0 لتعرض بياناته
    final pendingSub = user.userSubscriptions?.firstWhere(
      (sub) => sub.status?.toLowerCase() == 'pending' && sub.isActive == 0,
    );

    final planTitle = pendingSub?.subscription?.title ?? "Unknown Plan";
    final planType = pendingSub?.subscription?.type?.toUpperCase() ?? "";
    final currency = pendingSub?.subscription?.currency ?? "SYP";

    Color planColor;
    IconData planIcon;
    switch (planType) {
      case 'gold':
        planColor = const Color(0xFFFFB300); // ذهبي
        planIcon = Icons.stars_rounded;
        break;
      case 'silver':
        planColor = const Color(0xFF78909C); // فضي
        planIcon = Icons.workspace_premium_rounded;
        break;
      case 'bronze':
      default:
        planColor = const Color(0xffa87c43); // برونزي
        planIcon = Icons.emoji_events_rounded;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border(
          left: BorderSide(color: planColor.withOpacity(0.4), width: 4),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 1. صورة المستخدم الشخصية مع التعامل مع الصورة الفارغة (Null)
              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.grey.shade200,
                backgroundImage:
                    user.profilePic != null && user.profilePic!.isNotEmpty
                    ? NetworkImage(user.profilePic!)
                    : null,
                child: user.profilePic == null || user.profilePic!.isEmpty
                    ? const Icon(Icons.person, color: Colors.grey, size: 28)
                    : null,
              ),
              const SizedBox(width: 14),

              // 2. تفاصيل اسم المشترك ورقم هاتفه والخطة المطلوبة
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${user.firstName ?? ''} ${user.lastName ?? ''}".trim(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.phone ?? "No phone number",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F3F5),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            "$planTitle",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: planColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFEDF2F7)),
        ],
      ),
    );
  }
}
