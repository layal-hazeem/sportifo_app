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
  int selectedSeconds = 0;
  @override
  void initState() {
    super.initState();

    setsController = TextEditingController(
      text: widget.exercise.sets?.toString() ?? "",
    );

    repsController = TextEditingController(text: widget.exercise.reps ?? "");

    if (widget.exercise.duration != null) {
      final parts = widget.exercise.duration!.split(":");

      selectedSeconds = (int.parse(parts[0]) * 60) + int.parse(parts[1]);
    }
  }

  @override
  void dispose() {
    setsController.dispose();
    repsController.dispose();

    super.dispose();
  }

  void save() {
    final minutes = selectedSeconds ~/ 60;
    final seconds = selectedSeconds % 60;
    if (widget.exercise.isCardio) {
      widget.exercise.duration =
          "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";

      widget.exercise.sets = null;
      widget.exercise.reps = null;
    } else {
      widget.exercise.sets = int.tryParse(setsController.text.trim());

      widget.exercise.reps = repsController.text.trim().isEmpty
          ? null
          : repsController.text.trim();

      widget.exercise.duration = null;
    }

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

            if (widget.exercise.isCardio)
              durationPicker()
            else ...[
              inputField("Sets", setsController),

              inputField("Reps", repsController),
            ],
            
            const SizedBox(height: 20),
            
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

  Widget durationPicker() {
    final minutes = selectedSeconds ~/ 60;
    final seconds = selectedSeconds % 60;

    return Container(
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
      ),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,

        children: [
          _timeBox(
            value: minutes,
            label: "min",
            max: 59,
            onChanged: (value) {
              setState(() {
                selectedSeconds = value * 60 + seconds;
              });
            },
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              ":",
              style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold),
            ),
          ),

          _timeBox(
            value: seconds,
            label: "sec",
            max: 59,
            onChanged: (value) {
              setState(() {
                selectedSeconds = minutes * 60 + value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _timeBox({
    required int value,
    required String label,
    required int max,
    required Function(int) onChanged,
  }) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 70,

          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
          ),

          child: ListWheelScrollView.useDelegate(
            itemExtent: 45,

            perspective: 0.003,

            diameterRatio: 1.5,

            physics: const FixedExtentScrollPhysics(),

            controller: FixedExtentScrollController(
              initialItem: value.clamp(0, max),
            ),

            onSelectedItemChanged: (index) {
              // حماية إضافية من أي قيمة غير صحيحة
              if (index >= 0 && index <= max) {
                onChanged(index);
              }
            },

            childDelegate: ListWheelChildBuilderDelegate(
              builder: (context, index) {
                if (index < 0 || index > max) {
                  return null;
                }

                return Center(
                  child: Text(
                    index.toString().padLeft(2, '0'),

                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        const SizedBox(height: 6),

        Text(label, style: TextStyle(color: Colors.grey.shade600)),
      ],
    );
  }
}
