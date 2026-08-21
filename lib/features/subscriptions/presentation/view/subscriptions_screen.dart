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
      body: RefreshIndicator(
        color: AppColors.primaryBtn,
        backgroundColor: context.backgroundColor,
        onRefresh: () async {
          await context.read<SubscriptionCubit>().refreshSubscriptions();
        },
        child: BlocBuilder<SubscriptionCubit, SubscriptionState>(
          builder: (context, state) {
            if (state is SubscriptionLoading) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(
                    height: 300,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryBtn,
                      ),
                    ),
                  ),
                ],
              );
            }

            if (state is SubscriptionError) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.7,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // نفس محتوى الخطأ عندك
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }

            if (state is SubscriptionSuccess) {
              final allUsers = state.usersWithSubscriptions;

              final activeSubscriptions = _getActiveSubscriptions(allUsers);

              final historySubscriptions = _getRecentHistory(allUsers);

              final needsPlanCount = activeSubscriptions.where((item) {
                return (item.subscription.countPlan ?? 0) == 0;
              }).length;

              return CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
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
                                          style: const TextStyle(
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
                                    onTap: () {
                                      setState(() {
                                        _selectedFilterIndex = 0;
                                      });
                                    },
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: _buildFilterTab(
                                    title: l10n.history,
                                    count: historySubscriptions.length,
                                    isSelected: _selectedFilterIndex == 1,
                                    onTap: () {
                                      setState(() {
                                        _selectedFilterIndex = 1;
                                      });
                                    },
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
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  // ============================================================
  // FILTER TAB
  // ============================================================

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

  // ============================================================
  // ACTIVE SECTION
  // ============================================================

  Widget _buildActiveSectionSliver(List<_SubscriptionItem> activeList) {
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
          final item = activeList[index];

          return SubscriptionCard(
            userModel: item.user,
            subscription: item.subscription,
            isHistory: false,
            onCreatePlan: () async {
              final result = await Navigator.pushNamed(
                context,
                AppRoutes.createPlan,
                arguments: item.user,
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

  // ============================================================
  // HISTORY SECTION
  // ============================================================

  Widget _buildHistorySectionSliver(List<_SubscriptionItem> historyList) {
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
          final item = historyList[index];

          return SubscriptionCard(
            userModel: item.user,
            subscription: item.subscription,
            isHistory: true,
            onCreatePlan: () {},
          );
        }, childCount: historyList.length),
      ),
    );
  }

  // ============================================================
  // EMPTY SECTION
  // ============================================================

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

  // ============================================================
  // ACTIVE SUBSCRIPTIONS
  // ============================================================

  List<_SubscriptionItem> _getActiveSubscriptions(
    List<UsersSubscribedModel> allUsers,
  ) {
    final result = <_SubscriptionItem>[];

    for (final user in allUsers) {
      final subscriptions = user.userSubscriptions ?? [];

      for (final subscription in subscriptions) {
        if (_isActiveSubscription(subscription)) {
          result.add(_SubscriptionItem(user: user, subscription: subscription));
        }
      }
    }

    return result;
  }

  // ============================================================
  // ACTIVE CONDITION
  // ============================================================

  bool _isActiveSubscription(UserSubscription sub) {
    final status = sub.status?.trim().toLowerCase();

    return status == 'active' && sub.isActive == 1;
  }

  // ============================================================
  // HISTORY
  // ============================================================

  List<_SubscriptionItem> _getRecentHistory(
    List<UsersSubscribedModel> allUsers,
  ) {
    final now = DateTime.now();
    final result = <_SubscriptionItem>[];

    for (final user in allUsers) {
      final subscriptions = user.userSubscriptions ?? [];

      for (final subscription in subscriptions) {
        final endDate = subscription.endDate;

        if (endDate == null) continue;

        if (endDate.isBefore(now)) {
          result.add(_SubscriptionItem(user: user, subscription: subscription));
        }
      }
    }

    return result;
  }
}

// ================================================================
// UI ITEM
// ================================================================

class _SubscriptionItem {
  final UsersSubscribedModel user;
  final UserSubscription subscription;

  const _SubscriptionItem({required this.user, required this.subscription});
}
