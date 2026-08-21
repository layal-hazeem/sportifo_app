import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sportifo_app/core/theme/app_theme_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/loading_shimmer.dart';
import '../../../../core/widgets/wave_app_bar.dart';
import '../../../../core/widgets/no_internet_view.dart'; // ← 1. استيراد
import '../../../../l10n/app_localizations.dart';
import '../view_model/saved_exercises/saved_exercises_cubit.dart';
import '../view_model/saved_exercises/saved_exercises_state.dart';
import '../widgets/exercise_card.dart';

class SavedExercisesScreen extends StatefulWidget {
  const SavedExercisesScreen({super.key});

  @override
  State<SavedExercisesScreen> createState() => _SavedExercisesScreenState();
}

class _SavedExercisesScreenState extends State<SavedExercisesScreen> {
  @override
  void initState() {
    super.initState();
    context.read<SavedExercisesCubit>().initialize();
  }

  Future<void> _onRefresh() async {
    await context.read<SavedExercisesCubit>().fetchSavedExercises(
      forceRefresh: true,
    );
  }

  // ← 2. دالة فحص الـ offline
  bool _isOfflineError(String message) {
    final lower = message.toLowerCase();
    return lower.contains('socket') ||
        lower.contains('connection') ||
        lower.contains('network') ||
        lower.contains('failed host lookup') ||
        lower.contains('timeout');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: WaveAppBar(title: l10n.saved_exercises, showBackButton: true),
      body: BlocBuilder<SavedExercisesCubit, SavedExercisesState>(
        buildWhen: (previous, current) =>
            current is SavedExercisesSuccess ||
            current is SavedExercisesLoading ||
            current is SavedExercisesError,
        builder: (context, state) {
          if (state is SavedExercisesLoading &&
              state is! SavedExercisesSuccess) {
            return GridView.builder(
              padding: const EdgeInsets.all(16),
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
              ),
              itemCount: 6,
              itemBuilder: (context, index) => const LoadingShimmer(
                width: double.infinity,
                height: double.infinity,
                borderRadius: 20,
              ),
            );
          } else if (state is SavedExercisesSuccess) {
            final exercises = state.savedExercises;

            if (exercises.isEmpty) {
              return _buildEmptyState(context, l10n);
            }

            return RefreshIndicator(
              onRefresh: _onRefresh,
              color: AppColors.primaryBtn,
              backgroundColor: context.backgroundColor,
              displacement: 40,
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                physics: const AlwaysScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                ),
                itemCount: exercises.length,
                itemBuilder: (context, index) {
                  final exercise = exercises[index];
                  return ExerciseCard(
                    exercise: exercise,
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.exerciseDetails,
                        arguments: exercise,
                      );
                    },
                  );
                },
              ),
            );
          } else if (state is SavedExercisesError) {
            // ← 3. لو offline error → NoInternetView
            if (_isOfflineError(state.message)) {
              return NoInternetView(
                onRetry: () => context
                    .read<SavedExercisesCubit>()
                    .fetchSavedExercises(forceRefresh: true),
              );
            }

            // لو error تاني → نفس العرض القديم
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 50, color: Colors.red),
                  const SizedBox(height: 10),
                  Text(state.message),
                  TextButton(
                    onPressed: _onRefresh,
                    child: Text(
                      l10n.retry,
                      style: const TextStyle(color: AppColors.primaryBtn),
                    ),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return RefreshIndicator(
          onRefresh: _onRefresh,
          color: AppColors.primaryBtn,
          backgroundColor: context.backgroundColor,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: SizedBox(
              height: constraints.maxHeight,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.bookmark_border,
                      size: 80,
                      color: AppColors.primaryBtn.withValues(alpha: 0.2),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.noSavedExercisesYet,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        l10n.savedExercisesHint,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.arrow_downward,
                          size: 14,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          l10n.pullDownToRefresh,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}