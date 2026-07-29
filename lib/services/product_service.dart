import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../models/product.dart';
import '../data/sample_products.dart';

class ProductService {
  final _collection = FirebaseFirestore.instanceFor(
    app: Firebase.app(),
    databaseId: 'warehousepro-db',
  ).collection('products');

  Stream<List<Product>> streamProducts() {
    return _collection.orderBy('name').snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => Product.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  Future<List<Product>> getProducts() async {
    final snapshot = await _collection.orderBy('name').get();
    final list = snapshot.docs
        .map((doc) => Product.fromMap(doc.id, doc.data()))
        .toList();
    if (list.isNotEmpty) return list;
    return sampleProducts;
  }

  Future<Product?> getProduct(String id) async {
    final doc = await _collection.doc(id).get();
    if (!doc.exists) {
      final fallback = sampleProducts.where((p) => p.id == id).firstOrNull;
      if (fallback != null) return fallback;
      return null;
    }
    return Product.fromMap(doc.id, doc.data()!);
  }

  Future<Product?> getProductByBarcode(String barcode) async {
    final snapshot =
        await _collection.where('barcode', isEqualTo: barcode).limit(1).get();
    if (snapshot.docs.isEmpty) {
      return sampleProducts.where((p) => p.barcode == barcode).firstOrNull;
    }
    final doc = snapshot.docs.first;
    return Product.fromMap(doc.id, doc.data());
  }

  Future<List<Product>> searchByName(String query) async {
    if (query.isEmpty) return getProducts();
    final q = query.toLowerCase();
    try {
      final snapshot = await _collection.get();
      final list = snapshot.docs
          .map((doc) => Product.fromMap(doc.id, doc.data()))
          .where((p) =>
              p.name.toLowerCase().contains(q) || p.barcode.contains(query))
          .toList();
      if (list.isNotEmpty) return list;
    } catch (_) {}
    return sampleProducts
        .where((p) =>
            p.name.toLowerCase().contains(q) || p.barcode.contains(query))
        .toList();
  }

  Future<List<Product>> getByZone(String zone) async {
    try {
      final snapshot = await _collection.where('zone', isEqualTo: zone).orderBy('name').get();
      final list = snapshot.docs
          .map((doc) => Product.fromMap(doc.id, doc.data()))
          .toList();
      if (list.isNotEmpty) return list;
    } catch (_) {}
    return sampleProducts.where((p) => p.zone == zone).toList();
  }

  Future<void> addProduct(Product product) async {
    await _collection.add(product.toMap());
  }

  Future<void> updateProduct(String id, Map<String, dynamic> data) async {
    data['updatedAt'] = DateTime.now().toIso8601String();
    await _collection.doc(id).update(data);
  }

  Future<void> updateStock(String id, int newStock) async {
    await _collection.doc(id).update({
      'stock': newStock,
      'serverStock': newStock,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  Future<void> deleteProduct(String id) async {
    await _collection.doc(id).delete();
  }

  Future<List<Product>> getLowStockProducts() async {
    try {
      final snapshot = await _collection.get();
      final list = snapshot.docs
          .map((doc) => Product.fromMap(doc.id, doc.data()))
          .where((p) => p.isLowStock)
          .toList();
      if (list.isNotEmpty) return list;
    } catch (_) {}
    return sampleProducts.where((p) => p.isLowStock).toList();
  }

  Future<void> updateStockByBarcode(String barcode, int delta) async {
    final snapshot = await _collection
        .where('barcode', isEqualTo: barcode)
        .limit(1)
        .get();
    if (snapshot.docs.isEmpty) return;
    final doc = snapshot.docs.first;
    await doc.reference.update({
      'stock': FieldValue.increment(delta),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<String?> checkExportStock(List<Map<String, dynamic>> products) async {
    final errors = <String>[];
    for (final item in products) {
      final barcode = item['barcode'] as String? ?? '';
      final name = item['name'] as String? ?? '';
      final qty = (item['quantity'] as num?)?.toInt() ?? 0;
      if (barcode.isEmpty || qty == 0) continue;
      final product = await getProductByBarcode(barcode);
      if (product == null) {
        errors.add('$name: không tìm thấy trong kho');
      } else if (product.stock < qty) {
        errors.add('${product.name}: chỉ còn ${product.stock} (cần $qty)');
      }
    }
    return errors.isEmpty ? null : errors.join('\n');
  }
}
