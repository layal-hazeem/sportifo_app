import 'package:flutter/material.dart';
import 'package:sportifo_app/features/progress/presentation/widgets/stat_card.dart';
import 'package:sportifo_app/features/subscriptions/data/models/users_subscribed_model.dart';
import 'package:sportifo_app/l10n/app_localizations.dart';

class CoachStatsRow extends StatelessWidget {
  final List<UsersSubscribedModel> clients;

  const CoachStatsRow({super.key, required this.clients});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final activeCount = clients.where((c) => c.isActive == 1).length;
    final needsPlanCount =
        clients.where((c) => (c.hasPlan ?? false) == false).length;

    return Row(
      children: [
        Expanded(
          child: StatCard(
            l10n.activeTrainees,
            '$activeCount',
            Icons.groups_rounded,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StatCard(
            l10n.needs_a_plan,
            '$needsPlanCount',
            Icons.assignment_late_rounded,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StatCard(
            l10n.totalTrainees,
            '${clients.length}',
            Icons.people_alt_rounded,
          ),
        ),
      ],
    );
  }
}