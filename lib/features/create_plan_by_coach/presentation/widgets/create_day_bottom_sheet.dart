import 'package:flutter/material.dart';
import 'package:sportifo_app/core/theme/app_colors.dart';
import 'package:sportifo_app/l10n/app_localizations.dart';

class CreateDayBottomSheet extends StatefulWidget {
  final Function(String) onCreate;

  const CreateDayBottomSheet({super.key, required this.onCreate});

  static void show(BuildContext context, Function(String) onCreate) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CreateDayBottomSheet(onCreate: onCreate),
    );
  }

  @override
  State<CreateDayBottomSheet> createState() => _CreateDayBottomSheetState();
}

class _CreateDayBottomSheetState extends State<CreateDayBottomSheet> {
  final controller = TextEditingController();
  final focusNode = FocusNode();

  bool hasText = false;

  @override
  void initState() {
    super.initState();

    controller.addListener(() {
      final value = controller.text.trim().isNotEmpty;

      if (value != hasText) {
        setState(() => hasText = value);
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    focusNode.dispose();
    super.dispose();
  }

  void _submit() {
    final value = controller.text.trim();

    if (value.isEmpty) return;

    widget.onCreate(value);
    Navigator.pop(context);
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
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
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

            const SizedBox(height: 22),

            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.primaryBtn.withOpacity(.08),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: AppColors.primaryBtn.withOpacity(.14),
                ),
              ),
              child: const Icon(
                Icons.calendar_month_rounded,
                size: 28,
                color: AppColors.primaryBtn,
              ),
            ),

            const SizedBox(height: 16),

            Text(
              l10n.createWorkoutDay,
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              l10n.giveTrainingDayName,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 24),

            TextField(
              controller: controller,
              focusNode: focusNode,
              autofocus: true,
              style: const TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                hintText: l10n.exampleChestDay,
                hintStyle: TextStyle(
                  color: Colors.grey.shade400,
                  fontWeight: FontWeight.w500,
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
                prefixIcon: const Icon(
                  Icons.fitness_center_rounded,
                  color: AppColors.primaryBtn,
                  size: 20,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: AppColors.primaryBtn,
                    width: 1.4,
                  ),
                ),
              ),
              onSubmitted: (_) => _submit(),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: hasText ? _submit : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBtn,
                  disabledBackgroundColor: Colors.grey.shade300,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  l10n.createDayButton,
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
