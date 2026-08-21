import 'package:flutter/material.dart';
import 'package:sportifo_app/core/theme/app_colors.dart';
import 'package:sportifo_app/core/theme/app_theme_extensions.dart';
import 'package:sportifo_app/features/create_plan_by_coach/data/models/plan_day_ui_model.dart';
import 'package:sportifo_app/l10n/app_localizations.dart';

class DaySettingsBottomSheet extends StatefulWidget {
  final PlanDayUiModel day;

  const DaySettingsBottomSheet({super.key, required this.day});

  static Future<bool?> show(BuildContext context, PlanDayUiModel day) async {
    return await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.backgroundColor,
      builder: (_) {
        return DaySettingsBottomSheet(day: day);
      },
    );
  }

  @override
  State<DaySettingsBottomSheet> createState() => _DaySettingsBottomSheetState();
}

class _DaySettingsBottomSheetState extends State<DaySettingsBottomSheet> {
  late TextEditingController setsController;
  late TextEditingController repsController;

  bool applyToAll = false;

  @override
  void initState() {
    super.initState();

    setsController = TextEditingController(
      text: widget.day.defaultSets?.toString() ?? '',
    );

    repsController = TextEditingController(
      text: widget.day.defaultReps?.toString() ?? '',
    );

    applyToAll = false;
  }

  @override
  void dispose() {
    setsController.dispose();
    repsController.dispose();

    super.dispose();
  }

  void save() {
    widget.day.defaultSets = int.tryParse(setsController.text.trim());

    widget.day.defaultReps = int.tryParse(repsController.text.trim());

    Navigator.pop(context, applyToAll);
  }

  Widget inputField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.text,
        style: TextStyle(
          color: context.textColor,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        cursorColor: AppColors.primaryBtn,
        decoration: InputDecoration(
          labelText: label,

          labelStyle: TextStyle(
            color: AppColors.hintText,
            fontWeight: FontWeight.w500,
          ),

          floatingLabelStyle: TextStyle(
            color: AppColors.primaryBtn,
            fontWeight: FontWeight.w600,
          ),

          filled: true,

          // لون مختلف وواضح عن خلفية الـ BottomSheet
          fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,

          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: AppColors.hintText.withOpacity(0.25),
              width: 1,
            ),
          ),

          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: AppColors.primaryBtn,
              width: 1.8,
            ),
          ),

          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),

          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 17,
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
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: context.backgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 45,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(20),
              ),
            ),

            const SizedBox(height: 20),

            // Icon
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: AppColors.primaryBtn.withOpacity(.12),
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Icon(
                Icons.tune_rounded,
                size: 35,
                color: AppColors.primaryBtn,
              ),
            ),

            const SizedBox(height: 16),

            // Title
            Text(
              '${widget.day.name} ${l10n.settings}',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8),

            // Description
            Text(
              l10n.daySettingsDescription,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),

            const SizedBox(height: 25),

            // Default Sets
            inputField(l10n.defaultSets, setsController),

            // Default Reps
            inputField(l10n.defaultReps, repsController),
            

            // Apply to all
            CheckboxListTile(
              value: applyToAll,
              activeColor: AppColors.primaryBtn,
              onChanged: (value) {
                setState(() {
                  applyToAll = value ?? false;
                });
              },
              title: Text(
                l10n.applyToAllResistanceExercises,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(l10n.applyToAllResistanceExercisesDescription),
              contentPadding: EdgeInsets.zero,
            ),

            const SizedBox(height: 10),

            // Save button
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
                child: Text(
                  l10n.saveSettings,
                  style: TextStyle(
                    color: context.textColor,
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
