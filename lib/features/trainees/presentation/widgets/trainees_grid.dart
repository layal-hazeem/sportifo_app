import 'package:flutter/material.dart';
import 'package:sportifo_app/core/theme/app_colors.dart';
import 'package:sportifo_app/features/trainees/data/models/coach_plan_model.dart';
import 'package:sportifo_app/features/trainees/presentation/widgets/trainee_card_horizontal.dart';
import 'package:sportifo_app/l10n/app_localizations.dart'; // تأكد من مسار الاستيراد الصحيح

class TraineesGrid extends StatelessWidget {
  final List<CoachPlanModel> plans;
  final Function(CoachPlanModel) onTraineeTap;

  const TraineesGrid({
    super.key,
    required this.plans,
    required this.onTraineeTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (plans.isEmpty) {
      return Center(
        child: Text(
          l10n.noTraineesFound,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.hintText,
          ),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16, 
        childAspectRatio: 1.6, 
      ),
      itemCount: plans.length,
      itemBuilder: (context, index) {
        return TraineeCardHorizontal(
          plan: plans[index],
          index: index,
          onTap: () => onTraineeTap(plans[index]),
        );
      },
    );
  }
}