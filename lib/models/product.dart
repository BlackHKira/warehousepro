import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String name;
  final String barcode;
  final String sku;
  final String category;
  final String zone;
  final String location;
  final String unit;
  final int stock;
  final int serverStock;
  final double unitPrice;
  final double exportPrice;
  final int minStock;
  final int unitPerCase;
  final String note;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Product({
    required this.id,
    required this.name,
    required this.barcode,
    this.sku = '',
    this.category = '',
    this.zone = '',
    this.location = '',
    this.unit = 'cái',
    this.stock = 0,
    this.serverStock = 0,
    this.unitPrice = 0,
    this.exportPrice = 0,
    this.minStock = 10,
    this.unitPerCase = 1,
    this.note = '',
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
      location: warehouseLocation.isNotEmpty
          ? warehouseLocation
          : (map['location'] as String? ?? ''),
      unit: map['unit'] as String? ?? 'cái',
      stock: (map['stock'] as num?)?.toInt() ?? 0,
      serverStock: (map['serverStock'] as num?)?.toInt() ?? 0,
      unitPrice: (map['unitPrice'] as num?)?.toDouble() ?? 0,
      exportPrice: (map['exportPrice'] as num?)?.toDouble() ?? 0,
      minStock: (map['minStock'] as num?)?.toInt() ?? 10,
      unitPerCase: (map['unitPerCase'] as num?)?.toInt() ?? 1,
      note: map['note'] as String? ?? '',
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
        'location': location,
        'unit': unit,
        'stock': stock,
        'serverStock': serverStock,
        'unitPrice': unitPrice,
        'exportPrice': exportPrice,
        'minStock': minStock,
        'unitPerCase': unitPerCase,
        'note': note,
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };

  bool get isLowStock => stock <= minStock;
  bool get isOutOfStock => stock == 0;

  int get stockInCases => unitPerCase > 0 ? stock ~/ unitPerCase : 0;
  int get stockRemainder => unitPerCase > 0 ? stock % unitPerCase : stock;
  double get unitPricePerCase => unitPrice * unitPerCase;
  double get exportPricePerCase => exportPrice * unitPerCase;
}
