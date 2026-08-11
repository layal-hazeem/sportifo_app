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
  int _selectedFilterIndex = 0; // 0: Active, 1: History

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: BlocBuilder<SubscriptionCubit, SubscriptionState>(
        builder: (context, state) {
          if (state is SubscriptionLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryBtn),
            );
          }

          if (state is SubscriptionError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
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
                        Icons.wifi_off_rounded,
                        size: 48,
                        color: AppColors.primaryBtn,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.noInternet,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.checkYourNetwork,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 24),
                    CustomAuthButton(
                      isFullWidth: false,
                      text: l10n.retry,
                      onPressed: () {
                        context.read<SubscriptionCubit>().getSubscriptions();
                      },
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is SubscriptionSuccess) {
            final allUsers = state.usersWithSubscriptions;
            final activeSubscriptions = _getActiveSubscriptions(allUsers);
            final historySubscriptions = _getRecentHistory(allUsers);

            // الاعتماد الصريح والآمن على حقل hasPlan القادم من الباك إند
            final needsPlanCount = activeSubscriptions.where((u) {
              final hasActiveSub =
                  u.userSubscriptions?.any(
                    (sub) => sub.status?.toLowerCase() == 'active',
                  ) ??
                  false;
              final notHasPlan = (u.hasPlan ?? false) == false;
              return hasActiveSub && notHasPlan;
            }).length;

            return RefreshIndicator(
              color: AppColors.primaryBtn,
              backgroundColor: Colors.white,
              onRefresh: () async {
                await context.read<SubscriptionCubit>().getSubscriptions();
              },
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (needsPlanCount > 0) ...[
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.amber.shade50,
                                border: Border.all(
                                  color: Colors.amber.shade400,
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.warning_amber_rounded,
                                    color: Colors.amber.shade700,
                                    size: 28,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "Action Required",
                                          style: TextStyle(
                                            color: Color(0xFF1E293B),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          "You have $needsPlanCount active subscribers who don't have a training plan yet.",
                                          style: TextStyle(
                                            color: Colors.grey.shade700,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],

                          Row(
                            children: [
                              Expanded(
                                child: _buildFilterTab(
                                  title:
                                      "Active (${activeSubscriptions.length})",
                                  isSelected: _selectedFilterIndex == 0,
                                  onTap: () =>
                                      setState(() => _selectedFilterIndex = 0),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildFilterTab(
                                  title:
                                      "History (${historySubscriptions.length})",
                                  isSelected: _selectedFilterIndex == 1,
                                  onTap: () =>
                                      setState(() => _selectedFilterIndex = 1),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),

                  _selectedFilterIndex == 0
                      ? _buildActiveSectionSliver(activeSubscriptions)
                      : _buildHistorySectionSliver(historySubscriptions),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildFilterTab({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(vertical: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryBtn : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.primaryBtn : Colors.grey.shade300,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primaryBtn.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade700,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildActiveSectionSliver(List<UsersSubscribedModel> activeList) {
    final l10n = AppLocalizations.of(context)!;

    if (activeList.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: _emptySection(
            icon: Icons.card_membership_outlined,
            text: l10n.noActiveSubscriptions,
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
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
                if (mounted) {
                  context.read<SubscriptionCubit>().getSubscriptions();
                }
              }
            },
          );
        }, childCount: activeList.length),
      ),
    );
  }

  Widget _buildHistorySectionSliver(List<UsersSubscribedModel> historyList) {
    if (historyList.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: _emptySection(
            icon: Icons.history_rounded,
            text: "No recent expired history found",
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final user = historyList[index];
          return SubscriptionCard(
            userModel: user,
            isHistory: true,
            onCreatePlan: () {},
          );
        }, childCount: historyList.length),
      ),
    );
  }

  Widget _emptySection({required IconData icon, required String text}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(icon, size: 48, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

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

  List<UsersSubscribedModel> _getRecentHistory(
    List<UsersSubscribedModel> allUsers,
  ) {
    final now = DateTime.now();
    final oneMonthAgo = now.subtract(const Duration(days: 30));

    return allUsers.where((user) {
      return user.userSubscriptions?.any((sub) {
            final endDate = sub.endDate;
            if (endDate == null) return false;

            final isExpired = endDate.isBefore(now);
            final isRecent = endDate.isAfter(oneMonthAgo);

            return isExpired && isRecent;
          }) ??
          false;
    }).toList();
  }
}
