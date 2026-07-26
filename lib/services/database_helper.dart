import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

class DatabaseHelper {
  static Database? _db;

  static Future<void> init() async {
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
  }

  Future<Database> get database async {
    if (_db == null) await init();
    return _db!;
  }

  Future<int> insertTransaction(Map<String, dynamic> data) async {
    final db = await database;
    final entry = Map<String, dynamic>.from(data);
    if (entry['products'] is List) {
      entry['products'] = jsonEncode(entry['products']);
    }
    return await db.insert('stock_transactions', entry);
  }

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

  Future<List<Map<String, dynamic>>> getPendingTransactions() async {
    final db = await database;
    final results = await db.query(
      'stock_transactions',
      where: 'syncStatus = ?',
      whereArgs: ['pending'],
    );
    return results.map(_decodeRow).toList();
  }

  Future<void> markAsSynced(int localId, String firestoreId) async {
    final db = await database;
    await db.update(
      'stock_transactions',
      {'syncStatus': 'synced', 'firestoreId': firestoreId},
      where: 'id = ?',
      whereArgs: [localId],
    );
  }

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

  Map<String, dynamic> _decodeRow(Map<String, dynamic> row) {
    final entry = Map<String, dynamic>.from(row);
    if (entry['products'] is String) {
      try {
        entry['products'] = jsonDecode(entry['products'] as String);
      } catch (_) {}
    }
    return entry;
  }

  Future<void> close() async {
    final db = _db;
    if (db != null) {
      await db.close();
      _db = null;
    }
  }
}
