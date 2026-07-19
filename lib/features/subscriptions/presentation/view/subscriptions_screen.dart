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
              color: AppColors.primaryBtn,

              onRefresh: () async {
                context.read<SubscriptionCubit>().getSubscriptions();
              },

              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20,
                ),

                children: [_buildActiveSection(activeSubscriptions)],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
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
