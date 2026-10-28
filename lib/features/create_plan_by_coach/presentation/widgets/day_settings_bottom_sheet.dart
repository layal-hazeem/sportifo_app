import 'package:flutter/material.dart';
import 'package:sportifo_app/core/helpers/snack_bar_utils.dart';
import 'package:sportifo_app/core/theme/app_colors.dart';
import 'package:sportifo_app/core/theme/app_theme_extensions.dart';
import 'package:sportifo_app/core/widgets/custom_glass_bottom_sheet.dart';
import 'package:sportifo_app/features/create_plan_by_coach/data/models/plan_day_ui_model.dart';
import 'package:sportifo_app/l10n/app_localizations.dart';

class DaySettingsBottomSheet extends StatefulWidget {
  final PlanDayUiModel day;

  const DaySettingsBottomSheet({super.key, required this.day});

  /// 🔥 تم التوحيد مع نظام الـ Glass الموحد
  static Future<bool?> show(BuildContext context, PlanDayUiModel day) {
    return CustomGlassBottomSheet.show<bool>(
      context: context,
      child: DaySettingsBottomSheet(day: day),
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
    final l10n = AppLocalizations.of(context)!;
    final setsText = setsController.text.trim();
    final repsText = repsController.text.trim();

    // 🔥 حماية: إذا تم تفعيل "تطبيق على الكل" بدون إدخال مجموعات وعدات، امنع الحفظ ونبه المستخدم فوراً
    if (applyToAll) {
      if (setsText.isEmpty || repsText.isEmpty) {
        AppSnackBar.show(
          context,
          message: l10n.setsAndRepsRequired,
          type: SnackBarType.warning,
        );
        return;
      }

      final parsedSets = int.tryParse(setsText);
      if (parsedSets == null || parsedSets <= 0) {
        AppSnackBar.show(
          context,
          message: l10n.setsAndRepsRequired,
          type: SnackBarType.warning,
        );
        return;
      }
    }

    widget.day.defaultSets = int.tryParse(setsText);
    widget.day.defaultReps = int.tryParse(repsText);
    widget.day.defaultSets = int.tryParse(setsController.text.trim());

    widget.day.defaultReps = repsController.text.trim();

    Navigator.pop(context, applyToAll);
  }

  Widget inputField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number, // 🔥 أرقام فقط لمنع الإدخال الخاطئ
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
          floatingLabelStyle: const TextStyle(
            color: AppColors.primaryBtn,
            fontWeight: FontWeight.w600,
          ),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: AppColors.hintText.withValues(alpha: 0.25),
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

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: AppColors.primaryBtn.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Icon(
              Icons.tune_rounded,
              size: 35,
              color: AppColors.primaryBtn,
            ),
          ),

          const SizedBox(height: 16),

          Text(
            '${widget.day.name} ${l10n.settings}',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 8),

          Text(
            l10n.daySettingsDescription,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600),
          ),

          const SizedBox(height: 25),

          inputField(l10n.defaultSets, setsController),
          inputField(l10n.defaultReps, repsController),

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
    );
  }
}