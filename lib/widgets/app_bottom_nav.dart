import 'package:flutter/material.dart';

import '../screens/charts_screen.dart';
import '../screens/dashboard_screen.dart';
import '../screens/monthly_summary_screen.dart';
import '../screens/categories_screen.dart';

import '../services/storage/transaction_storage.dart';

/// Simple bottom navigation to keep app beginner-friendly.
class AppBottomNav extends StatefulWidget {
  const AppBottomNav({super.key, required this.storage});

  final TransactionStorage storage;

  @override
  State<AppBottomNav> createState() => _AppBottomNavState();
}

class _AppBottomNavState extends State<AppBottomNav> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          DashboardScreen(storage: widget.storage),
          CategoriesScreen(storage: widget.storage),
          MonthlySummaryScreen(storage: widget.storage),
          ChartsScreen(storage: widget.storage),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.category_outlined),
            label: 'Categories',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            label: 'Summary',
          ),
          NavigationDestination(
            icon: Icon(Icons.pie_chart_outline),
            label: 'Charts',
          ),
        ],
      ),
    );
  }
}

/// Minimal version of IndexedStack to avoid importing extra widgets.
class IndexedStack extends StatelessWidget {
  const IndexedStack({super.key, required this.index, required this.children});

  final int index;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        for (int i = 0; i < children.length; i++)
          Offstage(
            offstage: i != index,
            child: TickerMode(
              enabled: i == index,
              child: SizedBox.expand(child: children[i]),
            ),
          ),
      ],
    );
  }
}
