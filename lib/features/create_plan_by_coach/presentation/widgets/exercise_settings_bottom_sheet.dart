import 'package:flutter/material.dart';
import 'package:sportifo_app/core/theme/app_colors.dart';
import 'package:sportifo_app/core/theme/app_theme_extensions.dart';
import 'package:sportifo_app/core/widgets/custom_glass_bottom_sheet.dart';
import 'package:sportifo_app/features/workout/data/models/exercise_model.dart';
import 'package:sportifo_app/l10n/app_localizations.dart';

class ExerciseSettingsBottomSheet extends StatefulWidget {
  final ExerciseModel exercise;

  const ExerciseSettingsBottomSheet({super.key, required this.exercise});

  static Future<void> show(BuildContext context, ExerciseModel exercise) async {
    await CustomGlassBottomSheet.show(
      context: context,
      child: ExerciseSettingsBottomSheet(exercise: exercise),
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

    if (widget.exercise.duration != null &&
        widget.exercise.duration!.contains(":")) {
      final parts = widget.exercise.duration!.split(":");
      selectedSeconds =
          (int.tryParse(parts[0]) ?? 0) * 60 + (int.tryParse(parts[1]) ?? 0);
    }

    // 🔥 استماع فوري لأي تغيير لتفعيل أو تعطيل زر الحفظ
    setsController.addListener(_onFieldChanged);
    repsController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    setsController.removeListener(_onFieldChanged);
    repsController.removeListener(_onFieldChanged);
    setsController.dispose();
    repsController.dispose();
    super.dispose();
  }

  /// 🔥 شرط تفعيل زر الحفظ:
  /// - إذا كان كارديو: يجب أن تكون المدة أكبر من صفر.
  /// - إذا كان مقاومة: يجب إدخال المجموعات والعدّات معاً.
  bool get _isSaveEnabled {
    if (widget.exercise.isCardio) {
      return selectedSeconds > 0;
    }
    return setsController.text.trim().isNotEmpty &&
        repsController.text.trim().isNotEmpty;
  }

  void save() {
    if (!_isSaveEnabled) return;

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

  Widget inputField({
    required String label,
    required TextEditingController controller,
    required String hint,
  }) {
    final isEmpty = controller.text.trim().isEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: context.textColor,
        ),
        decoration: InputDecoration(
          labelText: "$label *",
          hintText: hint,
          hintStyle: TextStyle(
            color: Colors.grey.shade400,
            fontSize: 13,
            fontWeight: FontWeight.w400,
          ),
          labelStyle: const TextStyle(
            color: AppColors.primaryBtn,
            fontWeight: FontWeight.w600,
          ),
          floatingLabelStyle: const TextStyle(
            color: AppColors.primaryBtn,
            fontWeight: FontWeight.w600,
          ),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
              color: AppColors.hintText.withValues(alpha: 0.25),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
              color: isEmpty
                  ? Colors.orange.withValues(alpha: 0.5) // تنبيه عند الفراغ
                  : AppColors.hintText.withValues(alpha: 0.25),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: AppColors.primaryBtn,
              width: 1.4,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.primaryBtn.withValues(alpha: 0.08),
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
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
              color: context.textColor,
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
            inputField(
              label: l10n.sets,
              controller: setsController,
              hint: l10n.exampleSets,
            ),
            inputField(
              label: l10n.reps,
              controller: repsController,
              hint: l10n.exampleReps,
            ),
          ],

          const SizedBox(height: 18),

          // 🔥 الزر معطل ومموه تلقائياً حتى إدخال القيم
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: _isSaveEnabled ? save : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBtn,
                disabledBackgroundColor: isDark
                    ? Colors.white.withValues(alpha: 0.12)
                    : Colors.grey.shade300,
                disabledForegroundColor: isDark
                    ? Colors.white38
                    : Colors.grey.shade500,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                l10n.saveExerciseSettings,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 14.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget durationPicker() {
    final minutes = selectedSeconds ~/ 60;
    final seconds = selectedSeconds % 60;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.backgroundColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: selectedSeconds == 0
              ? Colors.orange.withValues(alpha: 0.5)
              : Colors.grey.withValues(alpha: 0.2),
        ),
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
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
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
                if (index < 0 || index > max) return null;
                return Center(
                  child: Text(
                    index.toString().padLeft(2, '0'),
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w700,
                      color: context.textColor,
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