import 'package:flutter/material.dart';

/// Simple category model.
/// Predefined categories are shown with built-in Material icons.
class CategoryModel {
  final String id;
  final String name;

  /// Icon code to recreate Material icon.
  /// We store this as an [IconData] code name.
  final IconData icon;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
  });

  static const String predefinedPrefix = 'pre_';

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'iconCodePoint': icon.codePoint,
      'iconFontFamily': icon.fontFamily,
      'iconFontPackage': icon.fontPackage,
    };
  }

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: IconData(
        json['iconCodePoint'] as int,
        fontFamily: json['iconFontFamily'] as String?,
        fontPackage: json['iconFontPackage'] as String?,
      ),
    );
  }

  /// Predefined categories required by the task.
  static List<CategoryModel> predefined() {
    return const [
      CategoryModel(id: 'pre_food', name: 'Food', icon: Icons.restaurant),
      CategoryModel(id: 'pre_travel', name: 'Travel', icon: Icons.flight),
      CategoryModel(id: 'pre_bills', name: 'Bills', icon: Icons.receipt_long),
      CategoryModel(
        id: 'pre_shopping',
        name: 'Shopping',
        icon: Icons.shopping_bag,
      ),
    ];
  }

  /// Small set of icons for custom categories.
  /// Using a limited set prevents missing icons.
  static List<IconData> customIconOptions() {
    return const [
      Icons.local_cafe,
      Icons.directions_bus,
      Icons.health_and_safety,
      Icons.school,
      Icons.home,
      Icons.build,
      Icons.event,
      Icons.sports,
      Icons.fastfood,
      Icons.shopping_cart,
    ];
  }

  /// Friendly color based on icon.
  Color iconColor(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    return theme.primary;
  }
}
