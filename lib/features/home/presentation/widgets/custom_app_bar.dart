// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:sportifo_app/core/theme/app_colors.dart';
import 'package:sportifo_app/l10n/app_localizations.dart';

import '../../../../core/widgets/wave_app_bar.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final int currentIndex;
  final String userName;
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

    String title = "";
    List<Widget>? actions;

    switch (currentIndex) {
      case 0:
        title = isCoach ? "Subscriptions" : l10n.progress;
        break;
      case 1:
        title = l10n.myPlans;
        break;
      case 2:
        title = l10n.welcomeBack;
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
          // 2. أنيميشن الـ Fade (شفافية)
          child: FadeTransition(
            opacity: animation,
            // 3. لمسة دورات بسيطة جداً (اختياري، إذا ما حبيتيها فيكِ تمسحي RotationTransition)
            // child: RotationTransition(
            //   turns: Tween<double>(begin: -0.02, end: 0.0).animate(
            //     CurvedAnimation(parent: animation, curve: Curves.easeOut),
            //   ),
            child: child,
          ),
        );
      },
      child: WaveAppBar(
        key: ValueKey<int>(currentIndex),
        title: title,
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
