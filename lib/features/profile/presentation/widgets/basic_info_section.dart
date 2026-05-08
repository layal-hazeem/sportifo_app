import 'package:flutter/material.dart';
import 'package:sportifo_app/core/theme/app_colors.dart';
import 'package:sportifo_app/l10n/app_localizations.dart';

class BasicInfoSection extends StatelessWidget {
  final String? email;
  final String? phone;
  final DateTime? birth;

  const BasicInfoSection({
    super.key,
    required this.email,
    required this.phone,
    required this.birth,
  });

  Widget _row(IconData icon, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primaryBtn),
          const SizedBox(width: 10),
          Text(value),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        _row(Icons.email, email ?? l10n.noEmail),
        _row(Icons.phone, phone ?? l10n.noPhone),
        _row(Icons.calendar_today, birth?.toString().split(" ").first ?? "-"),
      ],
    );
  }
}
