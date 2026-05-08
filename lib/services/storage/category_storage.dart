import 'package:get_storage/get_storage.dart';

import '../../models/category.dart';
import 'transaction_storage.dart';

/// Local storage for categories (predefined + custom).
///
/// Predefined categories are always available.
/// Custom categories are persisted in GetStorage.
class CategoryStorage {
  CategoryStorage(this._box);

  static const String boxName = TransactionStorage.boxName;
  static const String categoriesKey = 'categories';

  final GetStorage _box;

  /// Returns predefined + stored custom categories.
  List<CategoryModel> readCategories() {
    final customRaw = _box.read(categoriesKey);
    final predefined = CategoryModel.predefined();

    if (customRaw == null) return predefined;
    if (customRaw is! List) return predefined;

    final custom = customRaw
        .whereType<Map>()
        .map((e) => CategoryModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    return [...predefined, ...custom];
  }

  Future<void> addCustomCategory(CategoryModel category) async {
    final currentRaw = _box.read(categoriesKey);
    final List<dynamic> list = (currentRaw is List) ? currentRaw : [];

    final json = category.toJson();
    list.insert(0, json);

    await _box.write(categoriesKey, list);
  }
}
