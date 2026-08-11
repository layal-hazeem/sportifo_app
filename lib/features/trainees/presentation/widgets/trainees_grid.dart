import 'package:flutter/material.dart';
import 'package:sportifo_app/features/trainees/data/models/coach_plan_model.dart';
import 'package:sportifo_app/features/trainees/presentation/widgets/trainee_circle.dart';

class TraineesGrid extends StatelessWidget {
  final List<CoachPlanModel> plans;
  final ValueChanged<CoachPlanModel> onTraineeTap;

  const TraineesGrid({
    super.key,
    required this.plans,
    required this.onTraineeTap,
  });

  List<CoachPlanModel> get uniqueTrainees {
    final Map<int, CoachPlanModel> latestPlans = {};

    for (final plan in plans) {
      final userId = plan.user?.id;

      if (userId == null) {
        continue;
      }

      final existingPlan = latestPlans[userId];

      if (existingPlan == null) {
        latestPlans[userId] = plan;
        continue;
      }

      final existingDate = existingPlan.createdAt;
      final currentDate = plan.createdAt;

      if (currentDate != null &&
          (existingDate == null || currentDate.isAfter(existingDate))) {
        latestPlans[userId] = plan;
      }
    }

    return latestPlans.values.toList();
  }

  @override
  Widget build(BuildContext context) {
    final trainees = uniqueTrainees;

    if (trainees.isEmpty) {
      return const Center(
        child: Text(
          'No trainees found',
          style: TextStyle(
            color: Colors.black54,
            fontSize: 15,
          ),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 22,
        mainAxisSpacing: 2,
        childAspectRatio: 0.82,
      ),
      itemCount: trainees.length,
      itemBuilder: (context, index) {
        final plan = trainees[index];

        return Center(
          child: TraineeCircle(
            plan: plan,
            index: index,
            onTap: () => onTraineeTap(plan),
          ),
        );
      },
    );
  }
}