import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sportifo_app/core/routes/app_routes.dart';
import 'package:sportifo_app/core/theme/app_colors.dart';
import 'package:sportifo_app/core/theme/app_theme_extensions.dart';
import 'package:sportifo_app/features/plan_details/data/models/plan_details_model.dart';
import 'package:sportifo_app/features/plan_details/presentation/view_model/plan_details_cubit.dart';
import 'package:sportifo_app/features/plan_details/presentation/view_model/plan_details_state.dart';
import 'package:sportifo_app/features/plan_details/presentation/widgets/plan_command_center.dart';
import 'package:sportifo_app/features/plan_details/presentation/widgets/plan_day_selector.dart';
import 'package:sportifo_app/features/plan_details/presentation/widgets/plan_exercise_widgets.dart';
import 'package:sportifo_app/l10n/app_localizations.dart';

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
      backgroundColor: context.backgroundColor,
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

              if (plan == null) return const _PlanDetailsEmpty();
              if (plan.days.isEmpty) return _PlanDetailsNoDays(plan: plan);

              if (selectedDayIndex >= plan.days.length) {
                selectedDayIndex = 0;
              }

              final selectedDay = plan.days[selectedDayIndex];

              return RefreshIndicator(
                color: AppColors.primaryBtn,
                backgroundColor: Colors.white,
                onRefresh: () => context
                    .read<PlanDetailsCubit>()
                    .getPlanDetails(widget.planId),
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  slivers: [
                    SliverToBoxAdapter(
                      child: _TopBar(
                        planId: plan.id,
                        onEditTap: () async {
                          final result = await Navigator.pushNamed(
                            context,
                            AppRoutes.editCoachPlan,
                            arguments: plan,
                          );

                          if (result == true && mounted) {
                            await context
                                .read<PlanDetailsCubit>()
                                .getPlanDetails(widget.planId);
                          }
                        },
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 8)),
                    SliverToBoxAdapter(child: PlanCommandCenter(plan: plan)),
                    const SliverToBoxAdapter(child: SizedBox(height: 20)),
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
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 14),
                        child: _MissionHeader(day: selectedDay),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
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
  final VoidCallback? onEditTap;

  const _TopBar({required this.planId, this.onEditTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      child: Row(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: context.backgroundColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: context.backgroundColor),
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: context.textColor,
                size: 17,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Center(
                child: Text(
                  l10n.blueprint,
                  style: TextStyle(
                    color: AppColors.hintText,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${l10n.plan} #$planId',
                style: TextStyle(
                  color: context.textColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const Spacer(),
          _EditPlanButton(onTap: onEditTap),
        ],
      ),
    );
  }
}

class _EditPlanButton extends StatelessWidget {
  final VoidCallback? onTap;

  const _EditPlanButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        decoration: BoxDecoration(
          color: AppColors.primaryBtn,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.edit_rounded, color: context.textColor, size: 16),
            const SizedBox(width: 6),
            Text(
              l10n.editPlan,
              style: TextStyle(
                color: context.textColor,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
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
              Text(
                day.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: context.textColor,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
        Text(
          '${day.exercises.length} exercises',
          style: const TextStyle(
            color: AppColors.hintText,
            fontSize: 12,
            fontWeight: FontWeight.w700,
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
    return const Center(
      child: CircularProgressIndicator(color: AppColors.primaryBtn),
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
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: AppColors.primaryBtn,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.hintText, fontSize: 14),
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
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
    return const Center(
      child: Text(
        'No training days assigned',
        style: TextStyle(color: AppColors.hintText, fontSize: 14),
      ),
    );
  }
}
