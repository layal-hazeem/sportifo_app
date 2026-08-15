import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sportifo_app/core/di/service_locator.dart';
import 'package:sportifo_app/core/storage/local_storage.dart';
import 'package:sportifo_app/core/utils/url_fixer.dart';
import 'package:sportifo_app/features/chat/data/models/message_model.dart';
import '../../data/models/conversation_model.dart';

class ConversationTile extends StatelessWidget {
  final ConversationModel conversation;
  final VoidCallback onTap;

  const ConversationTile({
    Key? key,
    required this.conversation,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final fixedProfilePic = UrlFixer.image(conversation.otherParticipant.profilePic);
    final currentUserId = getIt<LocalStorage>().getUserId();

    // تحديد ما إذا كانت آخر رسالة مرسلة مني
    final bool isSentByMe = conversation.lastMessage != null &&
        currentUserId != null &&
        conversation.lastMessage!.senderId == currentUserId;

    // تحديد ما إذا كانت آخر رسالة غير مقروءة (مرسلة من الطرف الآخر و readAt == null)
    final bool isUnread = conversation.lastMessage != null &&
        currentUserId != null &&
        conversation.lastMessage!.senderId != currentUserId &&
        conversation.lastMessage!.readAt == null;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // صورة الطرف الآخر
            CircleAvatar(
              radius: 28,
              backgroundColor: Colors.grey.shade300,
              backgroundImage: fixedProfilePic != null
                  ? CachedNetworkImageProvider(fixedProfilePic)
                  : const AssetImage('assets/images/female.jpg') as ImageProvider,
              child: fixedProfilePic == null
                  ? const Icon(Icons.person, color: Colors.grey, size: 28)
                  : null,
            ),
            const SizedBox(width: 12),
            // النصوص (الاسم، معاينة الرسالة، الوقت)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          conversation.otherParticipant.name,
                          style: TextStyle(
                            fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
                            fontSize: 15,
                            color: isUnread ? Colors.black87 : Colors.black54,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // 🔥 نقطة برتقالية فقط إذا كانت الرسالة غير مقروءة
                      if (isUnread)
                        Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFF9800), // برتقالي
                            shape: BoxShape.circle,
                          ),
                        ),
                      const SizedBox(width: 8),
                      Text(
                        _formatTime(conversation),
                        style: TextStyle(
                          fontSize: 12,
                          color: isUnread ? Colors.black87 : Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      // 🔥 مؤشرات التوصيل/القراءة فقط إذا كانت الرسالة مرسلة مني
                      if (isSentByMe && conversation.lastMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: _buildStatusIcon(conversation.lastMessage!),
                        ),
                      Expanded(
                        child: Text(
                          conversation.getLastMessagePreview(),
                          style: TextStyle(
                            color: isUnread ? Colors.black87 : Colors.grey.shade600,
                            fontSize: 13,
                            fontWeight: isUnread ? FontWeight.w500 : FontWeight.normal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
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

  // 🔥 أيقونة حالة الرسالة (للمرسلة مني فقط)
  Widget _buildStatusIcon(MessageModel message) {
    final status = message.getStatus();
    if (status == 2) {
      // مقروءة (read_at موجود)
      return const Icon(Icons.done_all, size: 14, color: Colors.blue);
    } else if (status == 1) {
      // موصلة (delivered_at موجود)
      return Icon(Icons.done_all, size: 14, color: Colors.grey.shade500);
    } else {
      // مرسلة (sent_at فقط)
      return Icon(Icons.done, size: 14, color: Colors.grey.shade500);
    }
  }

  // 🔥 تنسيق الوقت
  String _formatTime(ConversationModel conversation) {
    final lastMessage = conversation.lastMessage;
    if (lastMessage == null || lastMessage.sentAt == null) return '';

    final msgDateStr = lastMessage.sentAt!['date'] ?? '';
    final msgTimeStr = lastMessage.sentAt!['time'] ?? '';
    if (msgDateStr.isEmpty) return '';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    try {
      final msgDate = DateTime.parse(msgDateStr);
      final msgDateOnly = DateTime(msgDate.year, msgDate.month, msgDate.day);

      if (msgDateOnly == today) return msgTimeStr;
      return msgDateStr;
    } catch (e) {
      return msgTimeStr;
    }
  }
}