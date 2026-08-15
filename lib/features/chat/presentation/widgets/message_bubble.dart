import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sportifo_app/core/utils/url_fixer.dart';
import '../../data/models/message_model.dart';

class MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isSentByCurrentUser;
  final bool canDelete;
  final VoidCallback? onDelete;
  final VoidCallback? onShowDetails;

  const MessageBubble({
    Key? key,
    required this.message,
    required this.isSentByCurrentUser,
    required this.canDelete,
    this.onDelete,
    this.onShowDetails,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (message.isDeleted) {
      return _buildDeletedMessage();
    }

    return Align(
      alignment: isSentByCurrentUser
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: GestureDetector(
        onLongPress: () {
          if (canDelete && isSentByCurrentUser) {
            onDelete?.call();
          }
        },
        onTap: () {
          if (isSentByCurrentUser) {
            onShowDetails?.call();
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.70,
            ),
            decoration: BoxDecoration(
              color: isSentByCurrentUser
                  ? const Color(0xFFFF9800)
                  : const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(18),
                topRight: const Radius.circular(18),
                bottomLeft: Radius.circular(
                  isSentByCurrentUser ? 18 : 4,
                ),
                bottomRight: Radius.circular(
                  isSentByCurrentUser ? 4 : 18,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 10,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // عرض الصور
                if (message.media.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: message.media.map((mediaItem) {
                        String? url;
                        if (mediaItem is Map) {
                          url = mediaItem['url']?.toString();
                        } else {
                          url = mediaItem.toString();
                        }
                        if (url == null || url.isEmpty) {
                          return const SizedBox.shrink();
                        }
                        final fixedUrl = UrlFixer.image(url);
                        if (fixedUrl == null) {
                          return const SizedBox.shrink();
                        }
                        return GestureDetector(
                          onTap: () => _showFullImage(context, fixedUrl),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: CachedNetworkImage(
                              imageUrl: fixedUrl,
                              width: 150,
                              height: 150,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                width: 150,
                                height: 150,
                                color: Colors.grey.shade300,
                                child: const Icon(Icons.image, color: Colors.grey),
                              ),
                              errorWidget: (context, url, error) => Container(
                                width: 150,
                                height: 150,
                                color: Colors.grey.shade200,
                                child: const Icon(Icons.broken_image, color: Colors.red),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                // عرض النص
                if (message.body.isNotEmpty)
                  Text(
                    message.body,
                    style: TextStyle(
                      color: isSentByCurrentUser
                          ? Colors.white
                          : Colors.black87,
                      fontSize: 15,
                      height: 1.3,
                    ),
                  ),
                const SizedBox(height: 6),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      message.getFormattedTime(),
                      style: TextStyle(
                        fontSize: 11,
                        color: isSentByCurrentUser
                            ? Colors.white.withOpacity(0.8)
                            : Colors.grey.shade500,
                      ),
                    ),
                    if (isSentByCurrentUser) ...[
                      const SizedBox(width: 4),
                      _buildStatusIcon(),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIcon() {
    final status = message.getStatus();
    if (status == 2) {
      return const Icon(Icons.done_all, size: 14, color: Colors.lightBlueAccent);
    } else if (status == 1) {
      return Icon(Icons.done_all, size: 14, color: Colors.white.withOpacity(0.7));
    } else {
      return Icon(Icons.done, size: 14, color: Colors.white.withOpacity(0.7));
    }
  }

  Widget _buildDeletedMessage() {
    return Align(
      alignment: isSentByCurrentUser
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.block,
                size: 14,
                color: Colors.grey.shade500,
              ),
              const SizedBox(width: 6),
              Text(
                'تم حذف هذه الرسالة',
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFullImage(BuildContext context, String imageUrl) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black87,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return Scaffold(
          backgroundColor: Colors.black,
          body: SafeArea(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Center(
                  child: InteractiveViewer(
                    minScale: 0.5,
                    maxScale: 4.0,
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.contain,
                      placeholder: (context, url) => const CircularProgressIndicator(
                        color: Colors.white,
                      ),
                      errorWidget: (context, url, error) => const Icon(
                        Icons.error,
                        color: Colors.white,
                        size: 48,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 28),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(
          opacity: anim1,
          child: child,
        );
      },
    );
  }
}