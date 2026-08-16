import 'package:flutter/material.dart';
import 'package:sportifo_app/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';

class CoachGreetingHeader extends StatelessWidget {
  final String coachName;
  final String? coachImageUrl;
  final int notificationCount;
  final VoidCallback onNotificationTap;

  const CoachGreetingHeader({
    super.key,
    required this.coachName,
    this.coachImageUrl,
    required this.notificationCount,
    required this.onNotificationTap,
  });

  String _getGreeting(AppLocalizations l10n) {
    final hour = DateTime.now().hour;

    if (hour < 12) {
      return l10n.goodMorning;
    }

    if (hour < 17) {
      return l10n.goodAfternoon;
    }

    return l10n.goodEvening;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final displayName = coachName.trim();

    return Row(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: AppColors.primaryBtn.withOpacity(0.15),
          backgroundImage: (coachImageUrl != null && coachImageUrl!.isNotEmpty)
              ? NetworkImage(coachImageUrl!)
              : null,
          child: (coachImageUrl == null || coachImageUrl!.isEmpty)
              ? Icon(Icons.person, color: AppColors.primaryBtn, size: 30)
              : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getGreeting(l10n),
                style: TextStyle(
                  fontSize: AppSizes.hintFontSize,
                  color: AppColors.hintText,
                ),
              ),
              Text(
                displayName.isEmpty ? l10n.coach : '${l10n.coach} $displayName',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                  height: 1.1,
                  color: AppColors.primaryBtn,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
