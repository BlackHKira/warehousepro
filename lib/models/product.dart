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
    this.note = '',
    this.createdAt,
    this.updatedAt,
  });

  factory Product.fromMap(String id, Map<String, dynamic> map) => Product(
        id: id,
        name: map['name'] as String? ?? '',
        barcode: map['barcode'] as String? ?? '',
        sku: map['sku'] as String? ?? '',
        category: map['category'] as String? ?? '',
        zone: map['zone'] as String? ?? '',
        location: map['location'] as String? ?? '',
        unit: map['unit'] as String? ?? 'cái',
        stock: (map['stock'] as num?)?.toInt() ?? 0,
        serverStock: (map['serverStock'] as num?)?.toInt() ?? 0,
        unitPrice: (map['unitPrice'] as num?)?.toDouble() ?? 0,
        exportPrice: (map['exportPrice'] as num?)?.toDouble() ?? 0,
        minStock: (map['minStock'] as num?)?.toInt() ?? 10,
        note: map['note'] as String? ?? '',
        createdAt: map['createdAt'] != null
            ? DateTime.tryParse(map['createdAt'] as String)
            : null,
        updatedAt: map['updatedAt'] != null
            ? DateTime.tryParse(map['updatedAt'] as String)
            : null,
      );

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
        'note': note,
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };

  bool get isLowStock => stock <= minStock;
  bool get isOutOfStock => stock == 0;
}
