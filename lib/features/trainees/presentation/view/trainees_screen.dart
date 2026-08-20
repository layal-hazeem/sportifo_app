import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sportifo_app/core/routes/app_routes.dart';
import 'package:sportifo_app/core/theme/app_colors.dart';
import 'package:sportifo_app/core/theme/app_theme_extensions.dart';
import 'package:sportifo_app/features/trainees/data/models/coach_plan_model.dart';
import 'package:sportifo_app/features/trainees/presentation/view_model/trainees_cubit.dart';
import 'package:sportifo_app/features/trainees/presentation/view_model/trainees_state.dart';
import 'package:sportifo_app/features/trainees/presentation/widgets/trainees_grid.dart';
import 'package:sportifo_app/features/trainees/presentation/widgets/trainees_header.dart';
import 'package:sportifo_app/l10n/app_localizations.dart';

class TraineesScreen extends StatefulWidget {
  const TraineesScreen({super.key});

  @override
  State<TraineesScreen> createState() => _TraineesScreenState();
}

class _TraineesScreenState extends State<TraineesScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TraineesCubit>().getCoachTrainees();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      body: Container(
        decoration: BoxDecoration(
          color: context.backgroundColor,
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [context.backgroundColor, context.backgroundColor],
          ),
        ),
        child: SafeArea(
          child: BlocBuilder<TraineesCubit, TraineesState>(
            builder: (context, state) {
              if (state is TraineesLoading) {
                return const _TraineesLoading();
              }

              if (state is TraineesFailure) {
                return _TraineesError(
                  message: state.message,
                  onRetry: () {
                    context.read<TraineesCubit>().getCoachTrainees();
                  },
                );
              }

              if (state is TraineesSuccess) {
                return _TraineesContent(plans: state.response.data);
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }
}

class _TraineesContent extends StatelessWidget {
  final List<CoachPlanModel> plans;

  const _TraineesContent({required this.plans});

  List<CoachPlanModel> get _latestPlansPerTrainee {
    final Map<int, CoachPlanModel> latestMap = {};

    for (final plan in plans) {
      final userId = plan.user?.id;

      if (userId == null) continue;

      if (!latestMap.containsKey(userId)) {
        latestMap[userId] = plan;
      } else {
        final existingPlanId = latestMap[userId]?.id ?? 0;
        final currentPlanId = plan.id ?? 0;

        if (currentPlanId > existingPlanId) {
          latestMap[userId] = plan;
        }
      }
    }

    return latestMap.values.toList();
  }

  int get uniqueTraineesCount {
    return _latestPlansPerTrainee.length;
  }

  @override
  Widget build(BuildContext context) {
    final filteredPlans = _latestPlansPerTrainee;

    return Column(
      children: [
        TraineesHeader(count: uniqueTraineesCount),

        Expanded(
          child: RefreshIndicator(
            color: AppColors.primaryBtn,
            backgroundColor: context.backgroundColor,

            onRefresh: () async {
              await context.read<TraineesCubit>().getCoachTrainees();
            },

            child: TraineesGrid(
              plans: filteredPlans,
              onTraineeTap: (plan) => _openPlan(context, plan),
            ),
          ),
        ),
      ],
    );
  }

  void _openPlan(BuildContext context, CoachPlanModel plan) {
    final planId = plan.id;

    if (planId == null) {
      return;
    }

    Navigator.pushNamed(context, AppRoutes.planDetails, arguments: planId);
  }
}

class _TraineesLoading extends StatelessWidget {
  const _TraineesLoading();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 5),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              Container(
                width: 170,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.primaryBtn.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),

              const Spacer(),

              Container(
                width: 65,
                height: 65,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryBtn.withOpacity(0.08),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 40),

        Expanded(
          child: Center(
            child: CircularProgressIndicator(color: AppColors.primaryBtn),
          ),
        ),
      ],
    );
  }
}

class _TraineesError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _TraineesError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: AppColors.primaryBtn.withOpacity(0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.cloud_off_rounded,
                size: 48,
                color: AppColors.primaryBtn,
              ),
            ),

            const SizedBox(height: 20),

            Text(
              l10n.couldntLoadTrainees,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: context.textColor,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.hintText),
            ),

            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, color: Colors.white),
              label: Text(
                l10n.tryAgain,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBtn,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 13,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
