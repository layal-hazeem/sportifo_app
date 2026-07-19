import 'package:flutter/material.dart';
import 'package:sportifo_app/features/auth/presentation/widgets/custom_button.dart';
import 'package:sportifo_app/features/plans/presentation/widgets/exercise_selectable_card.dart';
import 'package:sportifo_app/features/workout/data/models/exercise_model.dart';
import 'package:sportifo_app/features/workout/presentation/view/exercise_details_screen.dart';

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

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(child: SizedBox(height: 10)),

          SliverToBoxAdapter(
            child: Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 12)),

          const SliverToBoxAdapter(
            child: Center(
              child: Text(
                "Select Exercises",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 10)),

          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate((context, index) {
                final ex = widget.exercises[index];
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
              }, childCount: widget.exercises.length),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.8,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 20)),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: CustomAuthButton(
                text: "Add (${selected.length})",
                onPressed: selected.isEmpty
                    ? null
                    : () async {
                        final exercises = selected.toList();

                        for (final exercise in exercises) {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  ExerciseDetailsScreen(exercise: exercise),
                            ),
                          );
                        }

                        if (!mounted) return;

                        Navigator.pop(context, exercises);
                      },
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],
      ),
    );
  }
}
