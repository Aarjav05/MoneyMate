import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class SpendingPieChart extends StatefulWidget {
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
  State<SpendingPieChart> createState() => _SpendingPieChartState();
}

class _SpendingPieChartState extends State<SpendingPieChart> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (widget.categorySpending.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.pie_chart_outline,
                  size: 48,
                  color: theme.colorScheme.primary.withValues(alpha: 0.4),
                ),
              ),
              const SizedBox(height: 16),
              Text('No expenses this month', style: theme.textTheme.bodyLarge),
            ],
          ),
        ),
      );
    }

    final total = widget.categorySpending.values.fold(
      0.0,
      (sum, value) => sum + value,
    );

    final sortedEntries = widget.categorySpending.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      children: [
        // Chart — constrained so it doesn't blow up on wide screens
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 280, maxHeight: 280),
            child: PieChart(
              PieChartData(
                sectionsSpace: 3,
                centerSpaceRadius: 40,
                pieTouchData: PieTouchData(
                  touchCallback: (event, pieTouchResponse) {
                    setState(() {
                      if (!event.isInterestedForInteractions ||
                          pieTouchResponse == null ||
                          pieTouchResponse.touchedSection == null) {
                        _touchedIndex = -1;
                        return;
                      }
                      _touchedIndex =
                          pieTouchResponse.touchedSection!.touchedSectionIndex;
                    });
                  },
                ),
                sections: sortedEntries.asMap().entries.map((mapEntry) {
                  final idx = mapEntry.key;
                  final entry = mapEntry.value;
                  final isTouched = idx == _touchedIndex;
                  final percentage = (entry.value / total) * 100;
                  final color = widget.categoryColors[entry.key] ?? Colors.grey;

                  return PieChartSectionData(
                    color: color,
                    value: entry.value,
                    title: isTouched
                        ? '${percentage.toStringAsFixed(1)}%'
                        : percentage >= 8
                        ? '${percentage.toStringAsFixed(0)}%'
                        : '',
                    radius: isTouched ? 60 : 50,
                    titleStyle: TextStyle(
                      fontSize: isTouched ? 14 : 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          blurRadius: 4,
                          color: Colors.black.withValues(alpha: 0.3),
                        ),
                      ],
                    ),
                    badgePositionPercentageOffset: .98,
                  );
                }).toList(),
              ),
              swapAnimationDuration: const Duration(milliseconds: 400),
              swapAnimationCurve: Curves.easeInOutCubic,
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Legend
        Wrap(
          spacing: 16,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: sortedEntries.map((entry) {
            final color = widget.categoryColors[entry.key] ?? Colors.grey;
            final name = widget.categoryNames[entry.key] ?? 'Unknown';
            final pct = ((entry.value / total) * 100).toStringAsFixed(1);

            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '$name ($pct%)',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}
