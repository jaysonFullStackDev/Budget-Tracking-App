// lib/widgets/charts/chart_widgets.dart
// All fl_chart-based chart components used in the Reports screen.

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../utils/app_theme.dart';
import '../../utils/constants.dart';

// ── Pie Chart: Expense by Category ────────────────────────────
class ExpensePieChart extends StatefulWidget {
  final Map<String, double> data; // {category: amount}

  const ExpensePieChart({super.key, required this.data});

  @override
  State<ExpensePieChart> createState() => _ExpensePieChartState();
}

class _ExpensePieChartState extends State<ExpensePieChart> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    if (widget.data.isEmpty) {
      return const Center(child: Text('No expense data',
        style: TextStyle(color: Colors.grey)));
    }

    final entries = widget.data.entries.toList();
    final total   = widget.data.values.fold(0.0, (a, b) => a + b);

    return Row(children: [
      Expanded(
        flex: 3,
        child: PieChart(
          PieChartData(
            pieTouchData: PieTouchData(
              touchCallback: (event, response) {
                setState(() {
                  _touchedIndex = response?.touchedSection?.touchedSectionIndex ?? -1;
                });
              },
            ),
            sections: entries.asMap().entries.map((e) {
              final i      = e.key;
              final entry  = e.value;
              final isTouched = i == _touchedIndex;
              return PieChartSectionData(
                value:     entry.value,
                title:     '${(entry.value / total * 100).toStringAsFixed(1)}%',
                radius:    isTouched ? 85 : 70,
                color:     AppTheme.getCategoryColor(entry.key),
                titleStyle: TextStyle(
                  fontSize:   isTouched ? 13 : 11,
                  fontWeight: FontWeight.w700,
                  color:      Colors.white,
                ),
              );
            }).toList(),
            centerSpaceRadius: 40,
            sectionsSpace:     3,
          ),
        ),
      ),
      const SizedBox(width: 16),
      Expanded(
        flex: 2,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: entries.map((e) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(children: [
              Container(width: 12, height: 12,
                decoration: BoxDecoration(
                  color:        AppTheme.getCategoryColor(e.key),
                  borderRadius: BorderRadius.circular(3),
                )),
              const SizedBox(width: 8),
              Expanded(child: Text(e.key,
                style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis)),
            ]),
          )).toList(),
        ),
      ),
    ]);
  }
}

// ── Bar Chart: Monthly Income vs Expense ──────────────────────
class MonthlyBarChart extends StatelessWidget {
  final Map<String, Map<String, double>> data;
  // data = { 'Jan 2025': {'income': X, 'expense': Y}, ... }

  const MonthlyBarChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(child: Text('No monthly data',
        style: TextStyle(color: Colors.grey)));
    }

    final entries = data.entries.toList();
    final maxY = entries.fold<double>(0, (m, e) =>
      [m, e.value['income']!, e.value['expense']!].reduce(
        (a, b) => a > b ? a : b));

    return BarChart(
      BarChartData(
        maxY:        maxY * 1.2,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, gi, rod, ri) => BarTooltipItem(
              CurrencyFormatter.format(rod.toY),
              const TextStyle(color: Colors.white, fontSize: 11,
                fontWeight: FontWeight.w600),
            ),
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles:    true,
              reservedSize:  48,
              getTitlesWidget: (v, _) => Text(
                CurrencyFormatter.format(v, symbol: '₱').replaceAll(',000', 'k'),
                style: const TextStyle(fontSize: 9, color: Colors.grey),
              ),
            ),
          ),
          rightTitles:  AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:    AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles:    true,
              reservedSize:  28,
              getTitlesWidget: (v, _) {
                final idx = v.toInt();
                if (idx < 0 || idx >= entries.length) return const Text('');
                final label = entries[idx].key.split(' ').first;
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(label,
                    style: const TextStyle(fontSize: 10, color: Colors.grey)),
                );
              },
            ),
          ),
        ),
        gridData:    FlGridData(
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) => FlLine(
            color: Colors.grey.withOpacity(0.15), strokeWidth: 1),
        ),
        borderData: FlBorderData(show: false),
        barGroups:  entries.asMap().entries.map((e) =>
          BarChartGroupData(
            x: e.key,
            barRods: [
              BarChartRodData(
                toY:             e.value.value['income']!,
                color:           AppTheme.successColor,
                width:           10,
                borderRadius:    const BorderRadius.vertical(top: Radius.circular(4)),
              ),
              BarChartRodData(
                toY:             e.value.value['expense']!,
                color:           AppTheme.errorColor,
                width:           10,
                borderRadius:    const BorderRadius.vertical(top: Radius.circular(4)),
              ),
            ],
            barsSpace: 4,
          ),
        ).toList(),
      ),
    );
  }
}

// ── Line Chart: Spending Trend ─────────────────────────────────
class SpendingTrendChart extends StatelessWidget {
  // spots: list of {x: day, y: cumulativeSpend}
  final List<FlSpot> spots;

  const SpendingTrendChart({super.key, required this.spots});

  @override
  Widget build(BuildContext context) {
    if (spots.isEmpty) {
      return const Center(child: Text('No trend data',
        style: TextStyle(color: Colors.grey)));
    }

    final maxY = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b);

    return LineChart(
      LineChartData(
        minY: 0,
        maxY: maxY * 1.2,
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (spots) => spots.map((s) => LineTooltipItem(
              CurrencyFormatter.format(s.y),
              const TextStyle(color: Colors.white, fontSize: 11,
                fontWeight: FontWeight.w600),
            )).toList(),
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles:   true,
              reservedSize: 48,
              getTitlesWidget: (v, _) => Text(
                v >= 1000
                    ? '${(v / 1000).toStringAsFixed(0)}k'
                    : v.toStringAsFixed(0),
                style: const TextStyle(fontSize: 9, color: Colors.grey),
              ),
            ),
          ),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:   AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles:   true,
              reservedSize: 28,
              getTitlesWidget: (v, _) => Text(
                'Day ${v.toInt()}',
                style: const TextStyle(fontSize: 9, color: Colors.grey),
              ),
            ),
          ),
        ),
        gridData: FlGridData(
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) => FlLine(
            color: Colors.grey.withOpacity(0.15), strokeWidth: 1),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots:         spots,
            isCurved:      true,
            color:         AppTheme.accentColor,
            barWidth:      3,
            isStrokeCapRound: true,
            dotData:       FlDotData(show: false),
            belowBarData:  BarAreaData(
              show:  true,
              color: AppTheme.accentColor.withOpacity(0.15),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Chart Card Container ───────────────────────────────────────
class ChartCard extends StatelessWidget {
  final String title;
  final Widget child;
  final double height;

  const ChartCard({
    super.key,
    required this.title,
    required this.child,
    this.height = 220,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding:    const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color:        theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04),
            blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w700)),
        const SizedBox(height: 16),
        SizedBox(height: height, child: child),
      ]),
    );
  }
}

// ── Legend Row ─────────────────────────────────────────────────
class ChartLegend extends StatelessWidget {
  const ChartLegend({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      _dot(AppTheme.successColor), const SizedBox(width: 6),
      const Text('Income', style: TextStyle(fontSize: 12)),
      const SizedBox(width: 20),
      _dot(AppTheme.errorColor), const SizedBox(width: 6),
      const Text('Expense', style: TextStyle(fontSize: 12)),
    ]);
  }

  Widget _dot(Color color) => Container(
    width: 10, height: 10,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );
}
