import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import '../firebase_options.dart';
import 'seed_firestore.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  debugPrint("STEP 1");

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  debugPrint("STEP 2");

  final seed = SeedFirestore();

  debugPrint("STEP 3");

  await seed.seedAll();

  debugPrint("STEP 4");
}