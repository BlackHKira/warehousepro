import 'dart:convert';
import 'database_helper.dart';

Future<DatabaseHelper> createHelper() async => _WebDatabaseHelper();

class _WebDatabaseHelper extends DatabaseHelper {
  final List<Map<String, dynamic>> _store = [];
  int _nextId = 1;

  @override
  Future<int> insertTransaction(Map<String, dynamic> data) async {
    final entry = Map<String, dynamic>.from(data);
    if (entry['products'] is List) {
      entry['products'] = jsonEncode(entry['products']);
    }
    entry['id'] = _nextId++;
    _store.insert(0, entry);
    return entry['id'] as int;
  }

  @override
  Future<List<Map<String, dynamic>>> getTransactions({
    String? type,
    int limit = 200,
  }) async {
    var results = _store.toList();
    if (type != null) {
      results = results.where((e) => e['type'] == type).toList();
    }
    results.sort((a, b) => (b['id'] as int).compareTo(a['id'] as int));
    if (results.length > limit) results = results.sublist(0, limit);
    return results.map(_decodeRow).toList();
  }

  @override
  Future<List<Map<String, dynamic>>> getPendingTransactions() async {
    return _store
        .where((e) => e['syncStatus'] == 'pending')
        .map(_decodeRow)
        .toList();
  }

  @override
  Future<void> markAsSynced(int localId, String firestoreId) async {
    for (final entry in _store) {
      if (entry['id'] == localId) {
        entry['syncStatus'] = 'synced';
        entry['firestoreId'] = firestoreId;
        break;
      }
    }
  }

  @override
  Future<void> updateTransactionStatus(int localId, String newStatus) async {
    for (final entry in _store) {
      if (entry['id'] == localId) {
        entry['status'] = newStatus;
        break;
      }
    }
  }

  @override
  Future<Map<String, dynamic>?> getByFirestoreId(String firestoreId) async {
    for (final entry in _store) {
      if (entry['firestoreId'] == firestoreId) {
        return _decodeRow(entry);
      }
    }
    return null;
  }

  @override
  Future<bool> isDuplicate(String type, int items, String zone, String createdAt) async {
    return false;
  }

  Map<String, dynamic> _decodeRow(Map<String, dynamic> row) {
    final entry = Map<String, dynamic>.from(row);
    if (entry['products'] is String) {
      try {
        entry['products'] = jsonDecode(entry['products'] as String);
      } catch (_) {}
    }
    return entry;
  }

  @override
  Future<void> close() async {}
}
