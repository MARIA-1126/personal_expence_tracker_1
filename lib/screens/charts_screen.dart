import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../models/transaction.dart';
import '../services/storage/transaction_storage.dart';

/// Charts screen: pie chart (category-wise expenses) + simple monthly trend.
class ChartsScreen extends StatefulWidget {
  const ChartsScreen({super.key, required this.storage});

  final TransactionStorage storage;

  @override
  State<ChartsScreen> createState() => _ChartsScreenState();
}

class _ChartsScreenState extends State<ChartsScreen> {
  late List<TransactionModel> _transactions;
  DateTime _selectedMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    _transactions = widget.storage.readTransactions();
  }

  void _refresh() {
    setState(() => _transactions = widget.storage.readTransactions());
  }

  bool _sameMonth(DateTime d) =>
      d.year == _selectedMonth.year && d.month == _selectedMonth.month;

  Map<String, double> get expenseByCategory {
    final map = <String, double>{};
    for (final t in _transactions) {
      if (t.type != TransactionType.expense) continue;
      if (!_sameMonth(t.date)) continue;
      map[t.categoryId] = (map[t.categoryId] ?? 0) + t.amount;
    }
    return map;
  }

  List<FlSpot> _incomeExpenseTrend({required bool income}) {
    // last 6 months trend
    final now = DateTime.now();
    final months = List.generate(6, (i) {
      final m = DateTime(now.year, now.month - (5 - i), 1);
      return m;
    });

    double valueForMonth(DateTime month) {
      return _transactions
          .where(
            (t) => (income
                ? t.type == TransactionType.income
                : t.type == TransactionType.expense),
          )
          .where(
            (t) => t.date.year == month.year && t.date.month == month.month,
          )
          .fold(0.0, (s, t) => s + t.amount);
    }

    return [
      for (int i = 0; i < months.length; i++)
        FlSpot(i.toDouble(), valueForMonth(months[i])),
    ];
  }

  Future<void> _pickMonth() async {
    final firstDay = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
    final result = await showDatePicker(
      context: context,
      initialDate: firstDay,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (result == null) return;
    setState(() => _selectedMonth = DateTime(result.year, result.month, 1));
    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    final expenseMap = expenseByCategory;
    final totalExpenses = expenseMap.values.fold(0.0, (a, b) => a + b);

    final sections = expenseMap.entries.map((e) {
      final value = e.value;
      final pct = totalExpenses == 0 ? 0 : value / totalExpenses;
      final color =
          Colors.primaries[(e.key.hashCode.abs()) % Colors.primaries.length];
      return PieChartSectionData(
        value: pct * 100,
        color: color.withOpacity(0.9),
        title: '',
        radius: 90,
      );
    }).toList();

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Charts', style: Theme.of(context).textTheme.headlineMedium),
              IconButton(
                onPressed: _pickMonth,
                icon: const Icon(Icons.calendar_month_outlined),
              ),
            ],
          ),
          const SizedBox(height: 8),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Category-wise Expenses',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 260,
                    child: totalExpenses == 0
                        ? const Center(
                            child: Text('No expense data for this month.'),
                          )
                        : PieChart(
                            PieChartData(
                              sections: sections,
                              sectionsSpace: 4,
                              centerSpaceRadius: 45,
                              borderData: FlBorderData(show: false),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Monthly Trend (Last 6 Months)',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 260,
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                        ),
                        titlesData: FlTitlesData(
                          leftTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: true),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 26,
                              getTitlesWidget: (value, meta) {
                                final i = value.toInt();
                                return Text(i.toString());
                              },
                            ),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        lineBarsData: [
                          LineChartBarData(
                            spots: _incomeExpenseTrend(income: true),
                            isCurved: true,
                            color: Colors.green,
                            barWidth: 3,
                            dotData: const FlDotData(show: false),
                          ),
                          LineChartBarData(
                            spots: _incomeExpenseTrend(income: false),
                            isCurved: true,
                            color: Colors.red,
                            barWidth: 3,
                            dotData: const FlDotData(show: false),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text('Green = Income, Red = Expenses'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
