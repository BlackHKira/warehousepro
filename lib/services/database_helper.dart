import 'database_helper_native.dart'
    if (dart.library.js) 'database_helper_web.dart';

abstract class DatabaseHelper {
  static DatabaseHelper? _instance;

  static Future<void> init() async {
    _instance ??= await createHelper();
  }

  static DatabaseHelper get instance {
    if (_instance == null) throw Exception('Database not initialized');
    return _instance!;
  }

  Future<int> insertTransaction(Map<String, dynamic> data);
  Future<List<Map<String, dynamic>>> getTransactions({String? type, int limit = 200});
  Future<List<Map<String, dynamic>>> getPendingTransactions();
  Future<void> markAsSynced(int localId, String firestoreId);
  Future<Map<String, dynamic>?> getByFirestoreId(String firestoreId);
  Future<bool> isDuplicate(String type, int items, String zone, String createdAt);
  Future<void> close();
}
