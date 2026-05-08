import 'package:flutter/material.dart';

import '../models/category.dart';
import '../models/transaction.dart';
import '../services/storage/category_storage.dart';
import '../services/storage/transaction_storage.dart';
import '../widgets/category_icon.dart';

/// Screen to add a new income/expense transaction.
class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key, required this.storage});

  final TransactionStorage storage;

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();

  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  TransactionType _type = TransactionType.expense;
  DateTime _selectedDate = DateTime.now();

  String? _selectedCategoryId;

  late final CategoryStorage _categoryStorage;
  late final List<CategoryModel> _categories;

  @override
  void initState() {
    super.initState();
    // Category storage shares the same GetStorage instance through the TransactionStorage box.
    _categoryStorage = CategoryStorage(widget.storage.box);
    _categories = _categoryStorage.readCategories();
    _selectedCategoryId = _categories.isNotEmpty ? _categories.first.id : null;
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
    final formOk = _formKey.currentState?.validate() ?? false;
    if (!formOk) return;

    final amount = double.parse(_amountController.text.trim());

    final tx = TransactionModel(
      id: widget.storage.generateId(),
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

    await widget.storage.addTransaction(tx);

    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final dateStr =
        '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';

    return Scaffold(
      appBar: AppBar(title: const Text('Add Transaction')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<TransactionType>(
                    value: _type,
                    items: const [
                      DropdownMenuItem(
                        value: TransactionType.income,
                        child: Text('Income'),
                      ),
                      DropdownMenuItem(
                        value: TransactionType.expense,
                        child: Text('Expense'),
                      ),
                    ],
                    onChanged: (v) =>
                        setState(() => _type = v ?? TransactionType.expense),
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

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _save,
                      icon: const Icon(Icons.save),
                      label: const Text('Save'),
                    ),
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
