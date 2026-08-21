import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sportifo_app/core/theme/app_theme_extensions.dart';
import 'package:sportifo_app/core/widgets/no_internet_view.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/loading_shimmer.dart';
import '../../../../core/widgets/wave_app_bar.dart';
import '../../../../l10n/app_localizations.dart';
import '../view_model/exercises_cubit/exercises_cubit.dart';
import '../view_model/exercises_cubit/exercises_state.dart';
import '../widgets/exercises_grid_view.dart';

class ExercisesListScreen extends StatelessWidget {
  final int categoryId;
  final String categoryName;

  const ExercisesListScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

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
      appBar: WaveAppBar(
        title: categoryName,
        showBackButton: true,
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: context.textColor),
            onPressed: () {
              Navigator.pushNamed(
                context,
                AppRoutes.searchScreen,
                arguments: {
                  'categoryId': categoryId,
                  'organId': null,
                  'partIds': null,
                },
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<ExercisesCubit, ExercisesState>(
        builder: (context, state) {
          if (state is ExercisesLoading) {
            return GridView.builder(
              padding: const EdgeInsets.all(20),
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                childAspectRatio: 0.85,
              ),
              itemCount: 6,
              itemBuilder: (context, index) {
                return const LoadingShimmer(
                  width: double.infinity,
                  height: double.infinity,
                  borderRadius: 16,
                );
              },
            );
          }

          if (state is ExercisesFailure) {
            final isOffline = _isOfflineError(state.errorMessage);

            if (isOffline) {
              return NoInternetView(
                onRetry: () {
                  context.read<ExercisesCubit>().retry(categoryId: categoryId);
                },
              );
            }

            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      state.errorMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        context.read<ExercisesCubit>().retry(categoryId: categoryId);
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF57C00),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is ExercisesSuccess) {
            final exercises = state.exercises;

            if (exercises.isEmpty) {
              return Center(
                child: Text(
                  l10n.no_exercises_found,
                  style: const TextStyle(color: Colors.white),
                ),
              );
            }

            return ExercisesGridView(exercises: exercises);
          }

          return const SizedBox();
        },
      ),
    );
  }
}