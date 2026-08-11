import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sportifo_app/core/di/service_locator.dart';

import '../theme/app_colors.dart';

class WaveAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final int? currentIndex;
  final bool? isCoach;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showBackButton;

  const WaveAppBar({
    super.key,
    this.title,
    this.currentIndex,
    this.isCoach,
    this.actions,
    this.leading,
    this.showBackButton = true,
  });

  String _getAppBarTitle() {
    if (title != null) {
      return title!;
    }
    final String? role = getIt<SharedPreferences>().getString('user_role');
    final bool userIsCoach = isCoach ?? (role == 'coach');
    switch (currentIndex) {
      case 0:
        return (!userIsCoach) ? "Subscriptions" : "Progress";
      case 1:
        return (!userIsCoach) ? "Trainees" :"My Plans";
      case 2:
        return "Home";
      case 3:
        return "Workouts";
      case 4:
        return "Chat";
      default:
        return "Sportifo";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 1. رسم الموجة
        ClipPath(
          clipper: WaveClipper(), // تأكدي أن هذا الاسم مطابق للكلاس أدناه
          child: Container(
            height: 150,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primaryBtn, // البرتقالي الأساسي
                  Color(0xFFFF9D42),
                ],
              ),
            ),
          ),
        ),
        // 2. المحتوى
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: SizedBox(
              height: 60, // تحديد ارتفاع منطقة الأزرار
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        if (leading != null)
                          leading!
                        else if (showBackButton)
                          IconButton(
                            icon: const Icon(
                              Icons.arrow_back_ios_new,
                              color: Colors.white,
                              size: 20,
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            _getAppBarTitle(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (actions != null) Row(children: actions!),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(150);
}

// تأكدي أن هذا الكلاس خارج حدود كلاس WaveAppBar
class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 40);

    var firstControlPoint = Offset(size.width / 4, size.height);
    var firstEndPoint = Offset(size.width / 2.25, size.height - 30);
    path.quadraticBezierTo(
      firstControlPoint.dx,
      firstControlPoint.dy,
      firstEndPoint.dx,
      firstEndPoint.dy,
    );

    var secondControlPoint = Offset(
      size.width - (size.width / 3.25),
      size.height - 80,
    );
    var secondEndPoint = Offset(size.width, size.height - 40);
    path.quadraticBezierTo(
      secondControlPoint.dx,
      secondControlPoint.dy,
      secondEndPoint.dx,
      secondEndPoint.dy,
    );

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
