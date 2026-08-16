import 'package:flutter/material.dart';
import 'package:sportifo_app/core/theme/app_colors.dart';
import 'package:sportifo_app/l10n/app_localizations.dart';

class EditPlanEmptyDaysState extends StatelessWidget {
  const EditPlanEmptyDaysState({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.primaryBtn.withOpacity(.10),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.calendar_today_rounded,
              color: AppColors.primaryBtn,
              size: 28,
            ),
          ),
          const SizedBox(height: 16),
           Text(
            l10n.noWorkoutDaysYet,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.hintForCreateDay,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            l10n.tapPlus,
            style: TextStyle(
              color: AppColors.primaryBtn,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}