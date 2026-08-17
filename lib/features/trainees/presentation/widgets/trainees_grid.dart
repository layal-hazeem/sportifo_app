import 'package:flutter/material.dart';
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
            color: Colors.grey.shade500,
          ),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // عمودين لملء الواجهة وجعل الكاردات عريضة وواضحة
        crossAxisSpacing: 16, // المسافة الأفقية بين الكاردات
        mainAxisSpacing: 16, // المسافة العمودية بين الكاردات
        childAspectRatio: 1.6, // نسبة العرض للارتفاع لتناسب التصميم الأفقي
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