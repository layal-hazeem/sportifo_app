import 'package:flutter/material.dart';
import 'package:sportifo_app/core/theme/app_colors.dart';
import 'package:sportifo_app/features/workout/data/models/exercise_model.dart';
import 'package:sportifo_app/l10n/app_localizations.dart';

class PlanExerciseMatrix extends StatelessWidget {
  final List<ExerciseModel> exercises;

  const PlanExerciseMatrix({super.key, required this.exercises});

  @override
  Widget build(BuildContext context) {
    if (exercises.isEmpty) {
      return const SliverToBoxAdapter(child: _EmptyExercises());
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      sliver: SliverList.separated(
        itemCount: exercises.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          return PlanExerciseCard(exercise: exercises[index]);
        },
      ),
    );
  }
}

class PlanExerciseCard extends StatelessWidget {
  final ExerciseModel exercise;

  const PlanExerciseCard({super.key, required this.exercise});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final imageUrl =
        exercise.gifUrl ??
        (exercise.pictureUrls.isNotEmpty ? exercise.pictureUrls.first : null);

    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent,
          isScrollControlled: true,
          builder: (_) => _InstructionSheet(exercise: exercise),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black.withOpacity(0.05)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ExerciseThumbnail(imageUrl: imageUrl, order: exercise.order ?? 0),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          exercise.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.textDark,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            height: 1.2,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _ExerciseTypeBadge(isCardio: exercise.isCardio),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _MetricChip(
                        icon: Icons.repeat_rounded,
                        label: l10n.sets,
                        value: '${exercise.sets ?? '-'}',
                      ),
                      const SizedBox(width: 8),
                      _MetricChip(
                        icon: Icons.fitness_center_rounded,
                        label: l10n.reps,
                        value: exercise.reps ?? exercise.duration ?? '-',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExerciseThumbnail extends StatelessWidget {
  final String? imageUrl;
  final int order;

  const _ExerciseThumbnail({required this.imageUrl, required this.order});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 84,
      height: 84,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              width: 84,
              height: 84,
              child: imageUrl != null
                  ? Image.network(
                      imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const _MediaPlaceholder(),
                    )
                  : const _MediaPlaceholder(),
            ),
          ),
          Positioned(
            top: -6,
            left: -6,
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: AppColors.primaryBtn,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Center(
                child: Text(
                  order.toString().padLeft(2, '0'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _MetricChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black.withOpacity(0.04)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.primaryBtn, size: 13),
          const SizedBox(width: 5),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textDark,
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              color: AppColors.hintText,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExerciseTypeBadge extends StatelessWidget {
  final bool isCardio;

  const _ExerciseTypeBadge({required this.isCardio});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final color = isCardio ? AppColors.textDark : AppColors.primaryBtn;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        isCardio ? l10n.cardio : l10n.strength,
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

class _InstructionSheet extends StatelessWidget {
  final ExerciseModel exercise;

  const _InstructionSheet({required this.exercise});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      constraints: const BoxConstraints(maxHeight: 500),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.hintText.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                l10n.technicalNotes,
                style: TextStyle(
                  color: AppColors.primaryBtn,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                exercise.name,
                style: const TextStyle(
                  color: AppColors.textDark,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                exercise.description,
                style: TextStyle(
                  color: AppColors.textDark.withOpacity(0.7),
                  fontSize: 14,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MediaPlaceholder extends StatelessWidget {
  const _MediaPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: Center(
        child: Icon(
          Icons.fitness_center_rounded,
          color: AppColors.hintText.withOpacity(0.3),
          size: 28,
        ),
      ),
    );
  }
}

class _EmptyExercises extends StatelessWidget {
  const _EmptyExercises();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          children: [
            Icon(
              Icons.fitness_center_rounded,
              color: AppColors.hintText.withOpacity(0.3),
              size: 36,
            ),
            const SizedBox(height: 10),
             Text(
              l10n.noExercisesAssigned,
              style: TextStyle(color: AppColors.hintText, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
