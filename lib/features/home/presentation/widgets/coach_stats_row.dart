import 'package:flutter/material.dart';
import 'package:sportifo_app/features/progress/presentation/widgets/stat_card.dart';
import 'package:sportifo_app/features/subscriptions/data/models/users_subscribed_model.dart';

/// Receives the FULL client list (no pre-filtering upstream) so every stat
/// here is computed from the same source of truth.
class CoachStatsRow extends StatelessWidget {
  final List<UsersSubscribedModel> clients;

  const CoachStatsRow({super.key, required this.clients});

  @override
  Widget build(BuildContext context) {
    final activeCount = clients.where((c) => c.isActive == 1).length;
    final needsPlanCount =
        clients.where((c) => (c.hasPlan ?? false) == false).length;

    return Row(
      children: [
        Expanded(
          child: StatCard(
            'Active Trainees',
            '$activeCount',
            Icons.groups_rounded,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StatCard(
            'Needs a Plan',
            '$needsPlanCount',
            Icons.assignment_late_rounded,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StatCard(
            'Total Trainees',
            '${clients.length}',
            Icons.people_alt_rounded,
          ),
        ),
      ],
    );
  }
}