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
    return await _db.runTransaction<String?>((tx) async {
      final snapshot = await _collection
          .where('barcode', isEqualTo: barcode)
          .limit(1)
          .get();
      if (snapshot.docs.isEmpty) return null;
      final doc = snapshot.docs.first;
      final data = doc.data();
      final currentStock = (data['stock'] as num?)?.toInt() ?? 0;
      final docZone = data['zone'] as String? ?? '';
      final effectiveZone = (zone != null && zone.isNotEmpty) ? zone : docZone;

      final rawStockByZone = data['stockByZone'];
      final stockByZone = <String, int>{};
      if (rawStockByZone is Map && rawStockByZone.isNotEmpty) {
        rawStockByZone.forEach((k, v) {
          stockByZone[k.toString()] = (v as num?)?.toInt() ?? 0;
        });
      } else if (docZone.isNotEmpty) {
        stockByZone[docZone] = currentStock;
      }

      if (effectiveZone.isEmpty) {
        return '${data['name']}: không xác định khu vực';
      }

      final zoneStock = stockByZone[effectiveZone] ?? 0;
      if (zoneStock + delta < 0) {
        return '${data['name']}: chỉ còn $zoneStock ${data['unit']} ở $effectiveZone (cần ${-delta})';
      }

      stockByZone[effectiveZone] = zoneStock + delta;
      final newTotal = stockByZone.values.fold(0, (acc, v) => acc + v);
      tx.update(doc.reference, {
        'stock': newTotal,
        'stockByZone': stockByZone,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return null;
    });
  }

  Future<int> recalculateStockFromStockByZone() async {
    final snapshot = await _collection.get();
    int fixed = 0;
    for (final doc in snapshot.docs) {
      final data = doc.data();
      final rawStockByZone = data['stockByZone'];
      if (rawStockByZone is Map && rawStockByZone.isNotEmpty) {
        final correctTotal = rawStockByZone.values.fold<int>(0, (acc, v) => acc + ((v as num?)?.toInt() ?? 0));
        final currentStock = (data['stock'] as num?)?.toInt() ?? 0;
        if (currentStock != correctTotal) {
          await doc.reference.update({
            'stock': correctTotal,
            'updatedAt': FieldValue.serverTimestamp(),
          });
          fixed++;
        }
      }
    }
    return fixed;
  }

  Future<String?> checkExportStock(List<Map<String, dynamic>> products, {String? zone}) async {
    final errors = <String>[];
    for (final item in products) {
      final barcode = item['barcode'] as String? ?? '';
      final name = item['name'] as String? ?? '';
      final qty = (item['quantity'] as num?)?.toInt() ?? 0;
      if (barcode.isEmpty || qty == 0) continue;
      final product = await getProductByBarcode(barcode);
      if (product == null) {
        errors.add('$name: không tìm thấy trong kho');
        continue;
      }
      final itemZone = item['zone'] as String? ?? zone;
      if (itemZone != null && itemZone.isNotEmpty) {
        final zoneStock = product.getStockInZone(itemZone);
        if (zoneStock < qty) {
          errors.add('${product.name}: chỉ còn $zoneStock ${product.unit.toLowerCase()} ở $itemZone (cần $qty)');
        }
      } else {
        if (product.stock < qty) {
          errors.add('${product.name}: chỉ còn ${product.stock} ${product.unit.toLowerCase()} (cần $qty)');
        }
      }
    }
    return errors.isEmpty ? null : errors.join('\n');
  }
}
