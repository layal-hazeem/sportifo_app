import 'package:flutter/material.dart';
import 'package:sportifo_app/core/theme/app_colors.dart';
import 'package:sportifo_app/core/theme/app_theme_extensions.dart';
import 'package:sportifo_app/core/widgets/cached_static_gif.dart';
import 'package:sportifo_app/features/workout/data/models/exercise_model.dart';
import 'package:sportifo_app/l10n/app_localizations.dart';

class ExerciseDetailsScreen extends StatefulWidget {
  final ExerciseModel exercise;

  const ExerciseDetailsScreen({super.key, required this.exercise});

  @override
  State<ExerciseDetailsScreen> createState() => _ExerciseDetailsScreenState();
}

class _ExerciseDetailsScreenState extends State<ExerciseDetailsScreen> {
  late final TextEditingController setsController;
  late final TextEditingController repsController;
  late final TextEditingController durationController;
  late final TextEditingController orderController;

  @override
  void initState() {
    super.initState();

    setsController = TextEditingController(
      text: widget.exercise.sets?.toString() ?? '',
    );

    repsController = TextEditingController(text: widget.exercise.reps ?? '');

    durationController = TextEditingController(
      text: widget.exercise.duration ?? '',
    );

    orderController = TextEditingController(
      text: widget.exercise.order?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    setsController.dispose();
    repsController.dispose();
    durationController.dispose();
    orderController.dispose();

    super.dispose();
  }

  void clearOverride() {
    setsController.clear();
    repsController.clear();

    widget.exercise.sets = null;
    widget.exercise.reps = null;

    setState(() {});
  }

  void save() {
    widget.exercise.sets = int.tryParse(setsController.text.trim());

    widget.exercise.reps = repsController.text.trim().isEmpty
        ? null
        : repsController.text.trim();

    widget.exercise.duration = durationController.text.trim().isEmpty
        ? null
        : durationController.text.trim();

    widget.exercise.order = int.tryParse(orderController.text.trim());

    Navigator.pop(context);
  }

  Widget field(
    String label,
    TextEditingController controller,
    TextInputType keyboard,
    String hint,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        keyboardType: keyboard,
        textInputAction: TextInputAction.next,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          filled: true,
          fillColor: Colors.grey.shade50,
          labelStyle: TextStyle(
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w600,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.grey.shade200),
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
    final ex = widget.exercise;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: context.backgroundColor,

      appBar: AppBar(
        title: Text(
          ex.name,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
        ),
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        backgroundColor: context.backgroundColor,
        foregroundColor: context.textColor,
      ),

      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Exercise GIF
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Container(
                height: 220,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: CachedStaticGif(imageUrl: ex.gifUrl ?? ''),
              ),
            ),

            const SizedBox(height: 22),

            // Exercise name
            Text(
              ex.name,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),

            const SizedBox(height: 8),

            // Exercise description
            Text(
              ex.description,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 13.5,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 24),

            // Info message
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: context.backgroundColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: const Icon(
                      Icons.info_outline_rounded,
                      color: AppColors.primaryBtn,
                      size: 17,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Text(
                      l10n.exerciseDefaultsInfo,
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 26),

            // Section title
            Text(
              l10n.customValues,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
                color: Colors.grey.shade500,
              ),
            ),

            const SizedBox(height: 12),

            // Custom Sets
            field(
              l10n.customSets,
              setsController,
              TextInputType.text,
              l10n.exampleSets,
            ),

            // Custom Reps
            field(
              l10n.customReps,
              repsController,
              TextInputType.text,
              l10n.exampleReps,
            ),

            // Use Day Defaults
            if (ex.sets != null || ex.reps != null)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: clearOverride,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primaryBtn,
                  ),
                  icon: const Icon(Icons.restore_rounded, size: 17),
                  label: Text(
                    l10n.useDayDefaults,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),

            // Duration
            field(
              l10n.duration,
              durationController,
              TextInputType.text,
              l10n.exampleDuration,
            ),

            // Order
            field(
              l10n.order,
              orderController,
              TextInputType.text,
              l10n.exerciseOrder,
            ),

            const SizedBox(height: 16),

            // Save button
            SizedBox(
              height: 54,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBtn,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: save,
                child: Text(
                  l10n.save,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
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
