import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sportifo_app/core/di/service_locator.dart';

import '../theme/app_colors.dart';

class WaveAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final String? userName;
  final int? currentIndex;
  final bool? isCoach;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showBackButton;

  const WaveAppBar({
    super.key,
    this.title,
    this.userName,
    this.currentIndex,
    this.isCoach,
    this.actions,
    this.leading,
    this.showBackButton = true,
  });
  Widget _getAppBarTitleWidget() {
    if (title != null) {
      return Text(
        title!,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 25,
          fontWeight: FontWeight.bold,
        ),
        overflow: TextOverflow.ellipsis,
      );
    }

    final String? role = getIt<SharedPreferences>().getString('user_role');
    final bool userIsCoach = isCoach ?? (role == 'coach');

    String defaultTitle = "Sportifo";

    switch (currentIndex) {
      case 0:
        defaultTitle = (!userIsCoach) ? "Subscriptions" : "Progress";
        break;
      case 1:
        defaultTitle = (!userIsCoach) ? "Trainees" : "My Plans";
        break;
      case 2:
        final name = (userName != null && userName!.isNotEmpty) ? userName! : "Champion";
        return RichText(
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          text: TextSpan(
            text: "Welcome, ",
            style: TextStyle(
              color: Colors.white.withOpacity(0.85),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            children: [
              TextSpan(
                text: name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        );
      case 3:
        defaultTitle = "Workouts";
        break;
      case 4:
        defaultTitle = "Chat";
        break;
    }

    return Text(
      defaultTitle,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 25,
        fontWeight: FontWeight.bold,
      ),
      overflow: TextOverflow.ellipsis,
    );
  }
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipPath(
          clipper: WaveClipper(),
          child: Container(
            height: 150,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primaryBtn,
                  Color(0xFFFF9D42),
                ],
              ),
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5), // حواف مريحة
            child: SizedBox(
              height: 65,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
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
                          child: _getAppBarTitleWidget(), // 🔥 استدعاء واجهة النصوص هنا
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