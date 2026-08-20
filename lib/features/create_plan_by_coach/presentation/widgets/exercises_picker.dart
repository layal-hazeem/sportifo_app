import 'package:flutter/material.dart';
import 'package:sportifo_app/core/theme/app_colors.dart';
import 'package:sportifo_app/core/theme/app_theme_extensions.dart';
import 'package:sportifo_app/features/auth/presentation/widgets/custom_button.dart';
import 'package:sportifo_app/features/create_plan_by_coach/presentation/widgets/select_exercise.dart';
import 'package:sportifo_app/features/workout/data/models/exercise_model.dart';
import 'package:sportifo_app/features/workout/presentation/widgets/part_filter_chip.dart';
import 'package:sportifo_app/l10n/app_localizations.dart';

class ExerciseMultiPickerBottomSheet extends StatefulWidget {
  final List<ExerciseModel> exercises;

  const ExerciseMultiPickerBottomSheet({super.key, required this.exercises});

  @override
  State<ExerciseMultiPickerBottomSheet> createState() =>
      _ExerciseMultiPickerBottomSheetState();
}

class _ExerciseMultiPickerBottomSheetState
    extends State<ExerciseMultiPickerBottomSheet> {
  final Set<ExerciseModel> selected = {};

  late List<ExerciseModel> resistanceExercises;
  late List<ExerciseModel> cardioExercises;

  String selectedMuscle = "All";

  @override
  void initState() {
    super.initState();

    resistanceExercises = widget.exercises
        .where((e) => e.category?.id == 1)
        .toList();

    cardioExercises = widget.exercises
        .where((e) => e.category?.id == 2)
        .toList();
  }

  List<String> get muscles {
    final values = resistanceExercises
        .map((e) => e.category?.organ?.name)
        .whereType<String>()
        .toSet()
        .toList();

    values.sort();

    return ["All", ...values];
  }

  List<ExerciseModel> get filteredResistance {
    if (selectedMuscle == "All") {
      return resistanceExercises;
    }

    return resistanceExercises.where((exercise) {
      return exercise.category?.organ?.name == selectedMuscle;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return DefaultTabController(
      length: 2,
      child: Container(
        decoration: BoxDecoration(
          color: context.backgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 10),

            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            const SizedBox(height: 16),

            Center(
              child: Text(
                l10n.selectExercises,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            TabBar(
              labelColor: AppColors.primaryBtn,
              unselectedLabelColor: AppColors.hintText.withOpacity(0.85),
              indicatorColor: AppColors.primaryBtn,
              indicatorWeight: 2.5,
              dividerColor: AppColors.hintText.withOpacity(0.15),
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
              tabs: [
                Tab(
                  icon: Icon(Icons.fitness_center, size: 22),
                  text: l10n.resistance,
                ),
                Tab(
                  icon: Icon(Icons.directions_run, size: 22),
                  text: l10n.cardio,
                ),
              ],
            ),
            
            Expanded(
              child: TabBarView(
                children: [buildResistanceTab(), buildCardioTab()],
              ),
            ),

            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: CustomAuthButton(
                  text: l10n.addExercises(selected.length),
                  onPressed: selected.isEmpty
                      ? null
                      : () {
                          Navigator.pop(context, selected.toList());
                        },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildGrid(List<ExerciseModel> exercises) {
    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: exercises.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemBuilder: (context, index) {
        final ex = exercises[index];
        final isSelected = selected.contains(ex);

        return ExerciseSelectableCard(
          exercise: ex,
          isSelected: isSelected,
          onTap: () {
            setState(() {
              if (isSelected) {
                selected.remove(ex);
              } else {
                selected.add(ex);
              }
            });
          },
        );
      },
    );
  }

  Widget buildResistanceTab() {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              l10n.target_muscle,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.hintText,
              ),
            ),
          ),
        ),

        SizedBox(
          height: 50,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              final muscle = muscles[index];
              final selectedChip = selectedMuscle == muscle;

              return PartFilterChip(
                label: muscle,
                isSelected: selectedChip,
                onSelected: (_) {
                  setState(() {
                    selectedMuscle = muscle;
                  });
                },
              );
            },
            separatorBuilder: (_, __) => const SizedBox(width: 0),
            itemCount: muscles.length,
          ),
        ),

        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  setState(() {
                    selected.addAll(filteredResistance);
                  });
                },
                child: Text(
                  l10n.selectAll,
                  style: TextStyle(color: AppColors.primaryBtn),
                ),
              ),

              TextButton(
                onPressed: () {
                  setState(() {
                    selected.removeAll(filteredResistance);
                  });
                },
                child: Text(
                  l10n.clear,
                  style: TextStyle(color: AppColors.primaryBtn),
                ),
              ),
            ],
          ),
        ),

        Expanded(child: buildGrid(filteredResistance)),
      ],
    );
  }

  Widget buildCardioTab() {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  setState(() {
                    selected.addAll(cardioExercises);
                  });
                },
                child: Text(
                  l10n.selectAll,
                  style: TextStyle(color: AppColors.primaryBtn),
                ),
              ),

              TextButton(
                onPressed: () {
                  setState(() {
                    selected.removeAll(cardioExercises);
                  });
                },
                child: Text(
                  l10n.clear,
                  style: TextStyle(color: AppColors.primaryBtn),
                ),
              ),
            ],
          ),
        ),

        Expanded(child: buildGrid(cardioExercises)),
      ],
    );
  }
}
