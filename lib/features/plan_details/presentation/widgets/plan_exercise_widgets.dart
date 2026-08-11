import 'package:flutter/material.dart';
import 'package:sportifo_app/core/theme/app_colors.dart';
import 'package:sportifo_app/features/workout/data/models/exercise_model.dart';

class PlanExerciseMatrix extends StatelessWidget {
  final List<ExerciseModel> exercises;

  const PlanExerciseMatrix({super.key, required this.exercises});

  @override
  Widget build(BuildContext context) {
    if (exercises.isEmpty) {
      return const SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(30),
            child: Text(
              'No exercises assigned',
              style: TextStyle(color: AppColors.hintText, fontSize: 13),
            ),
          ),
        ),
      );
    }

    final hero = exercises.first;
    final secondary = exercises.skip(1).toList();

    return SliverToBoxAdapter(
      child: Column(
        children: [
          PlanHeroExerciseCard(exercise: hero),

          if (secondary.isNotEmpty) ...[
            const SizedBox(height: 14),
            _SecondaryExerciseGrid(exercises: secondary),
          ],
        ],
      ),
    );
  }
}

class PlanHeroExerciseCard extends StatelessWidget {
  final ExerciseModel exercise;

  const PlanHeroExerciseCard({super.key, required this.exercise});

  @override
  Widget build(BuildContext context) {
    final imageUrl =
        exercise.gifUrl ??
        (exercise.pictureUrls.isNotEmpty ? exercise.pictureUrls.first : null);

    return Container(
      height: 310,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.textDark.withOpacity(.07)),
        boxShadow: [
          BoxShadow(
            color: AppColors.textDark.withOpacity(.08),
            blurRadius: 22,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(
            child: imageUrl != null
                ? Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) {
                      return const _MediaPlaceholder();
                    },
                  )
                : const _MediaPlaceholder(),
          ),

          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(.02),
                    Colors.black.withOpacity(.12),
                    Colors.black.withOpacity(.82),
                  ],
                  stops: const [0, .42, 1],
                ),
              ),
            ),
          ),

          Positioned(
            top: 14,
            left: 14,
            child: _OrderBadge(number: exercise.order ?? 1),
          ),

          Positioned(
            top: 14,
            right: 14,
            child: _ExerciseTypeBadge(isCardio: exercise.isCardio),
          ),

          Positioned(
            left: 17,
            right: 17,
            bottom: 17,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _InstructionButton(exercise: exercise),
                const SizedBox(height: 10),
                Text(
                  exercise.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    height: 1.05,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -.5,
                  ),
                ),

                const SizedBox(height: 10),

                Row(
                  children: [
                    _MetricCapsule(
                      label: 'SETS',
                      value: '${exercise.sets ?? '-'}',
                    ),
                    const SizedBox(width: 7),
                    _MetricCapsule(
                      label: 'REPS',
                      value: exercise.reps ?? exercise.duration ?? '-',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SecondaryExerciseGrid extends StatelessWidget {
  final List<ExerciseModel> exercises;

  const _SecondaryExerciseGrid({required this.exercises});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: exercises.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: .60,
      ),
      itemBuilder: (context, index) {
        return PlanCompactExerciseCard(exercise: exercises[index]);
      },
    );
  }
}

class PlanCompactExerciseCard extends StatelessWidget {
  final ExerciseModel exercise;

  const PlanCompactExerciseCard({super.key, required this.exercise});

  @override
  Widget build(BuildContext context) {
    final imageUrl =
        exercise.gifUrl ??
        (exercise.pictureUrls.isNotEmpty ? exercise.pictureUrls.first : null);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.textDark.withOpacity(.07)),
        boxShadow: [
          BoxShadow(
            color: AppColors.textDark.withOpacity(.055),
            blurRadius: 16,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: Stack(
              children: [
                Positioned.fill(
                  child: imageUrl != null
                      ? Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) {
                            return const _MediaPlaceholder();
                          },
                        )
                      : const _MediaPlaceholder(),
                ),
                Positioned(
                  top: 9,
                  left: 9,
                  child: _OrderBadge(number: exercise.order ?? 0, small: true),
                ),
              ],
            ),
          ),

          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(11, 10, 11, 9),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _InstructionButton(exercise: exercise, compact: true),
                  const SizedBox(height: 7),
                  Text(
                    exercise.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textDark,
                      fontSize: 12,
                      height: 1.1,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  const Spacer(),

                  Row(
                    children: [
                      Expanded(
                        child: _MiniMetric(
                          title: 'SET',
                          value: '${exercise.sets ?? '-'}',
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: _MiniMetric(
                          title: 'REP',
                          value: exercise.reps ?? exercise.duration ?? '-',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InstructionButton extends StatelessWidget {
  final ExerciseModel exercise;
  final bool compact;

  const _InstructionButton({required this.exercise, this.compact = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent,
          isScrollControlled: true,
          builder: (_) {
            return _InstructionSheet(exercise: exercise);
          },
        );
      },
      child: Container(
        height: compact ? 27 : 33,
        padding: EdgeInsets.symmetric(horizontal: compact ? 8 : 11),
        decoration: BoxDecoration(
          color: AppColors.primaryBtn.withOpacity(.09),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.primaryBtn.withOpacity(.20)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.menu_book_rounded,
              color: AppColors.primaryBtn,
              size: compact ? 12 : 15,
            ),
            const SizedBox(width: 5),
            Text(
              'INSTRUCTIONS',
              style: TextStyle(
                color: AppColors.textDark,
                fontSize: compact ? 7 : 8,
                fontWeight: FontWeight.w900,
                letterSpacing: .6,
              ),
            ),
          ],
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
    return Container(
      constraints: const BoxConstraints(maxHeight: 520),
      padding: const EdgeInsets.fromLTRB(22, 12, 22, 28),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.hintText.withOpacity(.35),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              const SizedBox(height: 22),

              Text(
                'TECHNICAL NOTES',
                style: TextStyle(
                  color: AppColors.primaryBtn,
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),

              const SizedBox(height: 7),

              Text(
                exercise.name,
                style: const TextStyle(
                  color: AppColors.textDark,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),

              const SizedBox(height: 20),

              Text(
                exercise.description,
                style: TextStyle(
                  color: AppColors.textDark.withOpacity(.72),
                  fontSize: 14,
                  height: 1.65,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetricCapsule extends StatelessWidget {
  final String label;
  final String value;

  const _MetricCapsule({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.primaryBtn.withOpacity(.92),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBtn.withOpacity(.18),
            blurRadius: 8,
          ),
        ],
      ),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '$label ',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 8,
                fontWeight: FontWeight.w900,
                letterSpacing: .7,
              ),
            ),
            TextSpan(
              text: value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniMetric extends StatelessWidget {
  final String title;
  final String value;

  const _MiniMetric({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.textDark.withOpacity(.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.primaryBtn,
              fontSize: 7,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textDark,
              fontSize: 9,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderBadge extends StatelessWidget {
  final int number;
  final bool small;

  const _OrderBadge({required this.number, this.small = false});

  @override
  Widget build(BuildContext context) {
    final size = small ? 28.0 : 31.0;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.94),
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.textDark.withOpacity(.12)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(.12), blurRadius: 8),
        ],
      ),
      child: Center(
        child: Text(
          number.toString().padLeft(2, '0'),
          style: TextStyle(
            color: AppColors.textDark,
            fontSize: small ? 8 : 9,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _ExerciseTypeBadge extends StatelessWidget {
  final bool isCardio;

  const _ExerciseTypeBadge({required this.isCardio});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.94),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: AppColors.textDark.withOpacity(.08)),
      ),
      child: Text(
        isCardio ? 'CARDIO' : 'RESISTANCE',
        style: TextStyle(
          color: isCardio ? AppColors.textDark : AppColors.primaryBtn,
          fontSize: 7,
          fontWeight: FontWeight.w900,
          letterSpacing: 1,
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
          color: AppColors.hintText.withOpacity(.25),
          size: 46,
        ),
      ),
    );
  }
}
