import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class SpendingPieChart extends StatelessWidget {
  final Map<String, double> categorySpending;
  final Map<String, Color> categoryColors;
  final Map<String, String> categoryNames;

  const SpendingPieChart({
    super.key,
    required this.categorySpending,
    required this.categoryColors,
    required this.categoryNames,
  });

  @override
  Widget build(BuildContext context) {
    if (categorySpending.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.pie_chart_outline,
              size: 64,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No expenses this month',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      );
    }

    final total = categorySpending.values.fold(
      0.0,
      (sum, value) => sum + value,
    );

    return AspectRatio(
      aspectRatio: 1.3,
      child: PieChart(
        PieChartData(
          sectionsSpace: 2,
          centerSpaceRadius: 40,
          sections: categorySpending.entries.map((entry) {
            final percentage = (entry.value / total) * 100;
            return PieChartSectionData(
              color: categoryColors[entry.key] ?? Colors.grey,
              value: entry.value,
              title: '${percentage.toStringAsFixed(1)}%',
              radius: 60,
              titleStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
