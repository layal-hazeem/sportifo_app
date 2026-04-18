// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

import 'package:sportifo_app/core/theme/app_colors.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final int currentIndex;
  final String userName;

  const CustomAppBar({
    super.key,
    required this.currentIndex,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    return _buildBody(context);
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  Widget _buildBody(BuildContext context) {
    switch (currentIndex) {
      case 2:
        return AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          // title: Text("أهلاً \"$userName\"", style: const TextStyle(color: Colors.black)),
          actions: [
            IconButton(
              icon: const Icon(Icons.chat, color: AppColors.primaryBtn),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(
                Icons.notifications_none_outlined,
                color: AppColors.primaryBtn,
              ),
              onPressed: () {},
            ),
            const SizedBox(width: 8),
          ],
        );
      default:
        return AppBar(title: const Text("Sportifo"));
    }
  }
}
