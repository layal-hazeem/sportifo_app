import 'package:flutter/material.dart';
import 'package:sportifo_app/core/theme/app_colors.dart';
import 'package:sportifo_app/core/theme/app_theme_extensions.dart';
import 'package:sportifo_app/features/workout/data/models/exercise_model.dart';
import 'package:sportifo_app/l10n/app_localizations.dart';

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
          "${minutes.toString().padLeft(2, '0')}:"
          "${seconds.toString().padLeft(2, '0')}";

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
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,

        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),

        decoration: InputDecoration(
          labelText: label,

          labelStyle: TextStyle(
            color: AppColors.primaryBtn,
            fontWeight: FontWeight.w600,
          ),

          filled: true,
          fillColor: context.backgroundColor,

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: AppColors.hintText),
          ),

          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: AppColors.hintText),
          ),

          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: AppColors.primaryBtn, width: 1.4),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),

      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 14, 24, 24),

        decoration: BoxDecoration(
          color: context.backgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),

        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 42,
              height: 5,

              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(20),
              ),
            ),

            const SizedBox(height: 20),

            Container(
              width: 50,
              height: 50,

              decoration: BoxDecoration(
                color: AppColors.primaryBtn.withOpacity(.08),
                borderRadius: BorderRadius.circular(15),
              ),

              child: Icon(
                widget.exercise.isCardio
                    ? Icons.directions_run_rounded
                    : Icons.fitness_center_rounded,

                color: AppColors.primaryBtn,
                size: 22,
              ),
            ),

            const SizedBox(height: 14),

            Text(
              widget.exercise.name,

              textAlign: TextAlign.center,

              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              l10n.customizeExerciseSettings,

              textAlign: TextAlign.center,

              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 26),

            if (widget.exercise.isCardio)
              durationPicker()
            else ...[
              inputField(l10n.sets, setsController),

              inputField(l10n.reps, repsController),
            ],

            const SizedBox(height: 18),

            SizedBox(
              width: double.infinity,
              height: 54,

              child: ElevatedButton(
                onPressed: save,

                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBtn,
                  elevation: 0,

                  padding: const EdgeInsets.symmetric(vertical: 16),

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),

                child: Text(
                  l10n.saveExerciseSettings,

                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 14.5,
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
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
      ),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _timeBox(
            value: minutes,
            label: AppLocalizations.of(context)!.min,
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

              style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
            ),
          ),

          _timeBox(
            value: seconds,
            label: AppLocalizations.of(context)!.sec,
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
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
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
                      fontSize: 21,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        const SizedBox(height: 7),

        Text(
          label,

          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
