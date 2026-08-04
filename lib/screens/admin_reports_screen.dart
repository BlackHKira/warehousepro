import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/product_provider.dart';
import '../theme/app_theme.dart';

class AdminReportsScreen extends ConsumerWidget {
  final bool embedded;
  const AdminReportsScreen({super.key, this.embedded = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productsProvider);
    final body = productsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Lỗi: $e')),
      data: (products) {
        final totalStock = products.fold(0, (s, p) => s + p.stock);
        final lowStock = products.where((p) => p.isLowStock).length;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                Expanded(child: _StatCard(icon: Icons.inventory_2, label: 'Tổng tồn', value: '$totalStock sản phẩm', color: AppColors.primary)),
                const SizedBox(width: 10),
                Expanded(child: _StatCard(icon: Icons.category, label: 'Sản phẩm', value: '${products.length}', color: AppColors.green)),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _StatCard(icon: Icons.warning_amber, label: 'Sắp hết', value: '$lowStock', color: AppColors.orange)),
                const SizedBox(width: 10),
                const Expanded(child: SizedBox.shrink()),
              ],
            ),
            const SizedBox(height: 20),
            Text('Chi tiết theo khu vực', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            ..._buildZoneSummary(products),
            const SizedBox(height: 20),
            Text('Top sản phẩm tồn thấp', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            ...() {
              final lowStockProducts = products.where((p) => p.isLowStock).toList()..sort((a, b) => a.stock.compareTo(b.stock));
              if (lowStockProducts.isEmpty) {
                return [Card(child: Padding(padding: const EdgeInsets.all(16), child: Text('Không có sản phẩm sắp hết hàng', style: TextStyle(color: AppColors.textMuted))))];
              }
              return [
                SizedBox(
                  height: 300,
                  child: ListView.separated(
                    itemCount: lowStockProducts.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 6),
                    itemBuilder: (_, i) {
                      final p = lowStockProducts[i];
                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(backgroundColor: AppColors.orange.withValues(alpha: 0.1), child: const Icon(Icons.warning_amber, color: AppColors.orange, size: 18)),
                          title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
                          subtitle: Text('${p.zone}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                          trailing: Text(formatStockDetail(p.stock, p.unitPerCase, p.unit), style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.red, fontSize: 12)),
                        ),
                      );
                    },
                  ),
                ),
              ];
            }(),
          ],
        );
      },
    );

    if (embedded) return body;
    return Scaffold(appBar: AppBar(title: const Text('Báo cáo XNT')), body: body);
  }

  List<Widget> _buildZoneSummary(List products) {
    final zones = <String, int>{};
    for (final p in products) {
      zones[p.zone] = (zones[p.zone] ?? 0) + (p.stock as int);
    }
    final sortedZones = zones.entries.toList()..sort((a, b) => a.key.compareTo(b.key));
    return sortedZones.map((e) => Card(
      child: ListTile(
        leading: Container(
          width: 40, height: 40,
          decoration: BoxDecoration(color: _zoneColor(e.key).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
          child: Center(child: Text(e.key, style: TextStyle(color: _zoneColor(e.key), fontSize: 12, fontWeight: FontWeight.bold))),
        ),
        title: Text('Khu ${e.key}', style: const TextStyle(fontWeight: FontWeight.w500)),
        trailing: Text('${e.value} sản phẩm', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    )).toList();
  }

  Color _zoneColor(String code) {
    if (code.startsWith('A')) return AppColors.primary;
    if (code.startsWith('B')) return AppColors.green;
    if (code.startsWith('C')) return AppColors.orange;
    return Colors.grey;
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
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(width: 40, height: 40, decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: color, size: 20)),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: color)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
