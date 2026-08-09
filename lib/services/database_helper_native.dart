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
      version: 2,
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
            status TEXT DEFAULT 'pending',
            syncStatus TEXT DEFAULT 'pending',
            firestoreId TEXT,
            createdAt TEXT
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE stock_transactions ADD COLUMN status TEXT DEFAULT \'pending\'');
        }
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
  Future<void> updateTransactionStatus(int localId, String newStatus) async {
    final db = await database;
    await db.update(
      'stock_transactions',
      {'status': newStatus},
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
}
