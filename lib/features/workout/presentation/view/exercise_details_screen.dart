import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sportifo_app/features/workout/presentation/widgets/gallery_section.dart';
import 'package:sportifo_app/features/workout/presentation/widgets/how_to_perform_card.dart';
import 'package:sportifo_app/features/workout/presentation/widgets/info_stat_card.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/helpers/snack_bar_utils.dart';
import '../../../../core/widgets/cached_static_gif.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/models/exercise_model.dart';
import '../view_model/saved_exercises/saved_exercises_cubit.dart';
import '../view_model/saved_exercises/saved_exercises_state.dart';

class ExerciseDetailsScreen extends StatelessWidget {
  final ExerciseModel exercise;

  const ExerciseDetailsScreen({super.key, required this.exercise});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final organName = exercise.category?.organ?.name;
    final partName = exercise.category?.organ?.part?.name;

    final galleryUrls = exercise.pictureUrls.length > 1
        ? exercise.pictureUrls.sublist(1)
        : <String>[];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildAppBar(context, l10n),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise.name,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1E293B),
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 16),

                  if (organName != null || partName != null) ...[
                    Row(
                      children: [
                        if (organName != null)
                          Expanded(
                            child: InfoStatCard(
                              title: l10n.target_muscle,
                              value: organName,
                              icon: Icons.accessibility_new_rounded,
                              accentColor: AppColors.primaryBtn,
                            ),
                          ),
                        if (organName != null && partName != null)
                          const SizedBox(width: 12),
                        if (partName != null)
                          Expanded(
                            child: InfoStatCard(
                              title: "Body Part",
                              value: partName,
                              icon: Icons.line_weight_rounded,
                              accentColor: const Color(0xFF0EA5E9),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],

                  HowToPerformCard(
                    title: l10n.how_to_perform,
                    description: exercise.description,
                  ),
                  const SizedBox(height: 28),
                  GallerySection(
                    imageUrls: galleryUrls,
                    title: l10n.gallery,
                    photosLabel: "Photos",
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  SliverAppBar _buildAppBar(BuildContext context, AppLocalizations l10n) {
    return SliverAppBar(
      expandedHeight: 340,
      pinned: true,
      elevation: 0,
      backgroundColor: AppColors.primaryBtn,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CircleAvatar(
          backgroundColor: Colors.white.withValues(alpha:0.9),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 18),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.white.withValues(alpha:0.9),
            child: BlocConsumer<SavedExercisesCubit, SavedExercisesState>(
              listener: (context, state) {
                if (state is SavedExercisesToggleSuccess && state.exerciseId == exercise.id) {
                  AppSnackBar.show(
                    context,
                    message: state.isSaved ? "Added to saved" : "Removed from saved",
                    type: SnackBarType.success,
                    onActionPressed: () {
                      if (!context.mounted) return;
                      final currentRoute = ModalRoute.of(context)?.settings.name;
                      if (currentRoute == AppRoutes.savedExercises) {
                        Navigator.of(context).pop();
                        return;
                      }
                      Navigator.of(context).pushNamed(AppRoutes.savedExercises);
                    },
                  );
                }
              },
              builder: (context, state) {
                final cubit = context.read<SavedExercisesCubit>();
                final isCurrentlySaved = cubit.isSaved(exercise.id);

                return IconButton(
                  icon: Icon(
                    isCurrentlySaved ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
                    color: isCurrentlySaved ? AppColors.primaryBtn : Colors.black87,
                    size: 22,
                  ),
                  onPressed: () => cubit.toggleSave(exercise),
                );
              },
            ),
          ),
        )
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Hero(
              tag: 'exercise_${exercise.id}',
              child: Container(
                color: Colors.white,
                child: CachedStaticGif(
                  imageUrl: exercise.gifUrl ?? '',
                  autoPlay: true,
                ),
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.3),
                      Colors.transparent,
                      Colors.black.withValues(alpha:0.4),
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}