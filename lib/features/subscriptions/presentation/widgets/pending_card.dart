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
    final price = pendingSub?.subscription?.price ?? 0;
    final currency = pendingSub?.subscription?.currency ?? "SYP";

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
                    // عرض اسم الباقة وسعرها
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
                            "$planTitle ($planType)",
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF495057),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "$price $currency",
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
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
          const SizedBox(height: 12),

          // 3. أزرار التحكم (Accept / Reject) متطابقة مع التصميم
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: onAccept,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Colors.green,
                    padding: const EdgeInsets.all(12),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "Accept",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: onReject,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                    padding: const EdgeInsets.all(12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "Reject",
                    style: TextStyle(
                      color: Color(0xFFE53E3E),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
