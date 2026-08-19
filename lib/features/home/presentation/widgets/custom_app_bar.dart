import 'package:flutter/material.dart';
import 'package:sportifo_app/l10n/app_localizations.dart';

import '../../../../core/widgets/wave_app_bar.dart';
import '../../../notifications/presentation/widgets/notification_icon_button.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final int currentIndex;
  final String userName;
  final bool isCoach;
  final VoidCallback? onHomeTap; // 🔥 كولباك العودة للهوم

  const CustomAppBar({
    super.key,
    required this.currentIndex,
    required this.userName,
    required this.isCoach,
    this.onHomeTap,
  });

  @override
  Size get preferredSize => const Size.fromHeight(150);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    String? title;
    List<Widget>? actions;

    switch (currentIndex) {
      case 0:
        title = isCoach ? l10n.sub : l10n.progress;
        break;
      case 1:
        title = isCoach ? l10n.trainees : l10n.myPlans;
        break;
      case 2:
        title = null;
        actions = [
          IconButton(
            icon: const Icon(Icons.chat, color: Colors.white),
            onPressed: () {},
          ),
          const NotificationIconButton(
            iconColor: Colors.white,
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

    // 🔥 إذا كنا خارج الهوم (currentIndex != 2)، نضيف زر الهوم ضمن الـ actions
    if (currentIndex != 2) {
      actions = [
        IconButton(
          icon: const Icon(Icons.home_rounded, color: Colors.white, size: 28),
          tooltip: l10n.home,
          onPressed: onHomeTap,
        ),
        ...?actions, // للحفاظ على باقي الأزرار إن وجدت
      ];
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
        userName: userName,
        currentIndex: currentIndex,
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