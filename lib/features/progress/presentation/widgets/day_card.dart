import 'package:flutter/material.dart';
import 'package:sportifo_app/core/theme/app_theme_extensions.dart';
import 'package:sportifo_app/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/exercise_activity_model.dart';

class DayCard extends StatelessWidget {
  final DayActivity day;
  final bool showDetails;

  const DayCard({
    super.key,
    required this.day,
    this.showDetails = false,
  });

  @override
  Widget build(BuildContext context) {
    final monthParts = day.dateLabel.split(' ');
    final month = monthParts.length > 1 ? monthParts[1] : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: context.backgroundColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBtn.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: showDetails
          ? _ExpandableDayContent(day: day, month: month)
          : _CompactDayContent(day: day, month: month),
    );
  }
}

class _CompactDayContent extends StatelessWidget {
  final DayActivity day;
  final String month;

  const _CompactDayContent({
    required this.day,
    required this.month,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: _DayHeader(day: day, month: month),
    );
  }
}

class _ExpandableDayContent extends StatelessWidget {
  final DayActivity day;
  final String month;

  const _ExpandableDayContent({
    required this.day,
    required this.month,
  });

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        childrenPadding: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: _DayHeader(day: day, month: month),
        children: day.logs.map((log) => LogTile(log: log)).toList(),
      ),
    );
  }
}

class _DayHeader extends StatelessWidget {
  final DayActivity day;
  final String month;

  const _DayHeader({
    required this.day,
    required this.month,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primaryBtn.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            month,
            style: const TextStyle(
              color: AppColors.primaryBtn,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),),
           Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primaryBtn.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  month,
                  style: TextStyle(
                    color: AppColors.primaryBtn,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    day.dateLabel,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    "${day.totalExercises} exercises",
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  ),
                ],
              ),
            Text(
              l10n.exercises_count(day.totalExercises),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
        const Spacer(),
        Text(
          day.date,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
        ),
      ],
    );
  }
}

class LogTile extends StatelessWidget {
  final ActivityLog log;

  const LogTile({super.key, required this.log});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(top: 6),
            decoration: const BoxDecoration(
              color: AppColors.primaryBtn,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  log.exercise.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: log.sets.map((set) {
                    return Chip(
                      label: Text(
                        l10n.set_info(set.setNumber, set.reps, set.weight),
                        style: const TextStyle(fontSize: 11),
                      ),
                      backgroundColor: Colors.grey.shade100,
                      padding: EdgeInsets.zero,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      side: BorderSide.none,
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          Text(
            log.time,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }
}
