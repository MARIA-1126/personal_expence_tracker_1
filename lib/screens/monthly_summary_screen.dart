import 'package:flutter/material.dart';

import '../models/transaction.dart';
import '../services/storage/transaction_storage.dart';
import '../widgets/summary_card.dart';

/// Monthly summary screen.
class MonthlySummaryScreen extends StatefulWidget {
  const MonthlySummaryScreen({super.key, required this.storage});

  final TransactionStorage storage;

  @override
  State<MonthlySummaryScreen> createState() => _MonthlySummaryScreenState();
}

class _MonthlySummaryScreenState extends State<MonthlySummaryScreen> {
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

  double get income => _transactions
      .where((t) => t.type == TransactionType.income && _sameMonth(t.date))
      .fold(0.0, (s, t) => s + t.amount);
  double get expense => _transactions
      .where((t) => t.type == TransactionType.expense && _sameMonth(t.date))
      .fold(0.0, (s, t) => s + t.amount);
  double get remaining => income - expense;

  String get _monthLabel =>
      '${_selectedMonth.year}-${_selectedMonth.month.toString().padLeft(2, '0')}';

  Future<void> _pickMonth() async {
    final firstDay = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
    final result = await showDatePicker(
      context: context,
      initialDate: firstDay,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (result == null) return;
    setState(() {
      _selectedMonth = DateTime(result.year, result.month, 1);
    });
    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async => _refresh(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Monthly Summary',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 12),

            Card(
              child: ListTile(
                leading: const Icon(Icons.calendar_month_outlined),
                title: Text(_monthLabel),
                trailing: IconButton(
                  icon: const Icon(Icons.edit_calendar_outlined),
                  onPressed: _pickMonth,
                ),
              ),
            ),
            const SizedBox(height: 16),

            SummaryCard(
              label: 'Income',
              value: income,
              icon: Icons.trending_up,
              valueColor: Colors.green,
            ),
            const SizedBox(height: 12),

            SummaryCard(
              label: 'Expenses',
              value: expense,
              icon: Icons.trending_down,
              valueColor: Colors.red,
            ),
            const SizedBox(height: 12),

            SummaryCard(
              label: 'Remaining',
              value: remaining,
              icon: Icons.account_balance_wallet,
              valueColor: remaining >= 0 ? Colors.green : Colors.red,
            ),
          ],
        ),
      ),
    );
  }
}
