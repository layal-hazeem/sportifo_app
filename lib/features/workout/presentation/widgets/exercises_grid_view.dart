import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/models/exercise_model.dart';
import '../widgets/exercise_card.dart';
import '../../../../core/routes/app_routes.dart';

class ExercisesGridView extends StatelessWidget {
  final List<ExerciseModel> exercises;
  final Function(ExerciseModel)? onSelect;

  const ExercisesGridView({super.key, required this.exercises, this.onSelect});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (exercises.isEmpty) {
      return Center(child: Text(l10n.no_exercises_found));
    }

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      itemCount: exercises.length,
      shrinkWrap: false,
      physics: const AlwaysScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        childAspectRatio: 0.8,
      ),
      itemBuilder: (context, index) {
        final exercise = exercises[index];
        return ExerciseCard(
          exercise: exercise,
          onTap: () {
            if (onSelect != null) {
              onSelect!(exercise);
            } else {
              Navigator.pushNamed(
                context,
                AppRoutes.exerciseDetails,
                arguments: exercise,
              );
            }
          },
        );
      },
    );
  }
}
