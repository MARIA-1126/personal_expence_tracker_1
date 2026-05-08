// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

import '../models/transaction.dart';
import '../services/storage/transaction_storage.dart';
import '../widgets/category_icon.dart';
import '../widgets/summary_card.dart';
import '../widgets/transaction_tile.dart';
import 'add_transaction_screen.dart';
import 'edit_transaction_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({
    super.key,
    required this.storage,
  }); //yh ik constructor ha jhn se do valus pass ho rhi ha super key ..means parent class ka constructor and storage means transaction storage ka instance pass ho rha ha taki uska use kr ske

  final TransactionStorage
  storage; //yh variable ha jhn transaction storage ka instance store ho rha ha taki uska use kr ske

  @override
  State<DashboardScreen> createState() => _DashboardScreenState(); //_means private class ha jhn se dashboard screen ka state manage ho rha ha =>means k _dashboard screen ko return kerna ha jhn se dashboard screen ka state manage ho rha ha
}

//new class header k lie
class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader({
    required this.onAdd,
  }); //constructor ha jhn se onAdd function pass ho rha ha taki uska use kr ske

  final VoidCallback onAdd; //variable ha

  @override
  //build method creater ho rha ha
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment
          .spaceBetween, //row ke andar text aur button ko left aur right align krne k liye mainAxisAlignment use krte ha
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment
              .start, //column ke andar text ko left align krne k liye crossAxisAlignment use krte ha
          children: [
            Text(
              'Dashboard',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),

            Text(
              'Overview of your cashflow',
              style: TextStyle(
                fontSize: 16,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        IconButton.filledTonal(
          onPressed: onAdd,
          icon: const Icon(Icons.add_rounded), //icon ko round kre ga
          tooltip:
              'Add transaction', //hover krne pe button ka naam show krne k liye tooltip use krte ha
        ),
      ],
    );
  }
}

//yh mis section ha
class _DashboardScreenState extends State<DashboardScreen> {
  late List<TransactionModel> _transactions;

  @override
  void initState() {
    //init state is lie ha k transactionModel main jo transactions ha un ko ik new variable _transactions main store kr le
    super
        .initState(); //parent class yahi k DashboardScreenState ka init state call krna hoga taki wo bhi initialize ho jaye
    _transactions = widget.storage
        .readTransactions(); //yhn widget.storage.readTransactions() use krna hoga taki storage se transactions read kr ke _transactions main store kr le taki uska use kr ske
  }

  void _refresh() {
    setState(() {
      _transactions = widget.storage
          .readTransactions(); //yhn setState use krna hoga taki jab bhi transactions update ho to wo screen ko refresh kr de aur widget.storage.readTransactions() use krna hoga taki storage se transactions read kr ke _transactions main store kr le taki uska use kr ske
    });
  }

  double _incomeTotal() {
    //yh ik function ha jhn se income transactions ka total calculate kr ke return krna ha
    return _transactions
        .where(
          (t) => t.type == TransactionType.income,
        ) //yhn transactionType k ander income find ho rhi ha
        .fold(
          0.0,
          (sum, t) => sum + t.amount,
        ); //aur yhn calculate kr rha ha k income transactions ka total kitna ha jhn se fold use krte ha taki transactions ka total calculate kr ke return kr de aur 0.0 means initial value ha aur sum + t.amount means har transaction ka amount ko sum main add krte jao taki total mil jaye
  }

  double _expenseTotal() {
    return _transactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);
  } //same income jessehi ha

  double _balance() => _incomeTotal() - _expenseTotal();
  //yhn ik private variable bnaya ha jis main balance calculate kr ke return krna ha jhn se income total main se expense total minus kr ke balance mil jaye

  List<TransactionModel> _recentTransactions() {
    // Already inserted newest first; show top 8.
    return _transactions.take(8).toList();
  }

  void _goAdd() async {
    //wait kre ga jab tak add transaction screen se data return na ho jaye taki uske baad hi dashboard screen refresh ho jaye
    await Navigator.of(context).push(
      //yhn navigator use krna hoga taki add transaction screen pe navigate kr ske aur uske baad dashboard screen pe wapas aa jaye
      MaterialPageRoute(
        builder: (context) => AddTransactionScreen(
          storage: widget.storage,
        ), //dashboard screen se ai ho storage jo transaction screen ko de rha ha
        //yhn add transaction screen ko builder k through call krna hoga taki usme storage pass ho jaye
      ),
    );
    _refresh(); //yhn refresh function call krna hoga taki jab bhi add transaction screen se data return ho jaye to dashboard screen refresh ho jaye aur naya transaction show ho jaye
  }

  void _goEdit(TransactionModel tx) async {
    //wait kre ga jab tak edit transaction screen se data return na ho jaye taki uske baad hi dashboard screen refresh ho jaye
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditTransactionScreen(
          storage: widget.storage,
          transaction: tx,
        ), //dashboard screen se ai ho storage jo transaction screen ko de rha ha aur transaction jhn se edit krna ha wo bhi pass ho rha ha
      ),
    );
    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    //yhn se UI build ho rhi ha uper sab is main use hoi we methods the
    final income = _incomeTotal();
    final expense = _expenseTotal();
    final balance = _balance();
    //yhn per sab ko initialize ker rhe ha
    return Scaffold(
      body: SafeArea(
        //yhn safe area use krna hoga taki screen ke uper status bar aur neeche navigation bar ke andar content na chala jaye
        child: RefreshIndicator(
          //yhn refresh indicator use krna hoga taki pull to refresh ka feature mile aur onRefresh use krna hoga taki jab bhi user pull to refresh kare to _refresh function call ho jaye aur screen refresh ho jaye
          onRefresh: () async => _refresh(), //
          child: ListView(
            //screen ko scrollable banane k liye list view use krte ha taki agar transactions zyada ho jaye to user scroll kr ke dekh ske
            padding: const EdgeInsets.all(
              16,
            ), //yhn padding use krna hoga taki screen ke uper se content thoda neeche aaye aur sides se bhi thoda andar aaye taki design accha lage
            children: [
              const SizedBox(height: 4),
              _DashboardHeader(
                onAdd: _goAdd,
              ), //yhn dashboard header use krna hoga taki screen ke uper dashboard ka title aur add button show ho jaye aur onAdd use krna hoga taki jab bhi add button pe click ho to _goAdd function call ho jaye aur add transaction screen pe navigate ho jaye
              const SizedBox(height: 60),
              SummaryCard(
                label: 'Balance',
                value: balance,
                icon: Icons.account_balance_wallet_rounded,
                valueColor: balance >= 0
                    ? Colors.greenAccent
                    : Colors.blueAccent,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: SummaryCard(
                      label: 'Income',
                      value: income,
                      icon: Icons.trending_up_rounded,
                      valueColor: Colors.greenAccent,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SummaryCard(
                      label: 'Expenses',
                      value: expense,
                      icon: Icons.trending_down_rounded,
                      valueColor: Colors.redAccent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Transactions',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium, //yhn text style use krna hoga taki recent transactions ka title accha lage
                  ),
                  FilledButton.tonal(
                    onPressed: _goAdd,
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add_rounded),
                        SizedBox(width: 8),
                        Text('Add'),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (_transactions.isEmpty)
                Card(
                  elevation: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      children: [
                        Icon(
                          Icons.receipt_long_rounded,
                          size: 44,
                          color: Theme.of(context).colorScheme.primary.withOpacity(
                            0.9,
                          ), //yhn icon use krna hoga taki jab bhi transactions empty ho to receipt ka icon show ho jaye aur color scheme se primary color use krna hoga taki app ke theme ke hisab se color set ho jaye aur opacity use krna hoga taki color thoda light ho jaye
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'No transactions yet',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Add your first income/expense to see analytics and charts.',
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              else
                ..._recentTransactions().map((tx) {
                  //yhn recent transactions ko map kr ke transaction tile banani ha taki recent transactions show ho jaye aur ... use krna hoga taki list of widgets ko expand kr ke list view ke children main add kr de
                  return Dismissible(
                    key: ValueKey(tx.id),

                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 16),
                      color: Colors.red.withOpacity(0.15),
                      child: const Icon(
                        Icons.delete_rounded,
                        color: Colors.redAccent,
                      ),
                    ),
                    onDismissed: (d) async {
                      //yhn onDismissed use krna hoga taki jab bhi user transaction ko swipe karke delete kare to wo transaction delete ho jaye aur dashboard screen refresh ho jaye taki deleted transaction show na ho jaye
                      await widget.storage.deleteTransaction(
                        tx.id,
                      ); //yhn widget.storage.deleteTransaction use krna hoga taki storage se transaction delete ho jaye aur tx.id use krna hoga taki jis transaction ko delete krna ha uska id pass ho jaye taki wo transaction delete ho jaye
                      _refresh();
                      if (mounted) {
                        //yhn mounted use krna hoga taki jab bhi screen dispose ho jaye to snackbar show na ho jaye aur agar screen mounted ha to snackbar show ho jaye
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Transaction deleted')),
                        );
                      }
                    },
                    child: TransactionTile(
                      onTap: () => _goEdit(tx),
                      title: tx.categoryId,
                      date: tx.date,
                      note: tx.note,
                      amount: tx.amount,
                      icon: CategoryIconData.categoryIcon(tx.categoryId),
                    ),
                  );
                }),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        //yhn floating action button use krna hoga taki screen ke neeche add button show ho jaye aur extended use krna hoga taki button ke andar icon aur text dono show ho jaye
        onPressed: _goAdd,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add'),
      ),
    );
  }
}
