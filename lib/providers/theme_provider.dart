import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/local_storage_service.dart';

final themeModeProvider = StateProvider<ThemeMode>((ref) {
  final isDark = LocalStorageService().getDarkMode();
  return isDark ? ThemeMode.dark : ThemeMode.light;
});
