import 'package:flutter/material.dart';

import '../models/category.dart';
import '../services/storage/category_storage.dart';
import '../services/storage/transaction_storage.dart';
import '../widgets/category_icon.dart';

/// Manage predefined and custom categories.
class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key, required this.storage});

  final TransactionStorage storage;

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  late final CategoryStorage _categoryStorage;
  late List<CategoryModel> _categories;

  final _nameController = TextEditingController();

  int _selectedIconIndex = 0;

  @override
  void initState() {
    super.initState();
    _categoryStorage = CategoryStorage(widget.storage.box);
    _categories = _categoryStorage.readCategories();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _addCustom() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final iconOptions = CategoryModel.customIconOptions();
    final icon = iconOptions[_selectedIconIndex % iconOptions.length];

    final newCat = CategoryModel(
      id: 'custom_${DateTime.now().microsecondsSinceEpoch}',
      name: name,
      icon: icon,
    );

    await _categoryStorage.addCustomCategory(newCat);

    setState(() {
      _categories = _categoryStorage.readCategories();
      _nameController.clear();
      _selectedIconIndex = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Categories', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 16),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Add custom category',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Category name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Pick an icon',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 52,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: CategoryModel.customIconOptions().length,
                      itemBuilder: (context, i) {
                        final icon = CategoryModel.customIconOptions()[i];
                        final selected = i == _selectedIconIndex;
                        return Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: ChoiceChip(
                            selected: selected,
                            showCheckmark: false,
                            label: Icon(
                              icon,
                              size: 20,
                              color: selected
                                  ? Theme.of(context).colorScheme.primary
                                  : null,
                            ),
                            onSelected: (_) =>
                                setState(() => _selectedIconIndex = i),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _addCustom,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Category'),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),
          Text(
            'Your categories',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),

          for (final c in _categories)
            Card(
              elevation: 0,
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: CategoryIconData.categoryColor(
                      context,
                      c.id,
                    ).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    c.icon,
                    color: CategoryIconData.categoryColor(context, c.id),
                  ),
                ),
                title: Text(c.name),
              ),
            ),
        ],
      ),
    );
  }
}
