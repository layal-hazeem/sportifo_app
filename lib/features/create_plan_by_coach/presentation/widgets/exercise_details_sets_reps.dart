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

    // 🔥 استماع فوري لأي تغيير لتحديث حالة الزر
    setsController.addListener(_onFieldChanged);
    repsController.addListener(_onFieldChanged);
    durationController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    setsController.removeListener(_onFieldChanged);
    repsController.removeListener(_onFieldChanged);
    durationController.removeListener(_onFieldChanged);
    setsController.dispose();
    repsController.dispose();
    durationController.dispose();
    orderController.dispose();

    super.dispose();
  }

  /// 🔥 التحقق من صحة الإدخال لتفعيل زر الحفظ
  bool get _isSaveEnabled {
    if (widget.exercise.isCardio) {
      return durationController.text.trim().isNotEmpty;
    }
    return setsController.text.trim().isNotEmpty &&
        repsController.text.trim().isNotEmpty;
  }

  void clearOverride() {
    setsController.clear();
    repsController.clear();

    widget.exercise.sets = null;
    widget.exercise.reps = null;

    setState(() {});
  }

  void save() {
    if (!_isSaveEnabled) return;

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

  Widget field({
    required String label,
    required TextEditingController controller,
    required TextInputType keyboard,
    required String hint,
    bool isRequired = false,
  }) {
    final isEmpty = controller.text.trim().isEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        keyboardType: keyboard,
        textInputAction: TextInputAction.next,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: context.textColor,
        ),
        decoration: InputDecoration(
          labelText: isRequired ? "$label *" : label,
          hintText: hint,
          hintStyle: TextStyle(
            color: Colors.grey.shade400,
            fontSize: 13,
            fontWeight: FontWeight.w400,
          ),
          filled: true,
          // 🔥 لون الحقل الموحد والمتناسق مع الوضعين الفاتح والليلي
          fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          labelStyle: const TextStyle(
            color: AppColors.primaryBtn,
            fontWeight: FontWeight.w600,
          ),
          floatingLabelStyle: const TextStyle(
            color: AppColors.primaryBtn,
            fontWeight: FontWeight.w600,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
              color: AppColors.hintText.withValues(alpha: 0.25),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
              color: (isRequired && isEmpty)
                  ? Colors.orange.withValues(alpha: 0.5) // تنبيه عند النقص
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
    final ex = widget.exercise;
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: CachedStaticGif(imageUrl: ex.gifUrl ?? ''),
              ),
            ),

            const SizedBox(height: 22),

            // Exercise name
            Text(
              ex.name,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
                color: context.textColor,
              ),
            ),

            const SizedBox(height: 8),

            // Exercise description
            Text(
              ex.description,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 13.5,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 24),

            // Info message
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest
                    .withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.primaryBtn.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: context.backgroundColor,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.grey.withValues(alpha: 0.2),
                      ),
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
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                        color: context.textColor,
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

            if (!ex.isCardio) ...[
              // Custom Sets
              field(
                label: l10n.customSets,
                controller: setsController,
                keyboard: TextInputType.number,
                hint: l10n.exampleSets,
                isRequired: true,
              ),

              // Custom Reps
              field(
                label: l10n.customReps,
                controller: repsController,
                keyboard: TextInputType.number,
                hint: l10n.exampleReps,
                isRequired: true,
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
            ] else ...[
              // Duration (For cardio)
              field(
                label: l10n.duration,
                controller: durationController,
                keyboard: TextInputType.text,
                hint: l10n.exampleDuration,
                isRequired: true,
              ),
            ],

            // Order
            field(
              label: l10n.order,
              controller: orderController,
              keyboard: TextInputType.number,
              hint: l10n.exerciseOrder,
              isRequired: false,
            ),

            const SizedBox(height: 16),

            // 🔥 Save button معطل حتى كتابة القيم المطلوبة
            SizedBox(
              height: 54,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBtn,
                  disabledBackgroundColor: isDark
                      ? Colors.white.withValues(alpha: 0.12)
                      : Colors.grey.shade300,
                  disabledForegroundColor: isDark
                      ? Colors.white38
                      : Colors.grey.shade500,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: _isSaveEnabled ? save : null,
                child: Text(
                  l10n.save,
                  style: const TextStyle(
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