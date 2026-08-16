import 'package:flutter/material.dart';
import 'package:sportifo_app/core/theme/app_colors.dart';
import 'package:sportifo_app/l10n/app_localizations.dart';

class EditPlanBottomBar extends StatelessWidget {
  final int currentStep;
  final VoidCallback onBack;
  final VoidCallback onNext;

  const EditPlanBottomBar({
    super.key,
    required this.currentStep,
    required this.onBack,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          if (currentStep == 1) ...[
            Expanded(
              child: OutlinedButton(
                onPressed: onBack,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: AppColors.primaryBtn),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child:  Text(
                  l10n.back,
                  style: TextStyle(
                    color: AppColors.primaryBtn,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            flex: currentStep == 1 ? 2 : 1,
            child: ElevatedButton(
              onPressed: onNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBtn,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: Text(
                currentStep == 0 ? l10n.next : l10n.saveChanges,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
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