import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sportifo_app/core/theme/app_theme_extensions.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/no_internet_view.dart'; // ✅ استدعاء الودجت الموحدة
import '../view_model/notifications_cubit.dart';
import '../view_model/notifications_state.dart';
import '../widgets/notification_card.dart';
import '../widgets/notifications_shimmer.dart';
import '../../../../l10n/app_localizations.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          getIt<NotificationsCubit>()..getNotifications(isRefresh: true),
      child: const _NotificationsView(),
    );
  }
}

class _NotificationsView extends StatefulWidget {
  const _NotificationsView();

  @override
  State<_NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<_NotificationsView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<NotificationsCubit>().getNotifications();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        title: Text(
          l10n.notifications,
          style: TextStyle(
            color: context.textColor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.primaryBtn,
        elevation: 0.5,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: context.textColor,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocBuilder<NotificationsCubit, NotificationsState>(
        builder: (context, state) {
          final cubit = context.read<NotificationsCubit>();

          // ⏳ تحميل أول مرة (ما في بيانات سابقة)
          if (state is NotificationsLoading &&
              cubit.notificationsList.isEmpty) {
            return const NotificationsShimmerLoading();
          }

          // ✅✅✅ هون عدلنا: إذا فشل التحميل وما في بيانات مخزنة سابقاً
          // بنعرض NoInternetView الموحدة بدل الـ Center القديم
          if (state is NotificationsError && cubit.notificationsList.isEmpty) {
            return NoInternetView(
              onRetry: () => cubit.getNotifications(isRefresh: true),
              title: l10n.notifications_unableToLoadTitle,
              subtitle: l10n.notifications_unableToLoadSubtitle,
            );
          }

          // 📭 قائمة فارغة (نجاح بس ما في إشعارات)
          if (cubit.notificationsList.isEmpty) {
            return RefreshIndicator(
              color: AppColors.primaryBtn,
              onRefresh: () async => cubit.getNotifications(isRefresh: true),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.25),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.primaryBtn.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.notifications_off_outlined,
                            size: 64,
                            color: AppColors.primaryBtn,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l10n.notifications_emptyTitle,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: context.textColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.notifications_emptySubtitle,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }

          // ✅ في بيانات: نعرض اللستة
          return RefreshIndicator(
            color: AppColors.primaryBtn,
            onRefresh: () async => cubit.getNotifications(isRefresh: true),
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              itemCount:
                  cubit.notificationsList.length +
                  (state is NotificationsPaginationLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == cubit.notificationsList.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryBtn,
                      ),
                    ),
                  );
                }

                final notification = cubit.notificationsList[index];

                return NotificationCard(
                  notification: notification,
                  onTap: () {
                    if (notification.deepLink != null &&
                        notification.deepLink!.isNotEmpty) {
                      // يمكنك استخدام دالة _handleDeepLink هنا
                    }
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}