import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sportifo_app/core/di/service_locator.dart';
import 'package:sportifo_app/core/theme/app_colors.dart';
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
  static bool isUserCoach() {
    String? role = getIt<SharedPreferences>().getString('user_role');
    return role == 'coach';
  }

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
                  Text(
                    state.errorMessage,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<SubscriptionCubit>().getSubscriptions();
                    },
                    child: Text(l10n.retry),
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
                        sub.isActive == 0,
                  ) ??
                  false;
            }).toList();

            final activeSubscriptions = allUsers.where((user) {
              return user.userSubscriptions?.any((sub) => sub.isActive == 1) ??
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

  Widget _buildPendingSection(List<dynamic> pendingList) {
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
                          onAccept: () {
                            print("Accepted user: ${user.firstName}");
                          },
                          onReject: () {
                            print("Rejected user: ${user.firstName}");
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
      ],
    );
  }

  Widget _buildActiveSection(List<dynamic> activeList) {
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
                  final user = activeList[index] as UsersSubscribedModel;

                  return SubscriptionCard(
                    userModel: user,
                  );
                },
              ),
      ],
    );
  }
}
