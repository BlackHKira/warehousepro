import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/database_helper.dart';
import '../services/firestore_service.dart';

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
  final DatabaseHelper _db = DatabaseHelper();
  final Connectivity _connectivity = Connectivity();

  WarehouseNotifier() : super(WarehouseState()) {
    _initialize();
  }

  Future<void> _initialize() async {
    await _loadFromSQLite();
    await _pullFromFirestore();
    _connectivity.onConnectivityChanged.listen((results) {
      if (!results.contains(ConnectivityResult.none) && state.pendingSync > 0) {
        syncData();
      }
    });
  }

  Future<void> _loadFromSQLite() async {
    try {
      final all = await _db.getTransactions(limit: 200);
      _buildState(all);
    } catch (_) {}
  }

  Future<void> _pullFromFirestore() async {
    try {
      final snapshot = await _firestore.transactions
          .orderBy('createdAt', descending: true)
          .limit(100)
          .get();

      final now = DateTime.now();
      final syncTime = now.toIso8601String();

      for (final doc in snapshot.docs) {
        final existing = await _db.getByFirestoreId(doc.id);
        if (existing != null) continue;

        final data = doc.data() as Map<String, dynamic>;
        final ts = data['createdAt'] as Timestamp?;
        await _db.insertTransaction({
          'firestoreId': doc.id,
          'type': data['type'],
          'supplier': data['supplier'],
          'customer': data['customer'],
          'items': data['items'],
          'zone': data['zone'],
          'products': data['products'],
          'note': data['note'],
          'syncStatus': 'synced',
          'createdAt': ts?.toDate().toIso8601String() ?? syncTime,
        });
      }

      final all = await _db.getTransactions(limit: 200);
      _buildState(all);
    } catch (_) {}
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

  Future<void> addImport(
    int itemCount,
    String supplier, {
    String zone = 'D',
    List<Map<String, dynamic>> products = const [],
    String note = '',
  }) async {
    await _addTransaction(
      'import',
      itemCount,
      supplier: supplier,
      zone: zone,
      products: products,
      note: note,
    );
  }

  Future<void> addExport(
    int itemCount,
    String customer, {
    String zone = 'D',
    List<Map<String, dynamic>> products = const [],
    String note = '',
  }) async {
    await _addTransaction(
      'export',
      itemCount,
      customer: customer,
      zone: zone,
      products: products,
      note: note,
    );
  }

  Future<void> _addTransaction(
    String type,
    int itemCount, {
    String? supplier,
    String? customer,
    String zone = 'D',
    List<Map<String, dynamic>> products = const [],
    String note = '',
  }) async {
    try {
      final now = DateTime.now();
      final entry = {
        'type': type,
        'supplier': type == 'import' ? supplier : null,
        'customer': type == 'export' ? customer : null,
        'items': itemCount,
        'zone': zone,
        'products': products,
        'note': note,
        'syncStatus': 'pending',
        'createdAt': now.toIso8601String(),
      };

      await _db.insertTransaction(entry);

      final all = await _db.getTransactions(limit: 200);
      _buildState(all);

      syncData();
    } catch (e) {
      state = state.copyWith(syncError: 'Lỗi lưu giao dịch: $e');
    }
  }

  Future<void> syncData() async {
    if (state.isSyncing || state.pendingSync == 0) return;
    state = state.copyWith(isSyncing: true, syncError: null);

    final connectivityResult = await _connectivity.checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none)) {
      state = state.copyWith(
        isSyncing: false,
        syncError: 'Không có kết nối mạng',
      );
      return;
    }

    try {
      final pending = await _db.getPendingTransactions();
      for (final entry in pending) {
        final docRef = await _firestore.transactions.add({
          'type': entry['type'],
          'supplier': entry['supplier'],
          'customer': entry['customer'],
          'items': entry['items'],
          'zone': entry['zone'] ?? 'D',
          'products': entry['products'] ?? [],
          'note': entry['note'] ?? '',
          'createdAt': FieldValue.serverTimestamp(),
        });
        final localId = entry['localId'] ?? entry['id'];
        if (localId is int) {
          await _db.markAsSynced(localId, docRef.id);
        }
      }

      final all = await _db.getTransactions(limit: 200);
      _buildState(all);
      state = state.copyWith(isSyncing: false, syncError: null);
    } catch (e) {
      state = state.copyWith(isSyncing: false, syncError: 'Lỗi đồng bộ: $e');
    }
  }

  void clearSyncError() {
    state = state.copyWith(syncError: null);
  }
}

final warehouseProvider =
    StateNotifierProvider<WarehouseNotifier, WarehouseState>((ref) {
      return WarehouseNotifier();
    });
