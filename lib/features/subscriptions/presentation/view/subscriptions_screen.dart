import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sportifo_app/core/routes/app_routes.dart';
import 'package:sportifo_app/core/theme/app_colors.dart';
import 'package:sportifo_app/core/theme/app_theme_extensions.dart';
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
  int _selectedFilterIndex = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: context.backgroundColor,
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
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: context.textColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.checkYourNetwork,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.hintText),
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

            final needsPlanCount = activeSubscriptions.where((user) {
              final activeSub = user.userSubscriptions?.where(
                (sub) => sub.status?.trim().toLowerCase() == 'active',
              );

              if (activeSub == null || activeSub.isEmpty) return false;

              return activeSub.any((sub) => (sub.countPlan ?? 0) == 0);
            }).length;

            return RefreshIndicator(
              color: AppColors.primaryBtn,
              backgroundColor: context.backgroundColor,
              onRefresh: () async {
                await context.read<SubscriptionCubit>().getSubscriptions();
              },
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (needsPlanCount > 0) ...[
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.amber.shade50,
                                    Colors.amber.shade100.withOpacity(0.5),
                                  ],
                                ),
                                border: Border.all(
                                  color: Colors.amber.shade300,
                                ),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.amber.withOpacity(0.08),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.amber.shade200.withOpacity(
                                        0.5,
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.warning_amber_rounded,
                                      color: Colors.amber.shade800,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          l10n.actionRequired,
                                          style: TextStyle(
                                            color: context.textColor,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          l10n.subscribersNeedPlan(
                                            needsPlanCount,
                                          ),
                                          style: TextStyle(
                                            color: AppColors.hintText,
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.w500,
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

                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: context.backgroundColor,
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(color: Colors.grey.shade200),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.02),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: _buildFilterTab(
                                    title: l10n.active,
                                    count: activeSubscriptions.length,
                                    isSelected: _selectedFilterIndex == 0,
                                    onTap: () => setState(
                                      () => _selectedFilterIndex = 0,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: _buildFilterTab(
                                    title: l10n.history,
                                    count: historySubscriptions.length,
                                    isSelected: _selectedFilterIndex == 1,
                                    onTap: () => setState(
                                      () => _selectedFilterIndex = 1,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
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
    required int count,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: 8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryBtn : context.backgroundColor,
          borderRadius: BorderRadius.circular(30),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primaryBtn.withOpacity(0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(
                color: isSelected ? context.textColor : AppColors.hintText,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                fontSize: 14,
              ),
            ),
            if (count >= 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withOpacity(0.25)
                      : context.backgroundColor.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(30),
                  border: isSelected
                      ? null
                      : Border.all(color: Colors.grey.shade200),
                ),
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    color: isSelected ? context.textColor : AppColors.hintText,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ],
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

              if (result == true && mounted) {
                context.read<SubscriptionCubit>().getSubscriptions();
              }
            },
          );
        }, childCount: activeList.length),
      ),
    );
  }

  Widget _buildHistorySectionSliver(List<UsersSubscribedModel> historyList) {
    final l10n = AppLocalizations.of(context)!;
    if (historyList.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: _emptySection(
            icon: Icons.history_rounded,
            text: l10n.noRecentExpiredPlansHistoryFound,
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
      padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 40, color: Colors.grey.shade400),
          ),
          const SizedBox(height: 16),
          Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w600,
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
            final status = sub.status?.trim().toLowerCase();

            final startDate = sub.startDate;
            final endDate = sub.endDate;

            if (status != 'active') return false;

            if (startDate != null && startDate.isAfter(now)) {
              return false;
            }
            if (endDate != null && endDate.isBefore(now)) {
              return false;
            }

            return true;
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
