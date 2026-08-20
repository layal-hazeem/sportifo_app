import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sportifo_app/core/theme/app_theme_extensions.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/helpers/snack_bar_utils.dart';
import '../../../../core/widgets/loading_shimmer.dart';
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

    // 🔥 التعديل الذكي: البحث عن أول صورة ليست GIF (بغض النظر عن حالة الأحرف)
    String displayImageUrl = '';
    if (exercise.images != null && exercise.images!.isNotEmpty) {
      final selectedImage = exercise.images!.firstWhere(
            (img) {
          final type = (img.type ?? '').toLowerCase();
          final url = (img.url ?? '').toLowerCase();

          // نختار الصورة إذا كان نوعها لا يحتوي على gif والرابط لا يحتوي على .gif
          return !type.contains('gif') && !url.contains('.gif');
        },
        // إذا كان كل المرفقات من الباك إند هي gif حصراً، نأخذ أول عنصر كحل أخير
        orElse: () => exercise.images!.first,
      );
      displayImageUrl = selectedImage.url ?? '';
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: context.backgroundColor,
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
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    child: Container(
                      height: 90, // 🔥 التعديل الثاني: تصغير الارتفاع من 110 إلى 90
                      width: double.infinity,
                      color: Colors.white,
                      child: displayImageUrl.isNotEmpty
                          ? CachedNetworkImage(
                        imageUrl: displayImageUrl,
                        fit: BoxFit.contain, // 🔥 لضمان ظهور التمرين كاملاً بدون قص
                        placeholder: (context, url) => const LoadingShimmer(
                          width: double.infinity,
                          height: 90,
                          borderRadius: 20,
                        ),
                        errorWidget: (context, url, error) => const Icon(
                          Icons.fitness_center,
                          color: Colors.grey,
                        ),
                      )
                          : const Icon(
                        Icons.image_not_supported,
                        color: Colors.grey,
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
                    child:
                    BlocConsumer<SavedExercisesCubit, SavedExercisesState>(
                      listener: (context, state) {
                        if (state is SavedExercisesToggleSuccess &&
                            state.exerciseId == exercise.id) {
                          AppSnackBar.show(
                            context,
                            message: state.isSaved
                                ? "Added to saved"
                                : "Removed from saved",
                            type: SnackBarType.success,
                            onActionPressed: () {
                              if (!context.mounted) return;
                              final currentRoute = ModalRoute.of(
                                context,
                              )?.settings.name;
                              if (currentRoute ==
                                  AppRoutes.savedExercises) {
                                Navigator.of(context).pop();
                                return;
                              }
                              Navigator.of(
                                context,
                              ).pushNamed(AppRoutes.savedExercises);
                            },
                          );
                        }
                      },
                      builder: (context, state) {
                        final cubit = context.read<SavedExercisesCubit>();
                        final isCurrentlySaved = cubit.isSaved(exercise.id);

                        return GestureDetector(
                          onTap: () => cubit.toggleSave(exercise),
                          child: Center(
                            child: Icon(
                              isCurrentlySaved
                                  ? Icons.bookmark
                                  : Icons.bookmark_border,
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
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6, // 🔥 تعديل مسافات النصوص لتتناسب مع الارتفاع الجديد
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      exercise.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: context.textColor,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
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
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (exercise.category?.organ?.part != null)
                      const SizedBox(height: 2),
                    if (exercise.category?.organ?.part != null)
                      Text(
                        exercise.category!.organ!.part!.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.grey.shade500,
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