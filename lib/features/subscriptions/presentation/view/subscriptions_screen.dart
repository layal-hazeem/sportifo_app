import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sportifo_app/core/routes/app_routes.dart';
import 'package:sportifo_app/core/theme/app_colors.dart';
import 'package:sportifo_app/features/auth/presentation/widgets/custom_button.dart';
import 'package:sportifo_app/features/subscriptions/data/models/users_subscribed_model.dart';
import 'package:sportifo_app/features/subscriptions/presentation/widgets/pending_card.dart';
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

            final pendingSubscriptions = allUsers.where((user) {
              return user.userSubscriptions?.any(
                    (sub) =>
                        sub.status?.toLowerCase() == 'pending' &&
                        (sub.isActive ?? 0) == 0,
                  ) ??
                  false;
            }).toList();

            final activeSubscriptions = allUsers.where((user) {
  return user.userSubscriptions?.any(
        (sub) =>
            sub.status?.toLowerCase() == 'active' &&
            (sub.isActive ?? 0) == 1,
      ) ??
      false;
}).toList();

            return RefreshIndicator(
              onRefresh: () async {
                context.read<SubscriptionCubit>().getSubscriptions();
              },
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 20.0,
                ),
                children: [
                  _buildPendingSection(pendingSubscriptions),

                  const SizedBox(height: 24),

                  _buildActiveSection(activeSubscriptions),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildPendingSection(List<UsersSubscribedModel> pendingList) {
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth * 0.8;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.pendingApproval,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            if (pendingList.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF0F0),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "${pendingList.length} ${l10n.actionRequired}",
                  style: const TextStyle(
                    color: Color(0xFF8A1F1F),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        pendingList.isEmpty
            ? Text(l10n.noPendingSubscriptions)
            : SizedBox(
                height: 160,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: pendingList.length,
                  itemBuilder: (context, index) {
                    final user = pendingList[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 12.0),
                      child: SizedBox(
                        width: cardWidth,
                        child: PendingCard(
                          user: user,
                        ),
                      ),
                    );
                  },
                ),
              ),
      ],
    );
  }

  Widget _buildActiveSection(List<UsersSubscribedModel> activeList) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.activeSubscriptions,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 16),
        activeList.isEmpty
            ? Padding(
                padding: EdgeInsets.symmetric(vertical: 20.0),
                child: Center(
                  child: Text(
                    l10n.noPendingSubscriptions,
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              )
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: activeList.length,
                itemBuilder: (context, index) {
                  final user = activeList[index];
                  return SubscriptionCard(
  userModel: user,
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
}
