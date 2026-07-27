import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';

class ProductService {
  final _collection = FirebaseFirestore.instance.collection('products');

  Stream<List<Product>> streamProducts() {
    return _collection.orderBy('name').snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => Product.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  Future<List<Product>> getProducts() async {
    final snapshot = await _collection.orderBy('name').get();
    return snapshot.docs
        .map((doc) => Product.fromMap(doc.id, doc.data()))
        .toList();
  }

  Future<Product?> getProduct(String id) async {
    final doc = await _collection.doc(id).get();
    if (!doc.exists) return null;
    return Product.fromMap(doc.id, doc.data()!);
  }

  Future<Product?> getProductByBarcode(String barcode) async {
    final snapshot =
        await _collection.where('barcode', isEqualTo: barcode).limit(1).get();
    if (snapshot.docs.isEmpty) return null;
    final doc = snapshot.docs.first;
    return Product.fromMap(doc.id, doc.data());
  }

  Future<List<Product>> searchByName(String query) async {
    if (query.isEmpty) return getProducts();
    final q = query.toLowerCase();
    final snapshot = await _collection.get();
    return snapshot.docs
        .map((doc) => Product.fromMap(doc.id, doc.data()))
        .where((p) =>
            p.name.toLowerCase().contains(q) || p.barcode.contains(query))
        .toList();
  }

  Future<List<Product>> getByZone(String zone) async {
    final snapshot =
        await _collection.where('zone', isEqualTo: zone).orderBy('name').get();
    return snapshot.docs
        .map((doc) => Product.fromMap(doc.id, doc.data()))
        .toList();
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
    final snapshot = await _collection.get();
    return snapshot.docs
        .map((doc) => Product.fromMap(doc.id, doc.data()))
        .where((p) => p.isLowStock)
        .toList();
  }
}
