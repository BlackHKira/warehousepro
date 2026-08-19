import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_options.dart';
import 'screens/login_screen.dart';
import 'services/database_helper.dart';
import 'services/zone_service.dart';
import 'seed/seed_firestore.dart';
import 'providers/theme_provider.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper.init();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final db = FirebaseFirestore.instanceFor(
    app: Firebase.app(),
    databaseId: 'warehousepro-db',
  );

  try {
    final zonesSnap = await db.collection('zones').limit(1).get();
    if (zonesSnap.docs.isEmpty) {
      await ZoneService().seedDefaultZones();
    }

    final productsSnap = await db.collection('products').limit(1).get();
    if (productsSnap.docs.isEmpty) {
      await SeedFirestore().seedProducts();
    }
  } catch (e) {
    debugPrint('Seeding failed: $e');
  }

  runApp(const ProviderScope(child: WarehouseProApp()));
}

class WarehouseProApp extends ConsumerWidget {
  const WarehouseProApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    return MaterialApp(
      title: 'WarehousePro',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      home: const LoginScreen(),
    );
  }
}
