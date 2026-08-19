import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sportifo_app/core/theme/app_theme_extensions.dart';
import 'package:sportifo_app/features/progress/presentation/view_model/exercise_filter_params.dart';
import 'package:sportifo_app/features/progress/presentation/widgets/exercise_activity_section.dart';
import 'package:sportifo_app/features/progress/presentation/widgets/weight_progress_section.dart';
import 'package:sportifo_app/l10n/app_localizations.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/loading_shimmer.dart';
import '../view_model/exercise_activity_cubit.dart';
import '../view_model/exercise_activity_state.dart';
import '../view_model/weight_progress_cubit.dart';
import '../view_model/weight_progress_state.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      body: SafeArea(
        child: MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (_) => getIt<ExerciseActivityCubit>()..fetchActivity(),
            ),
            BlocProvider(
              create: (_) =>
                  getIt<WeightProgressCubit>()..fetchWeightProgress(),
            ),
          ],
          child: const _ProgressContent(),
        ),
      ),
    );
  }
}

class _ProgressContent extends StatefulWidget {
  const _ProgressContent();

  @override
  State<_ProgressContent> createState() => _ProgressContentState();
}

class _ProgressContentState extends State<_ProgressContent> {
  ExerciseFilterParams _filters = const ExerciseFilterParams();

  Future<void> _onRefresh() async {
    final activityCubit = context.read<ExerciseActivityCubit>();
    final weightCubit = context.read<WeightProgressCubit>();

    await Future.wait([
      activityCubit.fetchActivity(
        planId: _filters.planId,
        exerciseId: _filters.exerciseId,
        from: _filters.from,
        to: _filters.to,
        forceRefresh: true,
      ),
      weightCubit.fetchWeightProgress(forceRefresh: true),
    ]);
  }

  void _applyFilters(ExerciseFilterParams filters) {
    setState(() => _filters = filters);
    context.read<ExerciseActivityCubit>().fetchActivity(
      planId: filters.planId,
      exerciseId: filters.exerciseId,
      from: filters.from,
      to: filters.to,
    );
  }

  void _clearFilters() => _applyFilters(const ExerciseFilterParams());

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.primaryBtn,
      backgroundColor: context.backgroundColor,
      displacement: 40,
      onRefresh: _onRefresh,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Your Progress",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: context.textColor,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: BlocBuilder<WeightProgressCubit, WeightProgressState>(
              builder: (context, state) {
                if (state is WeightProgressLoading) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: LoadingShimmer(
                      width: double.infinity,
                      height: 280,
                      borderRadius: 24,
                    ),
                  );
                } else if (state is WeightProgressSuccess) {
                  return WeightProgressSection(data: state.data);
                } else if (state is WeightProgressError) {
                  return _ErrorWidget(
                    message: state.message,
                    onRetry: () => context
                        .read<WeightProgressCubit>()
                        .fetchWeightProgress(),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 25)),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: BlocBuilder<ExerciseActivityCubit, ExerciseActivityState>(
                builder: (context, state) {
                  if (state is ExerciseActivityLoading) {
                    return const LoadingShimmer(
                      width: double.infinity,
                      height: 400,
                      borderRadius: 24,
                    );
                  } else if (state is ExerciseActivitySuccess) {
                    return ExerciseActivitySection(
                      days: state.days,
                      filters: _filters,
                      onApplyFilters: _applyFilters,
                      onClearFilters: _clearFilters,
                    );
                  } else if (state is ExerciseActivityError) {
                    return _ErrorWidget(
                      message: state.message,
                      onRetry: () =>
                          context.read<ExerciseActivityCubit>().fetchActivity(),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 30)),
        ],
      ),
    );
  }
}

class _ErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorWidget({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(Icons.error_outline, color: Colors.grey.shade400, size: 40),
          const SizedBox(height: 8),
          Text(message, textAlign: TextAlign.center),
          TextButton(
            onPressed: onRetry,
            child: Text(
              l10n.retry,
              style: TextStyle(color: AppColors.primaryBtn),
            ),
          ),
        ],
      ),
    );
  }
}
