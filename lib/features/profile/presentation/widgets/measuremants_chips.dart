import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import '../../../../core/theme/app_colors.dart';

class MeasurementsChips extends StatelessWidget {
  final dynamic sizes;

  const MeasurementsChips({super.key, required this.sizes});

  @override
  Widget build(BuildContext context) {
    final data = [
      _MeasurementItem(
        label: "Shoulders",
        value: sizes.shouldersWidth,
        icon: Icons.horizontal_rule,
      ),
      _MeasurementItem(
        label: "Chest",
        value: sizes.chestPerimeter,
        icon: Icons.architecture,
      ),
      _MeasurementItem(
        label: "Stomach",
        value: sizes.stomachPerimeter,
        icon: Icons.fitness_center,
      ),
      _MeasurementItem(
        label: "Waist",
        value: sizes.waistPerimeter,
        icon: Icons.straighten,
      ),
      _MeasurementItem(
        label: "Thigh",
        value: sizes.thighPerimeter,
        icon: Icons.directions_walk,
      ),
      _MeasurementItem(
        label: "Hip",
        value: sizes.hipPerimeter,
        icon: Icons.accessibility_new,
      ),
      _MeasurementItem(
        label: "Arm",
        value: sizes.armPerimeter,
        icon: Icons.front_hand_outlined,
      ),
    ].where((e) => e.value != null).toList();

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: data.map((e) {
        return Neumorphic(
          style: NeumorphicStyle(
            depth: 3,
            intensity: 0.8,
            color: Colors.white,
            boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(18)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(e.icon, size: 18, color: AppColors.primaryBtn),
              const SizedBox(width: 6),
              Text(
                e.label,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(width: 6),
              Text(
                "${e.value} cm",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}



class _MeasurementItem {
  final String label;
  final double? value;
  final IconData icon;

  _MeasurementItem({
    required this.label,
    required this.value,
    required this.icon,
  });
}
