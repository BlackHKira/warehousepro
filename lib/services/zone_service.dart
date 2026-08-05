import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../models/zone.dart';

class ZoneService {
  final FirebaseFirestore _db = FirebaseFirestore.instanceFor(
    app: Firebase.app(),
    databaseId: 'warehousepro-db',
  );

  CollectionReference get _zones => _db.collection('zones');

  Stream<List<Zone>> getZonesStream() {
    return _zones.orderBy('sortOrder').snapshots().map((snapshot) {
      return snapshot.docs
          .map(
            (doc) => Zone.fromMap(doc.id, doc.data() as Map<String, dynamic>),
          )
          .toList();
    });
  }

  Future<void> seedDefaultZones() async {
    final snapshot = await _zones.limit(1).get();
    if (snapshot.docs.isNotEmpty) return;
    for (final z in _defaultZoneData) {
      await _zones.add(z);
    }
  }

  static const _defaultZoneData = [
    {'code': 'A1', 'label': 'Khu A1', 'description': 'Nước ngọt có gas', 'sortOrder': 1},
    {'code': 'A2', 'label': 'Khu A2', 'description': 'Nước ngọt có gas', 'sortOrder': 2},
    {'code': 'B1', 'label': 'Khu B1', 'description': 'Nước tăng lực', 'sortOrder': 3},
    {'code': 'B2', 'label': 'Khu B2', 'description': 'Nước tăng lực', 'sortOrder': 4},
    {'code': 'C1', 'label': 'Khu C1', 'description': 'Nước lọc', 'sortOrder': 5},
    {'code': 'C2', 'label': 'Khu C2', 'description': 'Trà', 'sortOrder': 6},
  ];

  static final defaultZones = [
    Zone(id: 'A1', code: 'A1', label: 'Khu A1', description: 'Nước ngọt có gas', sortOrder: 1),
    Zone(id: 'A2', code: 'A2', label: 'Khu A2', description: 'Nước ngọt có gas', sortOrder: 2),
    Zone(id: 'B1', code: 'B1', label: 'Khu B1', description: 'Nước tăng lực', sortOrder: 3),
    Zone(id: 'B2', code: 'B2', label: 'Khu B2', description: 'Nước tăng lực', sortOrder: 4),
    Zone(id: 'C1', code: 'C1', label: 'Khu C1', description: 'Nước lọc', sortOrder: 5),
    Zone(id: 'C2', code: 'C2', label: 'Khu C2', description: 'Trà', sortOrder: 6),
  ];

  Future<DocumentReference> addZone(Zone zone) => _zones.add(zone.toMap());

  Future<void> updateZone(String id, Map<String, dynamic> data) =>
      _zones.doc(id).update(data);

  Future<void> deleteZone(String id) => _zones.doc(id).delete();
}
