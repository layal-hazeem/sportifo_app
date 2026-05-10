import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gif_view/gif_view.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/models/exercise_model.dart';
import '../view_model/saved_exercises/saved_exercises_cubit.dart';

class ExerciseCard extends StatelessWidget {
  final ExerciseModel exercise;
  final VoidCallback onTap;

  const ExerciseCard({super.key, required this.exercise, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              offset: const Offset(0, 4),
              blurRadius: 10,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Hero(
                  tag: 'exercise_${exercise.id}',
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    child: GifView.network(
                      exercise.gifUrl ?? '',
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      autoPlay: false,
                      frameRate: 30,
                      progressBuilder: (context) => Container(
                        height: 120,
                        color: AppColors.background,
                        child: const Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primaryBtn,
                            ),
                          ),
                        ),
                      ),
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 120,
                        color: AppColors.background,
                        child: const Icon(Icons.fitness_center, color: AppColors.hintText),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: CircleAvatar(
                    backgroundColor: Colors.white.withValues(alpha:0.8),
                    radius: 16,
                    child: BlocBuilder<SavedExercisesCubit, void>(
                      builder: (context, state) {
                        return IconButton(
                          padding: EdgeInsets.zero,
                          icon: Icon(
                            exercise.isSaved ? Icons.bookmark : Icons.bookmark_border,
                            color: AppColors.primaryBtn,
                            size: 18,
                          ),
                          onPressed: () {
                            context.read<SavedExercisesCubit>().toggleSave(exercise);
                          },
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: AppColors.textDark,
                        fontSize: 14,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    exercise.category?.organ?.name ?? l10n.workout,
                    style: const TextStyle(
                        color: AppColors.primaryBtn,
                        fontSize: 11,
                        fontWeight: FontWeight.w600
                    ),
                  ),

                  if (exercise.category?.organ?.part != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      exercise.category!.organ!.part!.name,
                      style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}