import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';

class CoachInfoBadges extends StatelessWidget {
  final int yearsOfExp;
  final String dateOfBirth;
  final int gender;

  const CoachInfoBadges({
    super.key,
    required this.yearsOfExp,
    required this.dateOfBirth,
    required this.gender,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    int age = 0;
    if (dateOfBirth.isNotEmpty) {
      try {
        age = DateTime.now().year - DateTime.parse(dateOfBirth).year;
      } catch (_) {}
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildBadge(label: l10n.years_exp_badge(yearsOfExp), icon: Icons.calendar_today_outlined),
          const SizedBox(width: 10),
          if (age > 0) ...[
            _buildBadge(label: l10n.age_badge(age), icon: Icons.cake_outlined),
            const SizedBox(width: 10),
          ],
          _buildBadge(
            label: gender == 1 ? l10n.male : l10n.female,
            icon: gender == 1 ? Icons.male_outlined : Icons.female_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildBadge({required String label, required IconData icon}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.withOpacity(0.08)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xFF666666), size: 15),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF333333),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}