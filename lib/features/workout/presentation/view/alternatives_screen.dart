import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sportifo_app/core/theme/app_colors.dart';
import 'package:sportifo_app/core/theme/app_theme_extensions.dart';
import 'package:sportifo_app/l10n/app_localizations.dart';
import '../../data/models/exercise_model.dart';
import '../view_model/alternatives_cubit/alternatives_cubit.dart';
import '../view_model/alternatives_cubit/alternatives_state.dart';
import '../view_model/saved_exercises/saved_exercises_cubit.dart';
import 'exercise_details_screen.dart'; // استدعاء شاشة التفاصيل

class AlternativesScreen extends StatelessWidget {
  final int exerciseId;

  const AlternativesScreen({super.key, required this.exerciseId});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        backgroundColor: context.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: context.textColor,
            size: 18,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.alternativeExercises,
          style: TextStyle(
            color: context.textColor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<AlternativesCubit, AlternativesState>(
        builder: (context, state) {
          if (state is AlternativesLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryBtn),
            );
          } else if (state is AlternativesError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  state.message,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          } else if (state is AlternativesSuccess) {
            final exercises = state.exercises;

            if (exercises.isEmpty) {
              return Center(
                child: Text(
                  l10n.noAlternativesFound ?? "لا توجد تمارين بديلة",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                ),
              );
            }

            return ListView.builder(
              itemCount: exercises.length,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              itemBuilder: (context, index) {
                final altEx = exercises[index];
                return _buildAlternativeCard(context, altEx);
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildAlternativeCard(BuildContext context, ExerciseModel exercise) {
    final l10n = AppLocalizations.of(context)!;

    String displayImageUrl = '';
    if (exercise.images != null && exercise.images!.isNotEmpty) {
      final selectedImage = exercise.images!.firstWhere((img) {
        final type = (img.type ?? '').toLowerCase();
        final url = (img.url ?? '').toLowerCase();
        return !type.contains('gif') && !url.contains('.gif');
      }, orElse: () => exercise.images!.first);
      displayImageUrl = selectedImage.url ?? '';
    }

    String muscleText = exercise.category?.organ?.name ?? l10n.workout;
    if (exercise.category?.organ?.part != null) {
      muscleText += ' - ${exercise.category!.organ!.part!.name}';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: context.backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryBtn.withOpacity(0.2)),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: ListTile(
          contentPadding: const EdgeInsets.all(8),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 60,
              height: 60,
              color: Colors.white,
              child: displayImageUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: displayImageUrl,
                      fit: BoxFit.contain,
                      placeholder: (context, url) => const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.fitness_center, color: Colors.grey),
                    )
                  : const Icon(Icons.image_not_supported, color: Colors.grey),
            ),
          ),
          title: Text(
            exercise.name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            muscleText,
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryBtn.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.arrow_forward_ios_rounded,
              color: AppColors.primaryBtn,
              size: 16,
            ),
          ),
          onTap: () {
            final savedExercisesCubit = context.read<SavedExercisesCubit>();

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BlocProvider.value(
                  value: savedExercisesCubit,
                  child: ExerciseDetailsScreen(
                    exercise: exercise,
                    isAlternative: true, // إخفاء زر البدائل في الشاشة الداخلية
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
