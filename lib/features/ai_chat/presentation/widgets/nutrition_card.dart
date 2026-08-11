import 'package:flutter/material.dart';

class NutritionCard extends StatelessWidget {
  final double? calories;
  final double? protein;
  final double? carbs;
  final double? fat;

  const NutritionCard({
    super.key,
    this.calories,
    this.protein,
    this.carbs,
    this.fat,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      constraints: const BoxConstraints(minWidth: 240),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9F2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (calories != null)
            _Item(
              Icons.local_fire_department,
              "Cal",
              calories!,
              const Color(0xFFFF9800),
            ),
          if (protein != null)
            _Item(
              Icons.egg_alt_outlined,
              "Protein",
              protein!,
              const Color(0xFFEF5350),
            ),
          if (carbs != null)
            _Item(
              Icons.grain_outlined,
              "Carbs",
              carbs!,
              const Color(0xFFFFB300),
            ),
          if (fat != null)
            _Item(
              Icons.water_drop_outlined,
              "Fat",
              fat!,
              const Color(0xFF42A5F5),
            ),
        ],
      ),
    );
  }
}

class _Item extends StatelessWidget {
  final IconData icon;
  final String label;
  final double value;
  final Color color;

  const _Item(this.icon, this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 3),
          Text(
            value % 1 == 0 ? "${value.toInt()}g" : "${value}g",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            label,
            style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}
