// lib/features/chat/presentation/widgets/message_date_separator.dart

import 'package:flutter/material.dart';
import 'package:sportifo_app/core/theme/app_theme_extensions.dart';

class MessageDateSeparator extends StatelessWidget {
  final String date;

  const MessageDateSeparator({
    Key? key,
    required this.date,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dividerColor = context.textColor.withValues(alpha:0.2);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 1,
              color: dividerColor, // بدل Colors.grey[300]
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              date,
              style: TextStyle(
                fontSize: 12,
                color: context.textColor.withValues(alpha:0.6), // بدل Colors.grey[600]
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: 1,
              color: dividerColor, // بدل Colors.grey[300]
            ),
          ),
        ],
      ),
    );
  }
}