import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:sportifo_app/core/theme/app_colors.dart';
import 'package:sportifo_app/core/theme/app_theme_extensions.dart';
import 'package:sportifo_app/l10n/app_localizations.dart';
import '../../data/models/weight_progress_model.dart';

class WeightProgressSection extends StatelessWidget {
  final WeightProgressData data;

  const WeightProgressSection({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final currentWeight = data.user?.weight ?? 0;
    final target = data.target;
    final history = data.weightHistory;

    final Map<String, double> lastWeightPerDay = {};
    for (final entry in history) {
      lastWeightPerDay.putIfAbsent(entry.date, () => entry.weight);
    }
    final sortedHistory =
        lastWeightPerDay.entries
            .map((e) => WeightHistoryEntry(date: e.key, weight: e.value))
            .toList()
          ..sort((a, b) => a.date.compareTo(b.date));

    double weightChange = 0;
    if (sortedHistory.length >= 2) {
      weightChange = sortedHistory.last.weight - sortedHistory.first.weight;
    }

    double minY = 0;
    double maxY = 10;
    if (sortedHistory.isNotEmpty) {
      final weights = sortedHistory.map((e) => e.weight).toList();
      final minWeight = weights.reduce((a, b) => a < b ? a : b);
      final maxWeight = weights.reduce((a, b) => a > b ? a : b);
      minY = (minWeight - 2).floorToDouble();
      maxY = (maxWeight + 2).ceilToDouble();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _StatCard(
                label: l10n.current_weight,
                value: "${currentWeight.toStringAsFixed(1)} kg",
                icon: Icons.monitor_weight,
                color: AppColors.primaryBtn,
              ),
              const SizedBox(width: 12),
              _StatCard(
                label: l10n.goal,
                value: target != null
                    ? _getGoalLabel(target.goal, l10n)
                    : l10n.not_available_short,
                icon: Icons.flag,
                color: Colors.orange,
              ),
              const SizedBox(width: 12),
              _StatCard(
                label: l10n.change,
                value:
                    "${weightChange > 0 ? '+' : ''}${weightChange.toStringAsFixed(1)} kg",
                icon: Icons.trending_up,
                color: weightChange >= 0 ? Colors.green : Colors.red,
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (sortedHistory.length >= 2) ...[
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: context.secondaryBackgroundColor,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.weight_history,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: context.textColor,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 180,
                    child: LineChart(
                      LineChartData(
                        minY: minY,
                        maxY: maxY,
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: 1,
                          getDrawingHorizontalLine: (value) => FlLine(
                            color: Colors.grey.shade200,
                            strokeWidth: 1,
                          ),
                        ),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              interval: 1,
                              getTitlesWidget: (value, meta) => Text(
                                value.toStringAsFixed(0),
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
                                    index >= sortedHistory.length ||
                                    value != value.toInt()) {
                                  return const SizedBox.shrink();
                                }
                                final date = sortedHistory[index].date;
                                final parts = date.split('-');
                                final label = parts.length >= 3
                                    ? "${parts[1]}/${parts[2]}"
                                    : date;
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    label,
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
                            spots: List.generate(sortedHistory.length, (i) {
                              return FlSpot(
                                i.toDouble(),
                                sortedHistory[i].weight,
                              );
                            }),
                            isCurved: true,
                            color: AppColors.primaryBtn,
                            barWidth: 3,
                            belowBarData: BarAreaData(
                              show: true,
                              color: AppColors.primaryBtn.withValues(
                                alpha: 0.1,
                              ),
                            ),
                            dotData: FlDotData(
                              show: true,
                              getDotPainter: (spot, percent, bar, index) {
                                return FlDotCirclePainter(
                                  radius: 5,
                                  color: AppColors.primaryBtn,
                                  strokeWidth: 2,
                                  strokeColor: Colors.white,
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getGoalLabel(String goal, AppLocalizations l10n) {
    switch (goal.toLowerCase()) {
      case 'bulk':
        return l10n.goal_bulk;
      case 'cut':
        return l10n.goal_cut;
      case 'maintain':
        return l10n.goal_maintain;
      default:
        return goal;
    }
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: context.secondaryBackgroundColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: context.textColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}
