import 'package:flutter/material.dart';

class MessageInputField extends StatelessWidget {
  final TextEditingController controller;
  final bool enabled;
  final bool isLoading;
  final VoidCallback onSend;
  final ValueChanged<String>? onChanged;
  final String? disabledReason;
  final VoidCallback? onImageTap; // 🔥 جديد

  const MessageInputField({
    Key? key,
    required this.controller,
    required this.onSend,
    this.enabled = true,
    this.isLoading = false,
    this.onChanged,
    this.disabledReason,
    this.onImageTap, // 🔥 جديد
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!enabled && disabledReason != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  disabledReason!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.orange, fontSize: 12),
                ),
              ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.image,
                    color: enabled && !isLoading
                        ? const Color(0xFFFF9800)
                        : Colors.grey.shade400,
                  ),
                  onPressed: enabled && !isLoading ? onImageTap : null, // 🔥 ربط
                ),
                Expanded(
                  child: TextField(
                    controller: controller,
                    enabled: enabled && !isLoading,
                    onChanged: onChanged,
                    maxLines: null,
                    minLines: 1,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => enabled && !isLoading ? onSend() : null,
                    decoration: InputDecoration(
                      hintText: isLoading
                          ? 'جاري الإرسال...'
                          : (enabled ? 'اكتب رسالة...' : 'لا يمكنك الإرسال'),
                      hintStyle: TextStyle(color: Colors.grey.shade400),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF2F2F2),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: enabled && !isLoading ? onSend : null,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: enabled && !isLoading
                          ? const Color(0xFFFF9800)
                          : Colors.grey.shade300,
                      shape: BoxShape.circle,
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : Icon(
                            Icons.send,
                            color: enabled
                                ? Colors.white
                                : Colors.grey.shade500,
                            size: 20,
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}