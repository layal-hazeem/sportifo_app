import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/routes/app_routes.dart'; // 👈 عدلي المسار حسب مشروعك
import '../../../../core/theme/app_colors.dart';
import '../view_model/notifications_cubit.dart';
import '../view_model/notifications_state.dart';

class NotificationIconButton extends StatefulWidget {
  final Color iconColor;

  const NotificationIconButton({
    super.key,
    this.iconColor = Colors.white,
  });

  @override
  State<NotificationIconButton> createState() => _NotificationIconButtonState();
}

class _NotificationIconButtonState extends State<NotificationIconButton> {
  @override
  void initState() {
    super.initState();
    // جلب عدد الإشعارات الغير مقروءة فور إنشاء الأيقونة
    context.read<NotificationsCubit>().getUnreadCount();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationsCubit, NotificationsState>(
      buildWhen: (previous, current) => current is UnreadCountSuccess || current is NotificationsSuccess,
      builder: (context, state) {
        final count = context.read<NotificationsCubit>().unreadCount;

        return Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: Icon(
                count > 0 ? Icons.notifications_active_outlined : Icons.notifications_none_outlined,
                color: widget.iconColor,
                size: 26,
              ),
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.notifications).then((_) {
                  // تحديث العداد عند العودة من شاشة الإشعارات
                  if (context.mounted) {
                    context.read<NotificationsCubit>().getUnreadCount();
                  }
                });
              },
            ),
            if (count > 0)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.redAccent,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 18,
                    minHeight: 18,
                  ),
                  child: Text(
                    count > 99 ? '+99' : '$count',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}