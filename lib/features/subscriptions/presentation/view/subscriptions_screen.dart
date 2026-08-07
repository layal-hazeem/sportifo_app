import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sportifo_app/core/routes/app_routes.dart';
import 'package:sportifo_app/core/theme/app_colors.dart';
import 'package:sportifo_app/features/auth/presentation/widgets/custom_button.dart';
import 'package:sportifo_app/features/subscriptions/data/models/users_subscribed_model.dart';
import 'package:sportifo_app/features/subscriptions/presentation/widgets/subscription_card.dart';
import 'package:sportifo_app/l10n/app_localizations.dart';
import '../view_model/subscription_cubit.dart';

class SubscriptionsScreen extends StatefulWidget {
  const SubscriptionsScreen({super.key});

  @override
  State<SubscriptionsScreen> createState() => _SubscriptionsScreenState();
}

class _SubscriptionsScreenState extends State<SubscriptionsScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,

      body: BlocBuilder<SubscriptionCubit, SubscriptionState>(
        builder: (context, state) {
          if (state is SubscriptionLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryBtn),
            );
          }

          if (state is SubscriptionError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),

                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,

                      children: [
                        Icon(
                          Icons.wifi_off,
                          size: 50,
                          color: Colors.grey.shade400,
                        ),

                        const SizedBox(height: 10),

                        const Text(
                          "No Internet Connection",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 8,
                          ),

                          child: Text(
                            "Please check your network settings and try again.",
                            textAlign: TextAlign.center,

                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                  ),

                  CustomAuthButton(
                    isFullWidth: false,
                    text: l10n.retry,

                    onPressed: () {
                      context.read<SubscriptionCubit>().getSubscriptions();
                    },
                  ),
                ],
              ),
            );
          }

          if (state is SubscriptionSuccess) {
            final allUsers = state.usersWithSubscriptions;

            final activeSubscriptions = _getActiveSubscriptions(allUsers);

            final historySubscriptions = _getRecentHistory(allUsers);

            return RefreshIndicator(
              color: AppColors.primaryBtn,

              onRefresh: () async {
                await context.read<SubscriptionCubit>().getSubscriptions();
              },

              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20,
                ),

                children: [
                  _buildActiveSection(activeSubscriptions),

                  if (historySubscriptions.isNotEmpty) ...[
                    const SizedBox(height: 30),

                    _buildHistorySection(historySubscriptions),
                  ],
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  // ============================================================
  // ACTIVE SUBSCRIPTIONS
  // ============================================================

  List<UsersSubscribedModel> _getActiveSubscriptions(
    List<UsersSubscribedModel> allUsers,
  ) {
    final now = DateTime.now();

    return allUsers.where((user) {
      return user.userSubscriptions?.any((sub) {
            final endDate = sub.endDate;

            return sub.status?.toLowerCase() == 'active' &&
                (sub.isActive ?? 0) == 1 &&
                endDate != null &&
                !endDate.isBefore(now);
          }) ??
          false;
    }).toList();
  }

  // ============================================================
  // RECENT HISTORY
  // ============================================================

  List<UsersSubscribedModel> _getRecentHistory(
    List<UsersSubscribedModel> allUsers,
  ) {
    final now = DateTime.now();

    final oneMonthAgo = DateTime(
      now.year,
      now.month - 1,
      now.day,
      now.hour,
      now.minute,
      now.second,
    );

    return allUsers.where((user) {
      return user.userSubscriptions?.any((sub) {
            final endDate = sub.endDate;

            if (endDate == null) {
              return false;
            }

            final status = sub.status?.toLowerCase();

            // لازم يكون اشتراك منتهي
            final isFinished = status == 'active' && endDate.isBefore(now);

            if (!isFinished) {
              return false;
            }

            // انتهى خلال آخر شهر فقط
            return endDate.isAfter(oneMonthAgo);
          }) ??
          false;
    }).toList();
  }

  // ============================================================
  // ACTIVE SECTION
  // ============================================================

  Widget _buildActiveSection(List<UsersSubscribedModel> activeList) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        Row(
          children: [
            Container(
              width: 42,
              height: 42,

              decoration: BoxDecoration(
                color: AppColors.primaryBtn.withOpacity(.12),
                borderRadius: BorderRadius.circular(13),
              ),

              child: const Icon(
                Icons.workspace_premium_rounded,
                color: AppColors.primaryBtn,
              ),
            ),

            const SizedBox(width: 12),

            Text(
              l10n.activeSubscriptions,

              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        if (activeList.isEmpty)
          _emptySection(
            icon: Icons.card_membership_outlined,
            text: "No active subscriptions",
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),

            itemCount: activeList.length,

            itemBuilder: (context, index) {
              final user = activeList[index];

              return SubscriptionCard(
                userModel: user,

                isHistory: false,

                onCreatePlan: () async {
                  final result = await Navigator.pushNamed(
                    context,
                    AppRoutes.createPlan,
                    arguments: user,
                  );

                  if (result == true) {
                    context.read<SubscriptionCubit>().getSubscriptions();
                  }
                },
              );
            },
          ),
      ],
    );
  }

  // ============================================================
  // HISTORY SECTION
  // ============================================================

  Widget _buildHistorySection(List<UsersSubscribedModel> historyList) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        Row(
          children: [
            Container(
              width: 42,
              height: 42,

              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(.12),
                borderRadius: BorderRadius.circular(13),
              ),

              child: Icon(Icons.history_rounded, color: Colors.grey.shade600),
            ),

            const SizedBox(width: 12),

            const Text(
              "Recent History",

              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),

        const SizedBox(height: 6),

        Text(
          "Subscriptions that ended during the last month",

          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),

        const SizedBox(height: 16),

        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),

          itemCount: historyList.length,

          itemBuilder: (context, index) {
            final user = historyList[index];

            return SubscriptionCard(
              userModel: user,

              // مهم جداً
              // هذا يمنع زر Create Plan
              isHistory: true,

              onCreatePlan: () {},
            );
          },
        ),
      ],
    );
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _emptySection({required IconData icon, required String text}) {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),

        border: Border.all(color: Colors.grey.shade200),
      ),

      child: Column(
        children: [
          Icon(icon, size: 40, color: Colors.grey.shade400),

          const SizedBox(height: 10),

          Text(
            text,

            style: TextStyle(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
