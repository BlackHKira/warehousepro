import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/product_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/web_table.dart';

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

        return LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 800;
            if (!isWide) {
              return _mobile(products, totalStock, lowStock);
            }
            return _web(products, totalStock, lowStock);
          },
        );
      },
    );

    if (embedded) return body;
    return Scaffold(appBar: AppBar(title: const Text('Báo cáo XNT')), body: body);
  }

  Widget _mobile(List products, int totalStock, int lowStock) {
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
        Text('Chi tiết theo khu vực', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        ..._buildZoneSummary(products),
        const SizedBox(height: 20),
        Text('Top sản phẩm tồn thấp', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
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
  }

  Widget _web(List products, int totalStock, int lowStock) {
    final lowStockProducts = products.where((p) => p.isLowStock).toList()
      ..sort((a, b) => a.stock.compareTo(b.stock));
    return SingleChildScrollView(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 14,
            runSpacing: 14,
            children: [
              _WebStat(icon: Icons.inventory_2_outlined, label: 'Tổng giá trị tồn', value: '$totalStock', color: AppColors.primary),
              _WebStat(icon: Icons.swap_horiz, label: 'Sản phẩm', value: '${products.length}', color: AppColors.green),
              _WebStat(icon: Icons.warning_amber, label: 'Sản phẩm sắp hết', value: '$lowStock', color: AppColors.orange),
            ],
          ),
          const SizedBox(height: 22),
          const Text('Giá trị tồn kho theo khu vực', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          _ZoneGrid(products: products),
          const SizedBox(height: 22),
          const Text('Top sản phẩm tồn thấp', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          WebTable(
            minWidth: 700,
            headers: const ['Sản phẩm', 'Khu vực', 'Tồn kho'],
            rows: [
              for (final p in lowStockProducts.take(10))
                [
                  Text(p.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                  _ZoneChip(code: p.zone, color: _zoneColor(p.zone)),
                  Text(
                    formatStockDetail(p.stock, p.unitPerCase, p.unit),
                    style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.red),
                  ),
                ],
            ],
            cellAligns: const [null, null, TextAlign.right],
          ),
          if (lowStockProducts.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                'Không có sản phẩm sắp hết hàng',
                style: TextStyle(color: AppColors.textMuted, fontSize: 13),
              ),
            ),
        ],
      ),
    );
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(label, style: TextStyle(fontSize: 11, color: AppColors.textSecondary), overflow: TextOverflow.ellipsis),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: color)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WebStat extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color color;
  const _WebStat({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.6,
                    color: color,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ZoneChip extends StatelessWidget {
  final String code;
  final Color color;
  const _ZoneChip({required this.code, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        code,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color),
      ),
    );
  }
}

class _ZoneGrid extends StatelessWidget {
  final List products;
  const _ZoneGrid({required this.products});

  @override
  Widget build(BuildContext context) {
    final zones = <String, int>{};
    for (final p in products) {
      zones[p.zone] = (zones[p.zone] ?? 0) + (p.stock as int);
    }
    final sortedZones = zones.entries.toList()..sort((a, b) => a.key.compareTo(b.key));
    if (sortedZones.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Chưa có dữ liệu',
            style: TextStyle(color: AppColors.textMuted),
          ),
        ),
      );
    }
    return Wrap(
      spacing: 14,
      runSpacing: 14,
      children: sortedZones.map((e) {
        final color = _zoneColor(e.key);
        return Container(
          width: 240,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    e.key,
                    style: TextStyle(
                      color: color,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Khu ${e.key}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${e.value} sản phẩm',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${e.value}',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: color,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Color _zoneColor(String code) {
    if (code.startsWith('A')) return AppColors.primary;
    if (code.startsWith('B')) return AppColors.green;
    if (code.startsWith('C')) return AppColors.orange;
    return Colors.grey;
  }
}
