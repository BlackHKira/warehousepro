import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final _db = FirebaseFirestore.instanceFor(
  app: Firebase.app(),
  databaseId: 'warehousepro-db',
);

// --- Wallet: Số dư ví tiền kho ---

final walletProvider = StreamProvider<Map<String, dynamic>?>((ref) {
  return _db.collection('wallets').doc('current').snapshots().map((doc) {
    if (!doc.exists) return null;
    return doc.data();
  });
});

// --- Actuals: Tính tổng tiền nhập/xuất tháng hiện tại ---

final actualCostProvider = FutureProvider<Map<String, int>>((ref) async {
  final now = DateTime.now();
  final start = DateTime(now.year, now.month, 1);
  final end = DateTime(now.year, now.month + 1, 1);

  final startStr = start.toIso8601String();
  final endStr = end.toIso8601String();
  final startTs = Timestamp.fromDate(start);
  final endTs = Timestamp.fromDate(end);

  // Batch query products 1 lần để build barcode→price map
  final productsSnap = await _db.collection('products').get();
  final priceMap = <String, Map<String, int>>{};
  for (final doc in productsSnap.docs) {
    final data = doc.data();
    final barcode = data['barcode'] as String? ?? '';
    if (barcode.isNotEmpty) {
      priceMap[barcode] = {
        'unitPrice': (data['unitPrice'] as num?)?.toInt() ?? 0,
        'exportPrice': (data['exportPrice'] as num?)?.toInt() ?? 0,
        'category': 0,
      };
    }
  }

  // Query 1: Timestamp createdAt
  final tsSnap = await _db
      .collection('stock_transactions')
      .where('createdAt', isGreaterThanOrEqualTo: startTs)
      .where('createdAt', isLessThan: endTs)
      .get();

  // Query 2: String createdAt (ISO8601)
  final strSnap = await _db
      .collection('stock_transactions')
      .where('createdAt', isGreaterThanOrEqualTo: startStr)
      .where('createdAt', isLessThan: endStr)
      .get();

  // Merge & dedupe by doc id
  final allDocs = <String, Map<String, dynamic>>{};
  for (final doc in [...tsSnap.docs, ...strSnap.docs]) {
    allDocs.putIfAbsent(doc.id, () => doc.data());
  }

  int totalImportCost = 0;
  int totalExportRevenue = 0;

  for (final data in allDocs.values) {
    final type = data['type'] as String?;
    final products = data['products'] as List<dynamic>? ?? [];

    for (final item in products) {
      if (item is Map<String, dynamic>) {
        final barcode = item['barcode'] as String? ?? '';
        final quantity = (item['quantity'] as num?)?.toInt() ?? 0;
        final prices = priceMap[barcode];
        if (prices == null) continue;

        if (type == 'import') {
          totalImportCost += quantity * prices['unitPrice']!;
        } else if (type == 'export') {
          totalExportRevenue += quantity * prices['exportPrice']!;
        }
      }
    }
  }

  return {
    'importCost': totalImportCost,
    'exportRevenue': totalExportRevenue,
  };
});

// --- Category Costs: Phân bổ chi theo danh mục ---

final categoryCostProvider = FutureProvider<Map<String, int>>((ref) async {
  final now = DateTime.now();
  final start = DateTime(now.year, now.month, 1);
  final end = DateTime(now.year, now.month + 1, 1);

  final startStr = start.toIso8601String();
  final endStr = end.toIso8601String();
  final startTs = Timestamp.fromDate(start);
  final endTs = Timestamp.fromDate(end);

  // Batch query products
  final productsSnap = await _db.collection('products').get();
  final productMap = <String, Map<String, dynamic>>{};
  for (final doc in productsSnap.docs) {
    final data = doc.data();
    final barcode = data['barcode'] as String? ?? '';
    if (barcode.isNotEmpty) {
      productMap[barcode] = data;
    }
  }

  // Query both Timestamp and String
  final tsSnap = await _db
      .collection('stock_transactions')
      .where('createdAt', isGreaterThanOrEqualTo: startTs)
      .where('createdAt', isLessThan: endTs)
      .get();
  final strSnap = await _db
      .collection('stock_transactions')
      .where('createdAt', isGreaterThanOrEqualTo: startStr)
      .where('createdAt', isLessThan: endStr)
      .get();

  final allDocs = <String, Map<String, dynamic>>{};
  for (final doc in [...tsSnap.docs, ...strSnap.docs]) {
    allDocs.putIfAbsent(doc.id, () => doc.data());
  }

  final categoryMap = <String, int>{};

  for (final data in allDocs.values) {
    final type = data['type'] as String?;
    if (type != 'import') continue;
    final products = data['products'] as List<dynamic>? ?? [];

    for (final item in products) {
      if (item is Map<String, dynamic>) {
        final barcode = item['barcode'] as String? ?? '';
        final quantity = (item['quantity'] as num?)?.toInt() ?? 0;
        final productData = productMap[barcode];
        if (productData == null) continue;
        final category = productData['category'] as String? ?? 'Khác';
        final unitPrice = (productData['unitPrice'] as num?)?.toInt() ?? 0;
        categoryMap[category] = (categoryMap[category] ?? 0) + quantity * unitPrice;
      }
    }
  }

  return categoryMap;
});

// --- Transactions list for wallet history ---

final walletTransactionsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final now = DateTime.now();
  final start = DateTime(now.year, now.month, 1);
  final end = DateTime(now.year, now.month + 1, 1);

  final startStr = start.toIso8601String();
  final endStr = end.toIso8601String();
  final startTs = Timestamp.fromDate(start);
  final endTs = Timestamp.fromDate(end);

  final tsSnap = await _db
      .collection('stock_transactions')
      .where('createdAt', isGreaterThanOrEqualTo: startTs)
      .where('createdAt', isLessThan: endTs)
      .orderBy('createdAt', descending: true)
      .get();
  final strSnap = await _db
      .collection('stock_transactions')
      .where('createdAt', isGreaterThanOrEqualTo: startStr)
      .where('createdAt', isLessThan: endStr)
      .orderBy('createdAt', descending: true)
      .get();

  final allDocs = <String, Map<String, dynamic>>{};
  for (final doc in [...tsSnap.docs, ...strSnap.docs]) {
    allDocs.putIfAbsent(doc.id, () => doc.data());
  }

  // Build price map
  final productsSnap = await _db.collection('products').get();
  final priceMap = <String, Map<String, int>>{};
  for (final doc in productsSnap.docs) {
    final data = doc.data();
    final barcode = data['barcode'] as String? ?? '';
    if (barcode.isNotEmpty) {
      priceMap[barcode] = {
        'unitPrice': (data['unitPrice'] as num?)?.toInt() ?? 0,
        'exportPrice': (data['exportPrice'] as num?)?.toInt() ?? 0,
      };
    }
  }

  final result = <Map<String, dynamic>>[];
  for (final data in allDocs.values) {
    final type = data['type'] as String?;
    final products = data['products'] as List<dynamic>? ?? [];
    final partner = type == 'import'
        ? (data['supplier'] as String? ?? '')
        : (data['customer'] as String? ?? '');
    final createdAtRaw = data['createdAt'];
    String createdAtStr;
    if (createdAtRaw is Timestamp) {
      createdAtStr = createdAtRaw.toDate().toString().substring(0, 16);
    } else {
      createdAtStr = createdAtRaw?.toString() ?? '';
    }

    int txnTotal = 0;
    for (final item in products) {
      if (item is Map<String, dynamic>) {
        final barcode = item['barcode'] as String? ?? '';
        final quantity = (item['quantity'] as num?)?.toInt() ?? 0;
        final prices = priceMap[barcode];
        if (prices == null) continue;
        if (type == 'import') {
          txnTotal += quantity * prices['unitPrice']!;
        } else if (type == 'export') {
          txnTotal += quantity * prices['exportPrice']!;
        }
      }
    }

    result.add({
      'type': type,
      'partner': partner,
      'total': txnTotal,
      'createdAt': createdAtStr,
    });
  }

  return result;
});

// --- Save wallet ---

Future<void> saveWallet({
  required int initialDeposit,
  required String note,
}) async {
  await _db.collection('wallets').doc('current').set({
    'initialDeposit': initialDeposit,
    'note': note,
    'updatedAt': FieldValue.serverTimestamp(),
  }, SetOptions(merge: true));
}
