import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/wave_app_bar.dart'; // تأكدي من المسار الصحيح
import '../../../../l10n/app_localizations.dart';
import '../view_model/saved_exercises/saved_exercises_cubit.dart';
import '../view_model/saved_exercises/saved_exercises_state.dart';
import '../widgets/exercise_card.dart';

class SavedExercisesScreen extends StatelessWidget {
  const SavedExercisesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: WaveAppBar(
        title: l10n.saved_exercises,
        showBackButton: true,
      ),
      body: BlocBuilder<SavedExercisesCubit, SavedExercisesState>(
        buildWhen: (previous, current) =>
        current is SavedExercisesSuccess ||
            current is SavedExercisesLoading ||
            current is SavedExercisesError,
        builder: (context, state) {
          if (state is SavedExercisesLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryBtn),
            );
          } else if (state is SavedExercisesSuccess) {
            final exercises = state.savedExercises;

            if (exercises.isEmpty) {
              return _buildEmptyState(context, l10n);
            }

            return GridView.builder(
              padding: const EdgeInsets.all(16),
              physics: const BouncingScrollPhysics(),
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
            );
          } else if (state is SavedExercisesError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 50, color: Colors.red),
                  const SizedBox(height: 10),
                  Text(state.message),
                  TextButton(
                    onPressed: () =>
                        context.read<SavedExercisesCubit>().fetchSavedExercises(),
                    child: const Text("Retry", style: TextStyle(color: AppColors.primaryBtn)),
                  )
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, var l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bookmark_border, size: 80, color: AppColors.primaryBtn.withOpacity(0.2)),
          const SizedBox(height: 16),
          Text(
            "No saved exercises yet",
            style: TextStyle(fontSize: 18, color: Colors.grey.shade600, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              "Exercises you save will appear here for quick access",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade400),
            ),
          ),
        ],
      ),
    );
  }
}