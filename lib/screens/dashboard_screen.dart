import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/warehouse_provider.dart';
import 'import_screen.dart';
import 'export_screen.dart';
import 'bulk_scan_screen.dart';
import 'search_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final warehouse = ref.watch(warehouseProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('WarehousePro'),
        actions: [
          GestureDetector(
            onTap: () {
              ref.read(warehouseProvider.notifier).syncNow();
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã đồng bộ tất cả phiếu'), behavior: SnackBarBehavior.floating));
            },
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: warehouse.pendingSync > 0 ? Colors.orange.shade50 : Colors.green.shade50,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.sync_problem, size: 16, color: warehouse.pendingSync > 0 ? const Color(0xFFE65100) : Colors.green),
                  const SizedBox(width: 4),
                  Text('${warehouse.pendingSync}', style: TextStyle(fontWeight: FontWeight.bold, color: warehouse.pendingSync > 0 ? const Color(0xFFE65100) : Colors.green, fontSize: 13)),
                  Text(' chờ sync', style: TextStyle(fontSize: 12, color: warehouse.pendingSync > 0 ? const Color(0xFFE65100) : Colors.green)),
                ],
              ),
            ),
          ),
          IconButton(icon: const Icon(Icons.sync), onPressed: () {
            ref.read(warehouseProvider.notifier).syncNow();
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã đồng bộ tất cả phiếu'), behavior: SnackBarBehavior.floating));
          }),
          IconButton(icon: const Icon(Icons.person_outline), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats row
            Row(
              children: [
                Expanded(child: _StatCard(icon: Icons.inventory_2, label: 'Tổng SP', value: '${warehouse.totalProducts}', color: Colors.blue)),
                const SizedBox(width: 10),
                Expanded(child: _StatCard(icon: Icons.sync, label: 'Chờ sync', value: '${warehouse.pendingSync}', color: Colors.orange)),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _StatCard(icon: Icons.arrow_downward, label: 'Nhập hôm nay', value: '${warehouse.todayImports}', color: Colors.green)),
                const SizedBox(width: 10),
                Expanded(child: _StatCard(icon: Icons.arrow_upward, label: 'Xuất hôm nay', value: '${warehouse.todayExports}', color: Colors.red)),
              ],
            ),
            const SizedBox(height: 24),

            Text('Tác vụ nhanh', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),

            // Action grid
            Row(
              children: [
                Expanded(child: _ActionButton(icon: Icons.add_box, label: 'Nhập kho', color: Colors.blue, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ImportScreen())))),
                const SizedBox(width: 10),
                Expanded(child: _ActionButton(icon: Icons.outbox, label: 'Xuất kho', color: Colors.orange, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ExportScreen())))),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _ActionButton(icon: Icons.qr_code_scanner, label: 'Quét hàng loạt', color: Colors.teal, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BulkScanScreen())))),
                const SizedBox(width: 10),
                Expanded(child: _ActionButton(icon: Icons.search, label: 'Tra cứu', color: Colors.purple, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen())))),
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
                    child: Text('Chưa có hoạt động nào hôm nay', style: TextStyle(color: Colors.grey.shade500)),
                  ),
                ),
              )
            else
              ...warehouse.recentImports.take(3).map((e) => ListTile(
                dense: true,
                leading: CircleAvatar(radius: 16, backgroundColor: Colors.green.shade50, child: const Icon(Icons.arrow_downward, color: Colors.green, size: 18)),
                title: Text('Nhập kho: ${e['supplier']} — ${e['items']} SP', style: const TextStyle(fontSize: 13)),
                trailing: Text(_formatTime(e['time']), style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
              )),
            ...warehouse.recentExports.take(3).map((e) => ListTile(
              dense: true,
              leading: CircleAvatar(radius: 16, backgroundColor: Colors.red.shade50, child: const Icon(Icons.arrow_upward, color: Colors.red, size: 18)),
              title: Text('Xuất kho: ${e['customer']} — ${e['items']} SP', style: const TextStyle(fontSize: 13)),
              trailing: Text(_formatTime(e['time']), style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
            )),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  String _formatTime(dynamic t) {
    if (t is DateTime) return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
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
              decoration: BoxDecoration(color: color.withAlpha(25), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
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
                decoration: BoxDecoration(color: color.withAlpha(25), borderRadius: BorderRadius.circular(14)),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 10),
              Text(label, style: TextStyle(fontWeight: FontWeight.w600, color: color), textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
