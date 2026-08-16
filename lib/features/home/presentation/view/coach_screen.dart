import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:sportifo_app/core/di/service_locator.dart';
import 'package:sportifo_app/core/theme/app_colors.dart';
import 'package:sportifo_app/features/%20ads/presentation/widgets/ads_carousel_widget.dart';
import 'package:sportifo_app/features/home/presentation/widgets/empty_state_widget.dart';
import 'package:sportifo_app/features/subscriptions/data/models/users_subscribed_model.dart';
import 'package:sportifo_app/l10n/app_localizations.dart';

import '../view_model/coach_home_cubit.dart';
import '../view_model/coach_home_state.dart';
import '../widgets/coach_greeting_header.dart';
import '../widgets/coach_stats_row.dart';
import '../widgets/clients_preview_section.dart';
import '../widgets/coach_home_skeleton.dart';
import '../widgets/quick_actions_section.dart';

class CoachHomeScreen extends StatelessWidget {
  final ValueChanged<int> onNavigate;
  final ValueChanged<UsersSubscribedModel>? onClientTap;

  const CoachHomeScreen({
    super.key,
    required this.onNavigate,
    this.onClientTap,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<CoachHomeCubit>()..loadHomeData(),
      child: _CoachHomeView(onNavigate: onNavigate, onClientTap: onClientTap),
    );
  }
}

class _CoachHomeView extends StatelessWidget {
  final ValueChanged<int> onNavigate;
  final ValueChanged<UsersSubscribedModel>? onClientTap;

  const _CoachHomeView({required this.onNavigate, this.onClientTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocBuilder<CoachHomeCubit, CoachHomeState>(
      builder: (context, state) {
        if (state is CoachHomeLoading) {
          return const CoachHomeSkeleton();
        }

        if (state is CoachHomeError) {
          return Center(
            child: EmptyStateWidget(
              icon: Icons.error_outline_rounded,
              message: state.message,
              actionLabel: l10n.tryAgain,
              onAction: () => context.read<CoachHomeCubit>().loadHomeData(),
              height: 240,
            ),
          );
        }

        if (state is CoachHomeLoaded) {
          final coach = state.coach;
          final clients = state.clients
              .where((client) => client.hasPlan == true)
              .toList();

          return RefreshIndicator(
            color: AppColors.primaryBtn,
            onRefresh: () => context.read<CoachHomeCubit>().loadHomeData(),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              children: [
                CoachGreetingHeader(
                  coachName: coach.fullName,
                  coachImageUrl: coach.profilePic.isNotEmpty
                      ? coach.profilePic
                      : null,
                  notificationCount: state.notificationsCount,
                  onNotificationTap: () {},
                ),

                const SizedBox(height: 18),

                CoachStatsRow(clients: clients),

                const SizedBox(height: 18),

                ClientsPreviewSection(
                  clients: clients,
                  onSeeAllTap: () => onNavigate(1),
                  onClientTap: (client) {
                    onClientTap?.call(client);
                  },
                ),

                const SizedBox(height: 18),

                QuickActionsSection(onSubscriptionsTap: () => onNavigate(0)),

                const SizedBox(height: 18),

                const AdsCarouselWidget(),

                const SizedBox(height: 10),
              ],
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
