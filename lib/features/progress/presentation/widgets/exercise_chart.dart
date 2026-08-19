import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:sportifo_app/core/theme/app_theme_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/exercise_activity_model.dart';

class ExerciseChart extends StatelessWidget {
  final List<DayActivity> days;

  const ExerciseChart({super.key, required this.days});

  @override
  Widget build(BuildContext context) {
    final sortedDays = List<DayActivity>.from(days)
      ..sort((a, b) => a.date.compareTo(b.date));

    double maxY = 6;
    if (sortedDays.isNotEmpty) {
      final maxExercises = sortedDays
          .map((e) => e.totalExercises)
          .reduce((a, b) => a > b ? a : b);
      maxY = (maxExercises + 1).toDouble();
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.backgroundColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBtn.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Exercises Per Day",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: context.textColor,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: maxY,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 1,
                  getDrawingHorizontalLine: (value) =>
                      FlLine(color: Colors.grey.shade200, strokeWidth: 1),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (value, meta) => Text(
                        value.toInt().toString(),
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 ||
                            index >= sortedDays.length ||
                            value != value.toInt()) {
                          return const SizedBox.shrink();
                        }
                        final parts = sortedDays[index].dateLabel.split(' ');
                        final day = parts.isNotEmpty
                            ? parts.first.replaceAll(',', '')
                            : '';
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            day,
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: List.generate(sortedDays.length, (i) {
                      return FlSpot(
                        i.toDouble(),
                        sortedDays[i].totalExercises.toDouble(),
                      );
                    }),
                    isCurved: true,
                    color: AppColors.primaryBtn,
                    barWidth: 3,
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.primaryBtn.withValues(alpha: 0.1),
                    ),
                    dotData: const FlDotData(show: true),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
