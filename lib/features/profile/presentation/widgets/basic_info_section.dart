import 'package:flutter/material.dart';
import 'package:sportifo_app/core/theme/app_colors.dart';

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
    return Column(
      children: [
        _row(Icons.email, email!),
        _row(Icons.phone, phone ?? "No phone"),
        _row(Icons.calendar_today, birth?.toString().split(" ").first ?? "-"),
      ],
    );
  }
}
