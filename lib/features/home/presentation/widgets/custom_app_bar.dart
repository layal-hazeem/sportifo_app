// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:sportifo_app/l10n/app_localizations.dart';

import '../../../../core/widgets/wave_app_bar.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final int currentIndex;
  final String userName; // 🔥 الاسم موجود هون وجاهز
  final bool isCoach;

  const CustomAppBar({
    super.key,
    required this.currentIndex,
    required this.userName,
    required this.isCoach,
  });

  @override
  Size get preferredSize => const Size.fromHeight(150);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    String? title; // 🔥 خليناها تقبل null
    List<Widget>? actions;

    switch (currentIndex) {
      case 0:
        title = isCoach ? "Subscriptions" : l10n.progress;
        break;
      case 1:
        title = isCoach ? "Trainees" : l10n.myPlans;
        break;
      case 2:
      // 🚀 هون التعديل الأهم: خلينا الـ title = null في حالة الهوم
      // مشان الـ WaveAppBar ينفذ الـ UI الترحيبي الخاص اللي بياخد الاسم الممرر
        title = null;
        actions = [
          IconButton(
            icon: const Icon(Icons.chat, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(
              Icons.notifications_none_outlined,
              color: Colors.white,
            ),
            onPressed: () {},
          ),
        ];
        break;
      case 3:
        title = l10n.workouts;
        break;
      case 4:
        title = l10n.chat;
        break;
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return ScaleTransition(
          scale: Tween<double>(begin: 0.8, end: 1.0).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
          ),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
      child: WaveAppBar(
        key: ValueKey<int>(currentIndex),
        title: title,
        userName: userName, // 🔥 مررنا الاسم للـ WaveAppBar
        currentIndex: currentIndex, // 🔥 مررنا الـ Index ليفهم الـ WaveAppBar إننا بالهوم
        actions: actions,
        showBackButton: false,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
    );
  }
}