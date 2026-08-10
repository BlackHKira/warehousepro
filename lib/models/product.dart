import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String name;
  final String barcode;
  final String sku;
  final String category;
  final String zone;
  final String unit;
  final int stock;
  final int serverStock;
  final int minStock;
  final int unitPerCase;
  final int unitPrice;
  final int exportPrice;
  final String note;
  final String imageUrl;
  final Map<String, int> stockByZone;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Product({
    required this.id,
    required this.name,
    required this.barcode,
    this.sku = '',
    this.category = '',
    this.zone = '',
    this.unit = 'cái',
    this.stock = 0,
    this.serverStock = 0,
    this.minStock = 10,
    this.unitPerCase = 1,
    this.unitPrice = 0,
    this.exportPrice = 0,
    this.note = '',
    this.imageUrl = '',
    this.stockByZone = const {},
    this.createdAt,
    this.updatedAt,
  });

  factory Product.fromMap(String id, Map<String, dynamic> map) {
    final warehouseLocation = map['warehouseLocation'] as String? ?? '';
    final zone = warehouseLocation.isNotEmpty
        ? warehouseLocation.split('-').first
        : (map['zone'] as String? ?? '');
    final updatedAtRaw = map['updatedAt'];

    return Product(
      id: id,
      name: map['name'] as String? ?? '',
      barcode: map['barcode'] as String? ?? '',
      sku: map['sku'] as String? ?? map['id'] as String? ?? '',
      category: map['category'] as String? ?? '',
      zone: zone,
      unit: map['unit'] as String? ?? 'cái',
      stock: (map['stock'] as num?)?.toInt() ?? 0,
      serverStock: (map['serverStock'] as num?)?.toInt() ?? 0,
      minStock: (map['minStock'] as num?)?.toInt() ?? 10,
      unitPerCase: (map['unitPerCase'] as num?)?.toInt() ?? 1,
      unitPrice: (map['unitPrice'] as num?)?.toInt() ?? 0,
      exportPrice: (map['exportPrice'] as num?)?.toInt() ?? 0,
      note: map['note'] as String? ?? '',
      imageUrl: map['imageUrl'] as String? ?? '',
      stockByZone: (map['stockByZone'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(k, (v as num?)?.toInt() ?? 0)) ??
          const {},
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] is String
              ? DateTime.tryParse(map['createdAt'])
              : (map['createdAt'] as Timestamp?)?.toDate())
          : null,
      updatedAt: updatedAtRaw != null
          ? (updatedAtRaw is String
              ? DateTime.tryParse(updatedAtRaw)
              : (updatedAtRaw as Timestamp?)?.toDate())
          : null,
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'barcode': barcode,
        'sku': sku,
        'category': category,
        'zone': zone,
        'unit': unit,
        'stock': stock,
        'serverStock': serverStock,
        'minStock': minStock,
        'unitPerCase': unitPerCase,
        'unitPrice': unitPrice,
        'exportPrice': exportPrice,
        'note': note,
        'imageUrl': imageUrl,
        'stockByZone': stockByZone,
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };

  String get location {
    if (zone.isNotEmpty) return '$zone-$id';
    return '';
  }

  bool get isLowStock => stock <= minStock;
  bool get isOutOfStock => stock == 0;

  int getStockInZone(String zone) {
    if (stockByZone.isNotEmpty) return stockByZone[zone] ?? 0;
    if (zone == this.zone) return stock;
    return 0;
  }
}
