import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Products
  CollectionReference get products => _db.collection('products');

  Future<void> addProduct(Map<String, dynamic> data) => products.add(data);
  Future<void> updateProduct(String id, Map<String, dynamic> data) =>
      products.doc(id).update(data);
  Future<void> deleteProduct(String id) => products.doc(id).delete();
  Stream<QuerySnapshot> getProductsStream() => products.snapshots();
  Future<DocumentSnapshot> getProduct(String id) => products.doc(id).get();

  // Stock Transactions
  CollectionReference get transactions => _db.collection('stock_transactions');

  Future<void> addTransaction(Map<String, dynamic> data) =>
      transactions.add(data);
  Stream<QuerySnapshot> getTransactionsStream({String? productId}) {
    var query = transactions.orderBy('createdAt', descending: true);
    if (productId != null) {
      query = query.where('productId', isEqualTo: productId);
    }
    return query.snapshots();
  }

  // Picking Orders
  CollectionReference get pickingOrders => _db.collection('picking_orders');

  Future<void> addPickingOrder(Map<String, dynamic> data) =>
      pickingOrders.add(data);
  Future<void> updatePickingOrder(String id, Map<String, dynamic> data) =>
      pickingOrders.doc(id).update(data);
  Stream<QuerySnapshot> getPickingOrdersStream({String? status}) {
    var query = pickingOrders.orderBy('requestedDate', descending: true);
    if (status != null) query = query.where('status', isEqualTo: status);
    return query.snapshots();
  }

  // Inventory Snapshots (đồng bộ)
  CollectionReference get inventorySnapshots =>
      _db.collection('inventory_snapshots');

  Future<void> addSnapshot(Map<String, dynamic> data) =>
      inventorySnapshots.add(data);
}
