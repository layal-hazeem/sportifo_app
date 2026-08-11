import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sportifo_app/core/theme/app_colors.dart';
import 'package:sportifo_app/features/plan_details/data/models/plan_details_model.dart';
import 'package:sportifo_app/features/plan_details/presentation/view_model/plan_details_cubit.dart';
import 'package:sportifo_app/features/plan_details/presentation/view_model/plan_details_state.dart';
import 'package:sportifo_app/features/plan_details/presentation/widgets/plan_command_center.dart';
import 'package:sportifo_app/features/plan_details/presentation/widgets/plan_day_selector.dart';
import 'package:sportifo_app/features/plan_details/presentation/widgets/plan_exercise_widgets.dart';

class PlanDetailsScreen extends StatefulWidget {
  final int planId;

  const PlanDetailsScreen({super.key, required this.planId});

  @override
  State<PlanDetailsScreen> createState() => _PlanDetailsScreenState();
}

class _PlanDetailsScreenState extends State<PlanDetailsScreen> {
  int selectedDayIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocBuilder<PlanDetailsCubit, PlanDetailsState>(
          builder: (context, state) {
            if (state is PlanDetailsLoading || state is PlanDetailsInitial) {
              return const _PlanDetailsLoading();
            }

            if (state is PlanDetailsFailure) {
              return _PlanDetailsError(
                message: state.message,
                onRetry: () {
                  context.read<PlanDetailsCubit>().getPlanDetails(
                    widget.planId,
                  );
                },
              );
            }

            if (state is PlanDetailsSuccess) {
              final plan = state.response.data;

              if (plan == null) {
                return const _PlanDetailsEmpty();
              }

              if (plan.days.isEmpty) {
                return _PlanDetailsNoDays(plan: plan);
              }

              if (selectedDayIndex >= plan.days.length) {
                selectedDayIndex = 0;
              }

              final selectedDay = plan.days[selectedDayIndex];

              return RefreshIndicator(
                color: AppColors.primaryBtn,
                backgroundColor: Colors.white,
                onRefresh: () {
                  return context.read<PlanDetailsCubit>().getPlanDetails(
                    widget.planId,
                  );
                },
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  slivers: [
                    SliverToBoxAdapter(child: _TopBar(planId: plan.id)),

                    const SliverToBoxAdapter(child: SizedBox(height: 4)),

                    SliverToBoxAdapter(child: PlanCommandCenter(plan: plan)),

                    const SliverToBoxAdapter(child: SizedBox(height: 22)),

                    SliverToBoxAdapter(
                      child: PlanDaySelector(
                        days: plan.days,
                        selectedIndex: selectedDayIndex,
                        onDaySelected: (index) {
                          setState(() {
                            selectedDayIndex = index;
                          });
                        },
                      ),
                    ),

                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSizes.mainPadding,
                          24,
                          AppSizes.mainPadding,
                          16,
                        ),
                        child: _MissionHeader(day: selectedDay),
                      ),
                    ),

                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSizes.mainPadding,
                        0,
                        AppSizes.mainPadding,
                        36,
                      ),
                      sliver: PlanExerciseMatrix(
                        exercises: selectedDay.exercises,
                      ),
                    ),
                  ],
                ),
              );
            }

            return const _PlanDetailsEmpty();
          },
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final int planId;

  const _TopBar({required this.planId});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 4),
      child: Row(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.black.withOpacity(.06)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(.04),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: AppColors.textDark,
                  size: 17,
                ),
              ),
            ),
          ),

          const Spacer(),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'TRAINING BLUEPRINT',
                style: TextStyle(
                  color: AppColors.hintText,
                  fontSize: 8.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.7,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'PLAN #$planId',
                style: const TextStyle(
                  color: AppColors.textDark,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MissionHeader extends StatelessWidget {
  final PlanDayModel day;

  const _MissionHeader({required this.day});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'CURRENT MISSION',
                style: TextStyle(
                  color: AppColors.primaryBtn,
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.7,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                day.name.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textDark,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -.7,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Text(
          '${day.exercises.length.toString().padLeft(2, '0')} EXERCISES',
          style: const TextStyle(
            color: AppColors.hintText,
            fontSize: 9,
            fontWeight: FontWeight.w800,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }
}

class _PlanDetailsLoading extends StatelessWidget {
  const _PlanDetailsLoading();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(
                color: AppColors.primaryBtn.withOpacity(.25),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryBtn.withOpacity(.10),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Center(
              child: SizedBox(
                width: 25,
                height: 25,
                child: CircularProgressIndicator(
                  strokeWidth: 2.3,
                  color: AppColors.primaryBtn,
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'LOADING BLUEPRINT',
            style: TextStyle(
              color: AppColors.hintText,
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.8,
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanDetailsError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _PlanDetailsError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.mainPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.primaryBtn.withOpacity(.09),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.warning_amber_rounded,
                color: AppColors.primaryBtn,
                size: 38,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'BLUEPRINT UNAVAILABLE',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textDark,
                fontSize: 14,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 9),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.hintText,
                fontSize: 13,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 22),
            SizedBox(
              height: 46,
              child: ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBtn,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'RETRY',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    letterSpacing: .8,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanDetailsEmpty extends StatelessWidget {
  const _PlanDetailsEmpty();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'No plan data available',
        style: TextStyle(color: AppColors.hintText, fontSize: 14),
      ),
    );
  }
}

class _PlanDetailsNoDays extends StatelessWidget {
  final PlanDetailsModel plan;

  const _PlanDetailsNoDays({required this.plan});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        const SliverToBoxAdapter(child: SizedBox(height: 10)),
        SliverToBoxAdapter(child: PlanCommandCenter(plan: plan)),
        const SliverFillRemaining(
          child: Center(
            child: Text(
              'No training days assigned',
              style: TextStyle(color: AppColors.hintText, fontSize: 14),
            ),
          ),
        ),
      ],
    );
  }
}
