import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../models/product.dart';
import '../data/sample_products.dart';

class ProductService {
  final _db = FirebaseFirestore.instanceFor(
    app: Firebase.app(),
    databaseId: 'warehousepro-db',
  );
  late final _collection = _db.collection('products');

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
    for (final p in sampleProducts) {
      await _collection.add(p.toMap());
    }
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

  Future<String?> updateStockByBarcode(String barcode, int delta, {String? zone}) async {
    if (delta < 0) {
      return await _db.runTransaction<String?>((tx) async {
        final snapshot = await _collection
            .where('barcode', isEqualTo: barcode)
            .limit(1)
            .get();
        if (snapshot.docs.isEmpty) return null;
        final doc = snapshot.docs.first;
        final currentStock = (doc.data()['stock'] as num?)?.toInt() ?? 0;
        if (currentStock + delta < 0) {
          return '${doc.data()['name']}: chỉ còn $currentStock (cần ${-delta})';
        }
        final updateData = <String, dynamic>{
          'stock': FieldValue.increment(delta),
          'updatedAt': FieldValue.serverTimestamp(),
        };
        if (zone != null && zone.isNotEmpty) {
          updateData['zone'] = zone;
          updateData['warehouseLocation'] = '$zone-${doc.data()['id'] ?? ''}';
        }
        tx.update(doc.reference, updateData);
        return null;
      });
    }
    final snapshot = await _collection
        .where('barcode', isEqualTo: barcode)
        .limit(1)
        .get();
    if (snapshot.docs.isEmpty) return null;
    final updateData = <String, dynamic>{
      'stock': FieldValue.increment(delta),
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (zone != null && zone.isNotEmpty) {
      updateData['zone'] = zone;
      updateData['warehouseLocation'] = '$zone-${snapshot.docs.first.data()['id'] ?? ''}';
    }
    await snapshot.docs.first.reference.update(updateData);
    return null;
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
        errors.add('${product.name}: chỉ còn ${product.stock} ${product.unit.toLowerCase()} (cần $qty)');
      }
    }
    return errors.isEmpty ? null : errors.join('\n');
  }
}
