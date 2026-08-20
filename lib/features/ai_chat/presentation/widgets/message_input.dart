import 'package:flutter/material.dart';
import 'package:sportifo_app/core/theme/app_theme_extensions.dart';
import 'package:sportifo_app/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';

class MessageInput extends StatelessWidget {
  final TextEditingController controller;
  final void Function(String) onSend;
  final VoidCallback? onCancel;
  final bool isSending;

  const MessageInput({
    super.key,
    required this.controller,
    required this.onSend,
    this.onCancel,
    this.isSending = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: context.backgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                enabled: !isSending,
                textInputAction: TextInputAction.send,
                onSubmitted: isSending ? null : onSend,
                maxLines: 4,
                minLines: 1,
                decoration: InputDecoration(
                  hintText: isSending ? l10n.sending_hint : l10n.ask_ai_hint,
                  filled: true,
                  fillColor: context.backgroundColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(
                      color: context.textColor.withValues(alpha: 0.15),
                      width: 1,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(
                      color: context.textColor.withValues(alpha: 0.15),
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(
                      color: AppColors.primaryBtn.withValues(alpha: 0.7),
                      width: 1.5,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: isSending ? onCancel : () => onSend(controller.text),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSending ? Colors.red.shade400 : AppColors.primaryBtn,
                  shape: BoxShape.circle,
                ),
                child: isSending
                    ? const Icon(
                        Icons.stop_rounded,
                        color: Colors.white,
                        size: 22,
                      )
                    : const Icon(Icons.send, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
