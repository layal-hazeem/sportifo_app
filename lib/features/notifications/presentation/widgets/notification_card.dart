import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/notification_model.dart';

class NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback? onTap;

  const NotificationCard({
    super.key,
    required this.notification,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // تمييز الإشعار الغير مقروء بلون خلفية وإطار مميز
    final isUnread = !notification.isRead;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isUnread ? AppColors.primaryBtn.withOpacity(0.06) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUnread ? AppColors.primaryBtn.withOpacity(0.3) : Colors.grey.shade200,
          width: isUnread ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🖼️ الأيقونة أو الصورة
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isUnread
                        ? AppColors.primaryBtn.withOpacity(0.15)
                        : Colors.grey.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: notification.iconUrl != null && notification.iconUrl!.isNotEmpty
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Image.network(
                      notification.iconUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildDefaultIcon(isUnread),
                    ),
                  )
                      : _buildDefaultIcon(isUnread),
                ),
                const SizedBox(width: 12),

                // 📝 المحتوى (العنوان + النص + الوقت)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: isUnread ? FontWeight.w800 : FontWeight.w600,
                                color: AppColors.textDark,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isUnread)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.primaryBtn,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        notification.body,
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.4,
                          color: isUnread ? Colors.black87 : Colors.grey.shade600,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _formatDate(notification.createdAt),
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultIcon(bool isUnread) {
    return Icon(
      Icons.notifications_active_rounded,
      color: isUnread ? AppColors.primaryBtn : Colors.grey.shade500,
      size: 22,
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inMinutes < 1) return 'Just now';
      if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
      if (difference.inHours < 24) return '${difference.inHours}h ago';
      if (difference.inDays < 7) return '${difference.inDays}d ago';
      return '${date.day}/${date.month}/${date.year}';
    } catch (_) {
      return dateStr;
    }
  }
}