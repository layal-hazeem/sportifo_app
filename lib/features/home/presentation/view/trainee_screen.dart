import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sportifo_app/features/platform_plans/presentation/view_model/platform_plans_cubit.dart';
import 'package:sportifo_app/l10n/app_localizations.dart';
import '../../../ ads/presentation/view_model/ads_cubit.dart';
import '../../../ ads/presentation/widgets/ads_carousel_widget.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/widgets/loading_shimmer.dart';
import '../../../coaches/presentation/view_model/coaches_cubit.dart';
import '../../../coaches/presentation/view_model/coaches_state.dart';
import '../../../coaches/presentation/views/all_coaches_screen.dart';
import '../../../coaches/presentation/views/coach_details_screen.dart';
import '../../../coaches/presentation/widgets/coach_card.dart';

// 🔥 الاستيرادات الجديدة الخاصة بالأهداف الذكية
import '../../../platform_plans/presentation/widgets/platform_plans_section.dart';
import '../../../targets/presentation/view_model/target_cubit/target_cubit.dart';
import '../../../targets/presentation/view_model/target_cubit/target_state.dart';
import '../../../targets/presentation/widgets/daily_nutrition_card.dart';
import '../../../targets/presentation/widgets/target_activation_card.dart';
import '../../../nutrition/presentation/view_model/nutrition_cubit.dart';
import '../../../nutrition/presentation/view_model/nutrition_state.dart';
import '../../../nutrition/data/models/food_log_model.dart';

class TraineeScreen extends StatefulWidget {
  const TraineeScreen({super.key});

  @override
  State<TraineeScreen> createState() => _TraineeScreenState();
}

class _TraineeScreenState extends State<TraineeScreen> with WidgetsBindingObserver {
  late final NutritionCubit _nutritionCubit;

  @override
  void initState() {
    super.initState();
    _nutritionCubit = getIt<NutritionCubit>();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _nutritionCubit.fetchTodayFoodLogs(forceRefresh: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => getIt<AdsCubit>()),
        BlocProvider(create: (context) => getIt<TargetCubit>()..fetchLatestTarget()),
        BlocProvider(create: (context) => _nutritionCubit..initialize()),
// 🔥 استبدلي السطر القديم بهذا السطر:
        BlocProvider.value(value: getIt<PlatformPlansCubit>()..fetchPlatformPlans()),      ],
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            const AdsCarouselWidget(),
            const SizedBox(height: 10),
            BlocBuilder<TargetCubit, TargetState>(
              builder: (context, targetState) {
                if (targetState is TargetLoading) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: LoadingShimmer(width: double.infinity, height: 160, borderRadius: 24),
                  );
                } else if (targetState is TargetSuccess) {
                  return BlocBuilder<NutritionCubit, NutritionState>(
                    builder: (context, nutritionState) {
                      if (nutritionState is NutritionLoading ||
                          nutritionState is NutritionInitial) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          child: LoadingShimmer(
                            width: double.infinity,
                            height: 160,
                            borderRadius: 24,
                          ),
                        );
                      }

                      TotalMacros? consumed;
                      if (nutritionState is NutritionSuccess) {
                        consumed = nutritionState.foodLogs.total;
                      } else if (nutritionState is AddMealSuccess) {
                        consumed = nutritionState.mealResponse.total;
                      } else if (nutritionState is DeleteMealSuccess) {
                        consumed = nutritionState.mealResponse.total;
                      }

                      return DailyNutritionCard(
                        target: targetState.targetData,
                        consumedToday: consumed,
                      );
                    },
                  );
                } else {
                  return const TargetActivationCard();
                }
              },
            ),
            const PlatformPlansSection(),

            const SizedBox(height: 15),

            BlocProvider(
              create: (context) => getIt<CoachesCubit>()..fetchCoaches(),
              child: BlocBuilder<CoachesCubit, CoachesState>(
                builder: (context, state) {
                  if (state is CoachesLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is CoachesLoaded) {
                    final coaches = state.coaches;
                    if (coaches.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                l10n.coaches,
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const AllCoachesScreen()),
                                  );
                                },
                                child: Text(l10n.see_all),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 175,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
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
                                      builder: (_) => CoachDetailsScreen(coachId: coach.id),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  } else if (state is CoachesError) {
                    return Center(child: Text('${l10n.error}: ${state.message}'));
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}