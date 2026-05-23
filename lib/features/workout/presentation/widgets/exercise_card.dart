import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/helpers/snack_bar_utils.dart';
import '../../../../core/widgets/cached_static_gif.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/models/exercise_model.dart';
import '../view_model/saved_exercises/saved_exercises_cubit.dart';
import '../view_model/saved_exercises/saved_exercises_state.dart';

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
                // داخل الـ Stack في ExerciseCard:
                Hero(
                  tag: 'exercise_${exercise.id}',
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    child: Container(
                      height: 110,
                      width: double.infinity,
                      color: Colors.white,

                      // 🔥 استدعاء الويدجت الخارق اللي بيكيش وبيجمد الـ GIF
                      child: CachedStaticGif(
                        imageUrl: exercise.gifUrl ?? '',
                      ),

                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: CircleAvatar(
                    backgroundColor: Colors.white.withValues(alpha: 0.8),
                    radius: 16,
                    child: BlocConsumer<SavedExercisesCubit, SavedExercisesState>(
                      listener: (context, state) {
                        if (state is SavedExercisesToggleSuccess && state.exerciseId == exercise.id) {
                          AppSnackBar.show(
                            context,
                            message: state.isSaved ? "Added to saved" : "Removed from saved",
                            type: SnackBarType.success,
                            onActionPressed: () => Navigator.pushNamed(context, AppRoutes.savedExercises),
                          );
                        }
                      },
                      builder: (context, state) {
                        return GestureDetector(
                          onTap: () => context.read<SavedExercisesCubit>().toggleSave(exercise),
                          child: Center(
                            child: Icon(
                              exercise.isSaved ? Icons.bookmark : Icons.bookmark_border,
                              color: AppColors.primaryBtn,
                              size: 20,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),

            // قسم النصوص محمي بالـ Expanded للوقاية من الـ Overflow
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,                  children: [
                    Text(
                      exercise.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: AppColors.textDark,
                          fontSize: 13,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                  const SizedBox(height: 4),
                    Text(
                      exercise.category?.organ?.name ?? l10n.workout,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: AppColors.primaryBtn,
                          fontSize: 11,
                          fontWeight: FontWeight.w600
                      ),
                    ),
                    if (exercise.category?.organ?.part != null)
                      const SizedBox(height: 2), // 🔥 مسافة صغيرة ومرتبة
                      Text(
                        exercise.category!.organ!.part!.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.grey.shade500, // لون أهدى شوي
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}