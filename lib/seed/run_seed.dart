import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import '../firebase_options.dart';
import 'seed_firestore.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  print("STEP 1");

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  print("STEP 2");

  final seed = SeedFirestore();

  print("STEP 3");

  await seed.seedAll();

  print("STEP 4");
}