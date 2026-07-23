import 'package:flutter/material.dart';
import 'package:sportifo_app/core/theme/app_colors.dart';
import 'package:sportifo_app/features/workout/data/models/exercise_model.dart';

class ExerciseSettingsBottomSheet extends StatefulWidget {
  final ExerciseModel exercise;

  const ExerciseSettingsBottomSheet({super.key, required this.exercise});

  static Future<void> show(BuildContext context, ExerciseModel exercise) async {
    await showModalBottomSheet(
      context: context,

      isScrollControlled: true,

      backgroundColor: Colors.transparent,

      builder: (_) {
        return ExerciseSettingsBottomSheet(exercise: exercise);
      },
    );
  }

  @override
  State<ExerciseSettingsBottomSheet> createState() =>
      _ExerciseSettingsBottomSheetState();
}

class _ExerciseSettingsBottomSheetState
    extends State<ExerciseSettingsBottomSheet> {
  late TextEditingController setsController;
  late TextEditingController repsController;

  @override
  void initState() {
    super.initState();

    setsController = TextEditingController(
      text: widget.exercise.sets?.toString() ?? "",
    );

    repsController = TextEditingController(text: widget.exercise.reps ?? "");
  }

  @override
  void dispose() {
    setsController.dispose();

    repsController.dispose();

    super.dispose();
  }

  void save() {
    widget.exercise.sets = int.tryParse(setsController.text.trim());

    widget.exercise.reps = repsController.text.trim().isEmpty
        ? null
        : repsController.text.trim();

    Navigator.pop(context);
  }

  Widget inputField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),

      child: TextField(
        controller: controller,

        keyboardType: TextInputType.number,

        decoration: InputDecoration(
          labelText: label,

          filled: true,

          fillColor: Colors.grey.shade100,

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),

            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),

      child: Container(
        padding: const EdgeInsets.all(24),

        decoration: const BoxDecoration(
          color: Colors.white,

          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),

        child: Column(
          mainAxisSize: MainAxisSize.min,

          children: [
            Container(
              width: 45,

              height: 5,

              decoration: BoxDecoration(
                color: Colors.grey.shade300,

                borderRadius: BorderRadius.circular(20),
              ),
            ),

            const SizedBox(height: 20),

            Text(
              widget.exercise.name,

              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Text(
              "Customize this exercise settings",

              style: TextStyle(color: Colors.grey.shade600),
            ),

            const SizedBox(height: 25),

            inputField("Sets", setsController),

            inputField("Reps", repsController),

            SizedBox(
              width: double.infinity,

              child: ElevatedButton(
                onPressed: save,

                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBtn,

                  padding: const EdgeInsets.symmetric(vertical: 16),

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),

                child: const Text(
                  "Save Exercise Settings",

                  style: TextStyle(
                    color: Colors.white,

                    fontWeight: FontWeight.bold,
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
