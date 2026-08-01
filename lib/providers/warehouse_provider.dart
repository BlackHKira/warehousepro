import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/database_helper.dart';
import '../services/firestore_service.dart';
import '../services/product_service.dart';

class WarehouseState {
  final int totalProducts;
  final int todayImports;
  final int todayExports;
  final bool isSyncing;
  final String? lastSyncAt;
  final String? syncError;
  final List<Map<String, dynamic>> recentImports;
  final List<Map<String, dynamic>> recentExports;

  WarehouseState({
    this.totalProducts = 0,
    this.todayImports = 0,
    this.todayExports = 0,
    this.isSyncing = false,
    this.lastSyncAt,
    this.syncError,
    this.recentImports = const [],
    this.recentExports = const [],
  });

  int get pendingSync =>
      recentImports.where((e) => e['syncStatus'] == 'pending').length +
      recentExports.where((e) => e['syncStatus'] == 'pending').length;

  WarehouseState copyWith({
    int? totalProducts,
    int? todayImports,
    int? todayExports,
    bool? isSyncing,
    String? lastSyncAt,
    String? syncError,
    List<Map<String, dynamic>>? recentImports,
    List<Map<String, dynamic>>? recentExports,
  }) {
    return WarehouseState(
      totalProducts: totalProducts ?? this.totalProducts,
      todayImports: todayImports ?? this.todayImports,
      todayExports: todayExports ?? this.todayExports,
      isSyncing: isSyncing ?? this.isSyncing,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      syncError: syncError ?? this.syncError,
      recentImports: recentImports ?? this.recentImports,
      recentExports: recentExports ?? this.recentExports,
    );
  }
}

class WarehouseNotifier extends StateNotifier<WarehouseState> {
  final FirestoreService _firestore = FirestoreService();
  final ProductService _productService = ProductService();
  final DatabaseHelper _db = DatabaseHelper.instance;
  final Connectivity _connectivity = Connectivity();

  WarehouseNotifier() : super(WarehouseState()) {
    _initialize();
  }

  Future<void> _initialize() async {
    if (!kIsWeb) await _loadFromSQLite();
    await _pullFromFirestore();
    if (kIsWeb) await cleanupOldPendingExports();
    if (!kIsWeb) {
      _connectivity.onConnectivityChanged.listen((results) {
        if (!results.contains(ConnectivityResult.none) && state.pendingSync > 0) {
          syncData();
        }
      });
    }
  }

  Future<void> _loadFromSQLite() async {
    try {
      final all = await _db.getTransactions(limit: 200);
      _buildState(all);
    } catch (_) {}
  }

  Future<void> _pullFromFirestore() async {
    try {
      QuerySnapshot snapshot;
      try {
        snapshot = await _firestore.transactions
            .orderBy('createdAt', descending: true)
            .limit(100)
            .get();
      } catch (_) {
        snapshot = await _firestore.transactions.limit(100).get();
      }

      final now = DateTime.now();
      final syncTime = now.toIso8601String();

      final allMaps = <Map<String, dynamic>>[];

      for (final doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final ts = data['createdAt'] as Timestamp?;

        if (!kIsWeb) {
          final existing = await _db.getByFirestoreId(doc.id);
          if (existing != null) continue;
          final createdAt = ts?.toDate().toIso8601String() ?? syncTime;
          final isDup = await _db.isDuplicate(
            data['type'] as String? ?? '',
            (data['items'] as num?)?.toInt() ?? 0,
            data['zone'] as String? ?? '',
            createdAt,
          );
          if (isDup) continue;
          await _db.insertTransaction({
            'firestoreId': doc.id,
            'type': data['type'],
            'supplier': data['supplier'],
            'customer': data['customer'],
            'items': data['items'],
            'zone': data['zone'],
            'products': data['products'],
            'note': data['note'],
            'status': data['status'],
            'syncStatus': 'synced',
            'createdAt': createdAt,
          });
        } else {
          allMaps.add({
            'id': doc.id,
            'firestoreId': doc.id,
            'type': data['type'],
            'supplier': data['supplier'],
            'customer': data['customer'],
            'items': data['items'],
            'zone': data['zone'] ?? 'D',
            'products': data['products'] ?? [],
            'note': data['note'] ?? '',
            'status': data['status'],
            'syncStatus': 'synced',
            'createdAt': ts?.toDate().toIso8601String() ?? syncTime,
          });
        }
      }

      if (kIsWeb) {
        _buildState(allMaps);
      } else {
        final all = await _db.getTransactions(limit: 200);
        _buildState(all);
      }
    } catch (e) {
      state = state.copyWith(syncError: 'Lỗi tải dữ liệu từ Firestore: $e');
    }
  }

  void _buildState(List<Map<String, dynamic>> all) {
    final imports = <Map<String, dynamic>>[];
    final exports = <Map<String, dynamic>>[];
    int totalImportQty = 0;
    int totalExportQty = 0;
    int todayImportQty = 0;
    int todayExportQty = 0;

    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);

    for (final entry in all) {
      final items = (entry['items'] as num?)?.toInt() ?? 0;
      if (entry['type'] == 'import') {
        imports.add(entry);
        totalImportQty += items;
        final createdAt = DateTime.tryParse(entry['createdAt'] ?? '');
        if (createdAt != null && !createdAt.isBefore(todayStart)) {
          todayImportQty += items;
        }
      } else {
        exports.add(entry);
        totalExportQty += items;
        final createdAt = DateTime.tryParse(entry['createdAt'] ?? '');
        if (createdAt != null && !createdAt.isBefore(todayStart)) {
          todayExportQty += items;
        }
      }
    }

    state = state.copyWith(
      totalProducts: totalImportQty - totalExportQty,
      todayImports: todayImportQty,
      todayExports: todayExportQty,
      recentImports: imports,
      recentExports: exports,
      lastSyncAt: now.toIso8601String(),
      syncError: null,
    );
  }

  Future<bool> addImport(
    int itemCount,
    String supplier, {
    String zone = 'D',
    List<Map<String, dynamic>> products = const [],
    String note = '',
  }) async {
    return await _addTransaction(
      'import',
      itemCount,
      supplier: supplier,
      zone: zone,
      products: products,
      note: note,
    );
  }

  Future<bool> addExport(
    int itemCount,
    String customer, {
    String zone = 'D',
    List<Map<String, dynamic>> products = const [],
    String note = '',
    String status = 'pending',
  }) async {
    return await _addTransaction(
      'export',
      itemCount,
      customer: customer,
      zone: zone,
      products: products,
      note: note,
      status: status,
    );
  }

  Future<bool> updateExportStatus(Map<String, dynamic> order, String newStatus) async {
    try {
      final rawId = order['id'];
      final localId = rawId is int ? rawId : null;
      final rawFirestoreId = order['firestoreId'];
      var firestoreId = rawFirestoreId is String ? rawFirestoreId : null;

      final needPushToFirestore = newStatus == 'completed' &&
          (firestoreId == null || firestoreId.isEmpty || firestoreId == 'pending');

      if (needPushToFirestore) {
        final docRef = await _firestore.transactions.add({
          'type': order['type'],
          'supplier': order['supplier'],
          'customer': order['customer'],
          'items': order['items'],
          'zone': order['zone'],
          'products': order['products'],
          'note': order['note'],
          'status': 'completed',
          'createdAt': FieldValue.serverTimestamp(),
        });
        firestoreId = docRef.id;

        final products = (order['products'] as List<dynamic>?) ?? [];
        for (final item in products) {
          final map = item as Map<String, dynamic>;
          final barcode = map['barcode'] as String? ?? '';
          final qty = (map['quantity'] as num?)?.toInt() ?? 0;
          final itemZone = map['zone'] as String?;
          if (barcode.isEmpty || qty == 0) continue;
          await _productService.updateStockByBarcode(barcode, -qty, zone: itemZone);
        }

        if (localId != null) {
          await _db.updateTransactionStatus(localId, 'completed');
        }
      } else if (firestoreId != null && firestoreId.isNotEmpty && firestoreId != 'pending') {
        await _firestore.transactions.doc(firestoreId).update({'status': newStatus});
        if (localId != null) {
          await _db.updateTransactionStatus(localId, newStatus);
        }
      }

      if (kIsWeb) {
        await _pullFromFirestore();
      } else {
        final all = await _db.getTransactions(limit: 200);
        _buildState(all);
      }
      return true;
    } catch (e) {
      state = state.copyWith(syncError: 'Lỗi cập nhật trạng thái: $e');
      return false;
    }
  }

  Future<bool> _addTransaction(
    String type,
    int itemCount, {
    String? supplier,
    String? customer,
    String zone = 'D',
    List<Map<String, dynamic>> products = const [],
    String note = '',
    String? status,
  }) async {
    try {
      final now = DateTime.now();

      final effectiveStatus = status ?? (type == 'export' ? 'pending' : null);

      if (kIsWeb) {
        if (type == 'export') {
          final stockError = await _productService.checkExportStock(products);
          if (stockError != null) {
            state = state.copyWith(syncError: stockError);
            return false;
          }
        }

        final isPendingExport = type == 'export' && effectiveStatus == 'pending';

        if (!isPendingExport) {
          await _firestore.transactions.add({
            'type': type,
            'supplier': type == 'import' ? supplier : null,
            'customer': type == 'export' ? customer : null,
            'items': itemCount,
            'zone': zone,
            'products': products,
            'note': note,
            'status': effectiveStatus,
            'createdAt': FieldValue.serverTimestamp(),
          });

          for (final item in products) {
            final barcode = item['barcode'] as String? ?? '';
            final qty = (item['quantity'] as num?)?.toInt() ?? 0;
            if (barcode.isEmpty || qty == 0) continue;
            final delta = type == 'import' ? qty : -qty;
            await _productService.updateStockByBarcode(barcode, delta);
          }
        }

        final optimisticEntry = <String, dynamic>{
          'id': 'pending-${DateTime.now().millisecondsSinceEpoch}',
          'firestoreId': isPendingExport ? 'pending' : 'pending',
          'type': type,
          'supplier': type == 'import' ? supplier : null,
          'customer': type == 'export' ? customer : null,
          'items': itemCount,
          'zone': zone,
          'products': products,
          'note': note,
          'status': effectiveStatus,
          'syncStatus': isPendingExport ? 'local_only' : 'synced',
          'createdAt': now.toIso8601String(),
        };
        if (type == 'import') {
          state = state.copyWith(
            recentImports: [optimisticEntry, ...state.recentImports],
            todayImports: state.todayImports + itemCount,
          );
        } else {
          state = state.copyWith(
            recentExports: [optimisticEntry, ...state.recentExports],
            todayExports: state.todayExports + itemCount,
          );
        }
      } else {
        final entry = {
          'type': type,
          'supplier': type == 'import' ? supplier : null,
          'customer': type == 'export' ? customer : null,
          'items': itemCount,
          'zone': zone,
          'products': products,
          'note': note,
          'status': effectiveStatus,
          'syncStatus': effectiveStatus == 'pending' ? 'local_only' : 'pending',
          'createdAt': now.toIso8601String(),
        };
        await _db.insertTransaction(entry);
        final all = await _db.getTransactions(limit: 200);
        _buildState(all);
        if (effectiveStatus != 'pending') {
          await syncData();
        }
      }
      return true;
    } catch (e) {
      state = state.copyWith(syncError: 'Lỗi lưu giao dịch: $e');
      return false;
    }
  }

  Future<void> syncData() async {
    if (kIsWeb) return;
    if (state.isSyncing) return;
    state = state.copyWith(isSyncing: true, syncError: null);

    final connectivityResult = await _connectivity.checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none)) {
      state = state.copyWith(isSyncing: false, syncError: 'Không có kết nối mạng');
      return;
    }

    try {
      final allPending = await _db.getPendingTransactions();
      final pending = allPending.where((e) => e['syncStatus'] != 'local_only').toList();
      for (final entry in pending) {
        final docRef = await _firestore.transactions.add({
          'type': entry['type'],
          'supplier': entry['supplier'],
          'customer': entry['customer'],
          'items': entry['items'],
          'zone': entry['zone'] ?? 'D',
          'products': entry['products'] ?? [],
          'note': entry['note'] ?? '',
          'status': entry['status'],
          'createdAt': FieldValue.serverTimestamp(),
        });
        final localId = entry['localId'] ?? entry['id'];
        if (localId is int) {
          await _db.markAsSynced(localId, docRef.id);
        }
      }

      await _pullFromFirestore();
      state = state.copyWith(isSyncing: false);
    } catch (e) {
      state = state.copyWith(isSyncing: false, syncError: 'Lỗi đồng bộ: $e');
    }
  }

  void clearSyncError() {
    state = state.copyWith(syncError: null);
  }

  Future<void> refreshFromFirestore() async {
    await _pullFromFirestore();
  }

  Future<void> cleanupOldPendingExports() async {
    try {
      final snapshot = await _firestore.transactions
          .where('type', isEqualTo: 'export')
          .where('status', isEqualTo: 'pending')
          .get();
      for (final doc in snapshot.docs) {
        await doc.reference.update({'status': 'completed'});
      }
      await _pullFromFirestore();
    } catch (_) {}
  }
}

final warehouseProvider =
    StateNotifierProvider<WarehouseNotifier, WarehouseState>((ref) {
      return WarehouseNotifier();
    });
