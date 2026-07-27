import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'database_helper.dart';

Future<DatabaseHelper> createHelper() async => _NativeDatabaseHelper();

class _NativeDatabaseHelper extends DatabaseHelper {
  static Database? _db;

  Future<Database> get database async {
    _db ??= await openDatabase(
      p.join(await getDatabasesPath(), 'warehousepro.db'),
      version: 1,
      onCreate: (db, _) async {
        await db.execute('''
          CREATE TABLE stock_transactions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            type TEXT,
            supplier TEXT,
            customer TEXT,
            items INTEGER,
            zone TEXT,
            products TEXT,
            note TEXT,
            syncStatus TEXT DEFAULT 'pending',
            firestoreId TEXT,
            createdAt TEXT
          )
        ''');
      },
    );
    return _db!;
  }

  @override
  Future<int> insertTransaction(Map<String, dynamic> data) async {
    final db = await database;
    final entry = Map<String, dynamic>.from(data);
    if (entry['products'] is List) {
      entry['products'] = jsonEncode(entry['products']);
    }
    return await db.insert('stock_transactions', entry);
  }

  @override
  Future<List<Map<String, dynamic>>> getTransactions({
    String? type,
    int limit = 200,
  }) async {
    final db = await database;
    final results = await db.query(
      'stock_transactions',
      where: type != null ? 'type = ?' : null,
      whereArgs: type != null ? [type] : null,
      orderBy: 'id DESC',
      limit: limit,
    );
    return results.map(_decodeRow).toList();
  }

  @override
  Future<List<Map<String, dynamic>>> getPendingTransactions() async {
    final db = await database;
    final results = await db.query(
      'stock_transactions',
      where: 'syncStatus = ?',
      whereArgs: ['pending'],
    );
    return results.map(_decodeRow).toList();
  }

  @override
  Future<void> markAsSynced(int localId, String firestoreId) async {
    final db = await database;
    await db.update(
      'stock_transactions',
      {'syncStatus': 'synced', 'firestoreId': firestoreId},
      where: 'id = ?',
      whereArgs: [localId],
    );
  }

  @override
  Future<Map<String, dynamic>?> getByFirestoreId(String firestoreId) async {
    final db = await database;
    final results = await db.query(
      'stock_transactions',
      where: 'firestoreId = ?',
      whereArgs: [firestoreId],
      limit: 1,
    );
    return results.isNotEmpty ? _decodeRow(results.first) : null;
  }

  @override
  Future<bool> isDuplicate(String type, int items, String zone, String createdAt) async {
    final db = await database;
    final results = await db.query(
      'stock_transactions',
      where: 'type = ? AND items = ? AND zone = ? AND createdAt = ?',
      whereArgs: [type, items, zone, createdAt],
      limit: 1,
    );
    return results.isNotEmpty;
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
  Future<void> close() async {
    final db = _db;
    if (db != null) {
      await db.close();
      _db = null;
    }
  }
}
