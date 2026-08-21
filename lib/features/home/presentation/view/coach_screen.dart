import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:sportifo_app/core/di/service_locator.dart';
import 'package:sportifo_app/core/theme/app_colors.dart';
import 'package:sportifo_app/core/theme/app_theme_extensions.dart';
import 'package:sportifo_app/features/%20ads/presentation/widgets/ads_carousel_widget.dart';
import 'package:sportifo_app/features/home/presentation/widgets/empty_state_widget.dart';
import 'package:sportifo_app/features/subscriptions/data/models/users_subscribed_model.dart';
import 'package:sportifo_app/l10n/app_localizations.dart';

import 'package:sportifo_app/features/platform_plans/presentation/view_model/platform_plans_cubit.dart';
import 'package:sportifo_app/features/platform_plans/presentation/widgets/platform_plans_section.dart';

import 'package:sportifo_app/features/coaches/presentation/view_model/coaches_cubit.dart';
import 'package:sportifo_app/features/coaches/presentation/view_model/coaches_state.dart';
import 'package:sportifo_app/features/coaches/presentation/views/all_coaches_screen.dart';
import 'package:sportifo_app/features/coaches/presentation/views/coach_details_screen.dart';
import 'package:sportifo_app/features/coaches/presentation/widgets/coach_card.dart';

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
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<CoachHomeCubit>()..loadHomeData()),
        BlocProvider.value(
          value: getIt<PlatformPlansCubit>()..fetchPlatformPlans(),
        ),
        BlocProvider.value(value: getIt<CoachesCubit>()..fetchCoaches()),
      ],
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

                const PlatformPlansSection(),

                const SizedBox(height: 18),

                _CoachHomeCoachesSection(),

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

class _CoachHomeCoachesSection extends StatelessWidget {
  const _CoachHomeCoachesSection();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<CoachesCubit, CoachesState>(
      builder: (context, state) {
        if (state is CoachesLoading) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: CircularProgressIndicator(color: AppColors.primaryBtn),
            ),
          );
        }

        if (state is CoachesLoaded) {
          final coaches = state.coaches;

          if (coaches.isEmpty) {
            return const SizedBox.shrink();
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.coaches,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: context.textColor,
                      ),
                    ),

                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AllCoachesScreen(),
                          ),
                        );
                      },
                      child: Text(
                        l10n.see_all,
                        style: const TextStyle(
                          color: AppColors.primaryBtn,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 4),

              SizedBox(
                height: 175,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 0),
                  itemCount: coaches.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final coach = coaches[index];

                    return CoachCard(
                      coach: coach,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                CoachDetailsScreen(coachId: coach.id),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        }

        if (state is CoachesError) {
          return const SizedBox.shrink();
        }

        return const SizedBox.shrink();
      },
    );
  }
}
