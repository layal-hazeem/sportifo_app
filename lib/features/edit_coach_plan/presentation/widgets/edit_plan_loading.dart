import 'package:flutter/material.dart';
import 'package:sportifo_app/core/theme/app_colors.dart';
import 'package:sportifo_app/core/theme/app_theme_extensions.dart';
import 'package:sportifo_app/l10n/app_localizations.dart';

class EditPlanLoadingDialog extends StatelessWidget {
  const EditPlanLoadingDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Dialog(
      backgroundColor: context.backgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: AppColors.primaryBtn.withOpacity(.12),
                shape: BoxShape.circle,
              ),
              child: const Padding(
                padding: EdgeInsets.all(18),
                child: CircularProgressIndicator(
                  strokeWidth: 4,
                  color: AppColors.primaryBtn,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "${l10n.saveChanges}...",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.waitUpdatePlan,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.hintText, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
