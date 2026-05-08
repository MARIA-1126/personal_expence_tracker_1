import 'package:flutter/material.dart';

import '../models/category.dart';
import '../models/transaction.dart';
import '../services/storage/category_storage.dart';
import '../services/storage/transaction_storage.dart';
import '../widgets/category_icon.dart';

/// Screen to edit an existing transaction.
class EditTransactionScreen extends StatefulWidget {
  const EditTransactionScreen({
    super.key,
    required this.storage,
    required this.transaction,
  });

  final TransactionStorage storage;
  final TransactionModel transaction;

  @override
  State<EditTransactionScreen> createState() => _EditTransactionScreenState();
}

class _EditTransactionScreenState extends State<EditTransactionScreen> {
  final _formKey = GlobalKey<FormState>();

  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  late TransactionType _type;
  late DateTime _selectedDate;
  String? _selectedCategoryId;

  late CategoryStorage _categoryStorage;
  late List<CategoryModel> _categories;

  @override
  void initState() {
    super.initState();

    _type = widget.transaction.type;
    _selectedDate = widget.transaction.date;
    _selectedCategoryId = widget.transaction.categoryId;

    _amountController.text = widget.transaction.amount.toStringAsFixed(2);
    _noteController.text = widget.transaction.note ?? '';

    _categoryStorage = CategoryStorage(widget.storage.box);
    _categories = _categoryStorage.readCategories();

    // If category was deleted from custom list, fallback to first.
    if (_categories.where((c) => c.id == _selectedCategoryId).isEmpty &&
        _categories.isNotEmpty) {
      _selectedCategoryId = _categories.first.id;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final result = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (result != null) {
      setState(() {
        _selectedDate = result;
      });
    }
  }

  void _save() async {
    final ok = _formKey.currentState?.validate() ?? false;
    if (!ok) return;

    final amount = double.parse(_amountController.text.trim());

    final updated = widget.transaction.copyWith(
      type: _type,
      amount: amount,
      categoryId: _selectedCategoryId!,
      date: DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
      ),
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
    );

    await widget.storage.updateTransaction(updated);

    if (!mounted) return;
    Navigator.of(context).pop();
  }

  void _delete() async {
    await widget.storage.deleteTransaction(widget.transaction.id);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    //main block ha
    final dateStr =
        '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Transaction')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Form to edit transaction details
            Form(
              key:
                  _formKey, //yh form create kerne wali key ha jo form ki state ko manage krne me help krti ha
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<TransactionType>(
                    initialValue:
                        _type, //yeh dropdown create krta ha transaction type ke liye aur initial value set krta ha jo transaction ka current type ha
                    items: const [
                      //yeh dropdown ke options define krta ha
                      DropdownMenuItem(
                        value: TransactionType.income,
                        child: Text('Income'),
                      ), //yeh option income type ke liye ha
                      DropdownMenuItem(
                        value: TransactionType.expense,
                        child: Text('Expense'),
                      ), //yhe option expense type ke liye ha
                    ],
                    //yh logic ha jo dropdown me value change hone par execute hoti ha aur state update krti ha
                    onChanged: (v) => setState(
                      () => _type = v ?? TransactionType.expense,
                    ), //agar value null ho jaye to default expense set krdo
                    decoration: const InputDecoration(
                      labelText: 'Type',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Amount',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      prefixIcon: Icon(Icons.attach_money),
                    ),
                    validator: (v) {
                      final text = (v ?? '').trim();
                      if (text.isEmpty) return 'Enter an amount';
                      final value = double.tryParse(text);
                      if (value == null) return 'Invalid number';
                      if (value <= 0) return 'Amount must be greater than 0';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  DropdownButtonFormField<String>(
                    value: _selectedCategoryId,
                    items: _categories
                        .map(
                          (c) => DropdownMenuItem(
                            value: c.id,
                            child: Row(
                              children: [
                                Icon(
                                  c.icon,
                                  size: 18,
                                  color: CategoryIconData.categoryColor(
                                    context,
                                    c.id,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(c.name),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _selectedCategoryId = v),
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                    ),
                    validator: (v) => v == null ? 'Choose a category' : null,
                  ),
                  const SizedBox(height: 12),

                  InkWell(
                    onTap: _pickDate,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Date',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_month),
                          const SizedBox(width: 10),
                          Text(dateStr),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: _noteController,
                    decoration: const InputDecoration(
                      labelText: 'Note (optional)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      prefixIcon: Icon(Icons.note_alt_outlined),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _save,
                          icon: const Icon(Icons.save),
                          label: const Text('Save'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      IconButton.filledTonal(
                        onPressed: _delete,
                        icon: const Icon(Icons.delete_forever),
                        tooltip: 'Delete',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
