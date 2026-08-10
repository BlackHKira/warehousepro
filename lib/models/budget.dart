import 'package:cloud_firestore/cloud_firestore.dart';

class BudgetCategory {
  final String name;
  final int importLimit;

  const BudgetCategory({required this.name, required this.importLimit});

  Map<String, dynamic> toMap() => {
        'name': name,
        'importLimit': importLimit,
      };

  factory BudgetCategory.fromMap(Map<String, dynamic> map) {
    return BudgetCategory(
      name: map['name'] as String? ?? '',
      importLimit: (map['importLimit'] as num?)?.toInt() ?? 0,
    );
  }
}

class Budget {
  final String id;
  final String month;
  final int importBudget;
  final int exportRevenueTarget;
  final List<BudgetCategory> categories;
  final DateTime? createdAt;

  const Budget({
    required this.id,
    required this.month,
    this.importBudget = 0,
    this.exportRevenueTarget = 0,
    this.categories = const [],
    this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'month': month,
        'importBudget': importBudget,
        'exportRevenueTarget': exportRevenueTarget,
        'categories': categories.map((c) => c.toMap()).toList(),
        'createdAt': createdAt?.toIso8601String(),
      };

  factory Budget.fromMap(String id, Map<String, dynamic> map) {
    final rawCategories = map['categories'] as List<dynamic>? ?? [];
    return Budget(
      id: id,
      month: map['month'] as String? ?? '',
      importBudget: (map['importBudget'] as num?)?.toInt() ?? 0,
      exportRevenueTarget: (map['exportRevenueTarget'] as num?)?.toInt() ?? 0,
      categories: rawCategories
          .map((c) => BudgetCategory.fromMap(c as Map<String, dynamic>))
          .toList(),
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] is String
              ? DateTime.tryParse(map['createdAt'])
              : (map['createdAt'] as Timestamp?)?.toDate())
          : null,
    );
  }

  static String currentMonth() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}';
  }
}
