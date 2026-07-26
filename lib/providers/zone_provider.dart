import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/zone.dart';
import '../services/zone_service.dart';

final zoneServiceProvider = Provider<ZoneService>(
  (ref) => ZoneService()..seedDefaultZones(),
);

final zonesProvider = StreamProvider<List<Zone>>((ref) {
  return ref.watch(zoneServiceProvider).getZonesStream();
});
