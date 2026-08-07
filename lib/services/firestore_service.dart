import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instanceFor(
    app: Firebase.app(),
    databaseId: 'warehousepro-db',
  );

  CollectionReference get transactions => _db.collection('stock_transactions');
}
