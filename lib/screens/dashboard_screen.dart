import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/warehouse_provider.dart' show warehouseProvider;
import '../providers/product_provider.dart';
import '../theme/app_theme.dart';
import 'import_screen.dart';
import 'export_screen.dart';
import 'search_screen.dart';

class DashboardScreen extends ConsumerWidget {
  final bool embedded;
  const DashboardScreen({super.key, this.embedded = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final warehouse = ref.watch(warehouseProvider);
    final productsAsync = ref.watch(productsProvider);
    final products = productsAsync.valueOrNull ?? [];
    final lowStockCount = products.where((p) => p.isLowStock).length;
    final totalStock = products.fold(0, (sum, p) => sum + p.stock);

    final body = SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sync banner — tap to sync
          if (warehouse.syncError != null)
            GestureDetector(
              onTap: () {
                ref.read(warehouseProvider.notifier).clearSyncError();
                ref.read(warehouseProvider.notifier).syncData();
              },
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.red.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: AppColors.red, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        warehouse.syncError!,
                        style: const TextStyle(color: AppColors.red, fontWeight: FontWeight.w500, fontSize: 14),
                      ),
                    ),
                    const Icon(Icons.refresh, color: AppColors.red, size: 20),
                  ],
                ),
              ),
            )
          else if (warehouse.pendingSync > 0)
            GestureDetector(
              onTap: warehouse.isSyncing ? null : () => ref.read(warehouseProvider.notifier).syncData(),
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.orange.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.cloud_upload_outlined, color: AppColors.orange, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '${warehouse.pendingSync} bản ghi chờ đồng bộ',
                        style: const TextStyle(color: AppColors.orange, fontWeight: FontWeight.w500, fontSize: 14),
                      ),
                    ),
                    if (warehouse.isSyncing)
                      const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.orange))
                    else
                      const Icon(Icons.sync, color: AppColors.orange, size: 20),
                  ],
                ),
              ),
            )
          else if (warehouse.lastSyncAt != null)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.green.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.cloud_done_outlined, color: AppColors.green, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    'Đã đồng bộ',
                    style: const TextStyle(color: AppColors.green, fontWeight: FontWeight.w500, fontSize: 14),
                  ),
                ],
              ),
            ),

          // 4 Stat cards
          Row(
            children: [
              Expanded(child: _StatCard(icon: Icons.inventory_2, label: 'Tổng SP', value: '$totalStock', color: AppColors.primary)),
              const SizedBox(width: 10),
              Expanded(child: _StatCard(icon: Icons.arrow_downward, label: 'Nhập HN', value: '${warehouse.todayImports}', color: AppColors.green)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _StatCard(icon: Icons.arrow_upward, label: 'Xuất HN', value: '${warehouse.todayExports}', color: AppColors.red)),
              const SizedBox(width: 10),
              Expanded(child: _StatCard(icon: Icons.warning_amber, label: 'Sắp hết', value: '$lowStockCount', color: AppColors.orange)),
            ],
          ),
          const SizedBox(height: 24),

          // Quick actions
          Text('Tác vụ nhanh', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _ActionButton(icon: Icons.add_box, label: 'Nhập kho', color: AppColors.green, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ImportScreen())))),
              const SizedBox(width: 10),
              Expanded(child: _ActionButton(icon: Icons.outbox, label: 'Xuất kho', color: AppColors.red, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ExportScreen())))),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _ActionButton(icon: Icons.qr_code_scanner, label: 'Kiểm kê', color: AppColors.primary, onTap: () {})),
              const SizedBox(width: 10),
              Expanded(child: _ActionButton(icon: Icons.search, label: 'Tra cứu', color: AppColors.orange, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen())))),
            ],
          ),
          const SizedBox(height: 24),

          // Recent activity
          Row(
            children: [
              Text('Hoạt động gần đây', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
              const Spacer(),
              TextButton(onPressed: () {}, child: const Text('Xem tất cả')),
            ],
          ),
          const SizedBox(height: 8),
          if (warehouse.recentImports.isEmpty && warehouse.recentExports.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Text('Chưa có hoạt động nào hôm nay', style: TextStyle(color: AppColors.textMuted)),
                ),
              ),
            )
          else
            ...warehouse.recentImports.take(3).map((e) => ListTile(
                  dense: true,
                  leading: CircleAvatar(radius: 16, backgroundColor: AppColors.green.withValues(alpha: 0.1), child: const Icon(Icons.arrow_downward, color: AppColors.green, size: 18)),
                  title: Text('Nhập kho: ${e['supplier']} — ${e['items']} SP', style: const TextStyle(fontSize: 13)),
                  trailing: Text(_formatTime(e['time']), style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                )),
          ...warehouse.recentExports.take(3).map((e) => ListTile(
                dense: true,
                leading: CircleAvatar(radius: 16, backgroundColor: AppColors.red.withValues(alpha: 0.1), child: const Icon(Icons.arrow_upward, color: AppColors.red, size: 18)),
                title: Text('Xuất kho: ${e['customer']} — ${e['items']} SP', style: const TextStyle(fontSize: 13)),
                trailing: Text(_formatTime(e['time']), style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
              )),
          const SizedBox(height: 32),
        ],
      ),
    );

    if (embedded) return body;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kho'),
        actions: [
          if (warehouse.isSyncing)
            const Padding(
              padding: EdgeInsets.only(right: 12),
              child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
            )
          else if (warehouse.pendingSync > 0)
            GestureDetector(
              onTap: () => ref.read(warehouseProvider.notifier).syncData(),
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: AppColors.orange.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.sync_problem, size: 16, color: AppColors.orange),
                    const SizedBox(width: 4),
                    Text('${warehouse.pendingSync}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.orange, fontSize: 13)),
                  ],
                ),
              ),
            )
          else
            GestureDetector(
              onTap: () => ref.read(warehouseProvider.notifier).syncData(),
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: AppColors.green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.sync, size: 16, color: AppColors.green),
                    SizedBox(width: 4),
                    Text('Đã sync', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.green, fontSize: 13)),
                  ],
                ),
              ),
            ),
        ],
      ),
      body: body,
    );
  }

  String _formatTime(dynamic t) {
    if (t is DateTime) return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
    if (t is String) {
      final dt = DateTime.tryParse(t);
      if (dt != null) return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    }
    return '';
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color color;
  const _StatCard({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: color)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionButton({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            children: [
              Container(
                width: 52, height: 52,
                decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(14)),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 10),
              Text(label, style: TextStyle(fontWeight: FontWeight.w600, color: color)),
            ],
          ),
        ),
      ),
    );
  }
}
