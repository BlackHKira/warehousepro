import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/app_theme.dart';
import '../services/product_service.dart';

class MigrationScreen extends StatefulWidget {
  const MigrationScreen({super.key});

  @override
  State<MigrationScreen> createState() => _MigrationScreenState();
}

class _MigrationScreenState extends State<MigrationScreen> {
  final _log = <String>[];
  bool _running = false;
  bool _done = false;
  bool _repairing = false;

  Future<void> _runMigration() async {
    if (_running) return;
    setState(() {
      _running = true;
      _log.clear();
    });

    final db = FirebaseFirestore.instanceFor(
      app: Firebase.app(),
      databaseId: 'warehousepro-db',
    );

    try {
      final snapshot = await db.collection('products').get();
      _log.add('Đọc ${snapshot.docs.length} products...');

      int updated = 0;
      int skipped = 0;

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final name = data['name'] as String? ?? doc.id;

        if (data.containsKey('stockByZone') && data['stockByZone'] != null) {
          _log.add('⏭️ $name — đã có stockByZone, bỏ qua');
          skipped++;
          continue;
        }

        final zone = data['zone'] as String? ?? '';
        final stock = (data['stock'] as num?)?.toInt() ?? 0;

        if (zone.isEmpty) {
          _log.add('⚠️ $name — không có zone, bỏ qua');
          skipped++;
          continue;
        }

        final stockByZone = {zone: stock};
        await doc.reference.update({'stockByZone': stockByZone});

        _log.add('✅ $name — stockByZone = {$zone: $stock}');
        updated++;
        setState(() {});
      }

      _log.add('');
      _log.add('=== Migration hoàn tất ===');
      _log.add('Đã cập nhật: $updated');
      _log.add('Bỏ qua: $skipped');
    } catch (e) {
      _log.add('❌ Lỗi: $e');
    }

    setState(() {
      _running = false;
      _done = true;
    });
  }

  Future<void> _recalculateStock() async {
    if (_repairing) return;
    setState(() {
      _repairing = true;
      _log.clear();
    });

    try {
      _log.add('Đang tính lại stock từ stockByZone...');
      final fixed = await ProductService().recalculateStockFromStockByZone();
      _log.add('');
      _log.add('=== Repari hoàn tất ===');
      _log.add('Đã sửa: $fixed sản phẩm');
    } catch (e) {
      _log.add('❌ Lỗi: $e');
    }

    setState(() {
      _repairing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Migration stockByZone')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Thêm stockByZone vào products',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Script sẽ đọc mỗi product, nếu chưa có stockByZone sẽ tạo từ zone + stock hiện tại. '
                      'Toàn bộ dữ liệu cũ (imageUrl, tên, barcode...) giữ nguyên.',
                      style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _running ? null : _runMigration,
              icon: _running
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.play_arrow),
              label: Text(_running ? 'Đang chạy...' : (_done ? 'Chạy lại' : 'Bắt đầu migration')),
            ),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: _repairing ? null : _recalculateStock,
              icon: _repairing
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.build),
              label: Text(_repairing ? 'Đang repari...' : 'Tính lại stock từ stockByZone'),
              style: FilledButton.styleFrom(backgroundColor: AppColors.orange),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _log.isEmpty
                  ? Center(
                      child: Text(
                        'Nhấn "Bắt đầu migration" để chạy',
                        style: TextStyle(color: AppColors.textMuted),
                      ),
                    )
                  : Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListView.builder(
                        itemCount: _log.length,
                        itemBuilder: (_, i) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Text(
                            _log[i],
                            style: const TextStyle(fontSize: 13, fontFamily: 'monospace'),
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
