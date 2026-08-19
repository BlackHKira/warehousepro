import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/warehouse_provider.dart' show warehouseProvider;
import '../providers/product_provider.dart';
import '../providers/user_profile_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/web_table.dart';

class AnalystDashboardScreen extends ConsumerWidget {
  final bool embedded;
  const AnalystDashboardScreen({super.key, this.embedded = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final warehouse = ref.watch(warehouseProvider);
    final productsAsync = ref.watch(productsProvider);
    final profile = ref.watch(userProfileProvider);
    final products = productsAsync.valueOrNull ?? [];
    final totalStock = products.fold(0, (s, p) => s + p.stock);
    final lowStock = products.where((p) => p.isLowStock).length;
    final userName = profile?.name ?? 'Người dùng';

    final body = LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 800;
        if (!isWide) {
          return _mobileBody(userName, totalStock, products.length, lowStock, warehouse, products);
        }
        return _webBody(totalStock, products.length, lowStock, warehouse, products);
      },
    );

    if (embedded) return body;
    return Scaffold(
      appBar: AppBar(title: const Text('Tổng quan')),
      body: body,
    );
  }

  Widget _mobileBody(
    String userName,
    int totalStock,
    int productCount,
    int lowStock,
    warehouse,
    List products,
  ) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.analytics_outlined, color: AppColors.orange, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Xin chào, $userName',
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Kế toán — Tổng quan kho vận',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'THỐNG KÊ',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMuted, letterSpacing: 1),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(child: _DashStat(icon: Icons.inventory_2_outlined, label: 'Tổng tồn', value: '$totalStock', color: AppColors.primary)),
                    const SizedBox(width: 10),
                    Expanded(child: _DashStat(icon: Icons.category_outlined, label: 'Sản phẩm', value: '$productCount', color: AppColors.green)),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: _DashStat(icon: Icons.warning_amber, label: 'Sắp hết', value: '$lowStock', color: AppColors.orange)),
                    const SizedBox(width: 10),
                    Expanded(child: _DashStat(icon: Icons.download_outlined, label: 'Nhập hôm nay', value: '${warehouse.todayImports}', color: AppColors.green)),
                    const SizedBox(width: 10),
                    Expanded(child: _DashStat(icon: Icons.upload_outlined, label: 'Xuất hôm nay', value: '${warehouse.todayExports}', color: AppColors.red)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'NHẬP / XUẤT THEO THÁNG',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMuted, letterSpacing: 1),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _AnalystChart(imports: warehouse.recentImports, exports: warehouse.recentExports),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'CHI TIẾT THEO KHU VỰC',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMuted, letterSpacing: 1),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _ZoneSummary(products: products),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'SẢN PHẨM TỒN THẤP',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMuted, letterSpacing: 1),
            ),
          ),
          const SizedBox(height: 8),
          if (products.where((p) => p.isLowStock).isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Không có sản phẩm nào sắp hết',
                style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
              ),
            )
          else
            ...products.where((p) => p.isLowStock).take(5).map((p) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
              child: Card(
                child: ListTile(
                  leading: CircleAvatar(backgroundColor: AppColors.orange.withValues(alpha: 0.1), child: const Icon(Icons.warning_amber, color: AppColors.orange, size: 18)),
                  title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
                  subtitle: Text('${p.zone} · ${p.location}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  trailing: Text(formatStockDetail(p.stock, p.unitPerCase), style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.red, fontSize: 12)),
                ),
              ),
            )),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _webBody(
    int totalStock,
    int productCount,
    int lowStock,
    warehouse,
    List products,
  ) {
    final importCount = _countThisMonth(warehouse.recentImports);
    final exportCount = _countThisMonth(warehouse.recentExports);
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
              _WebStat(icon: Icons.inventory_2_outlined, label: 'Giá trị tồn kho', value: '$totalStock', color: AppColors.primary),
              _WebStat(icon: Icons.add_box_outlined, label: 'Phiếu nhập tháng', value: '$importCount', color: AppColors.green),
              _WebStat(icon: Icons.outbox_outlined, label: 'Phiếu xuất tháng', value: '$exportCount', color: AppColors.orange),
              _WebStat(icon: Icons.warning_amber, label: 'Sắp hết hàng', value: '$lowStock', color: AppColors.red),
            ],
          ),
          const SizedBox(height: 22),
          const _SectionTitle('Nhập / Xuất theo tháng'),
          const SizedBox(height: 10),
          _AnalystChart(imports: warehouse.recentImports, exports: warehouse.recentExports),
          const SizedBox(height: 22),
          const _SectionTitle('Tồn kho theo khu vực'),
          const SizedBox(height: 10),
          _ZoneGrid(products: products),
          const SizedBox(height: 22),
          const _SectionTitle('Sản phẩm tồn thấp'),
          const SizedBox(height: 10),
          WebTable(
            minWidth: 700,
            headers: const ['Sản phẩm', 'Khu vực', 'Vị trí', 'Tồn kho'],
            rows: [
              for (final p in lowStockProducts.take(10))
                [
                  Text(p.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                  _ZoneChip(code: p.zone),
                  Text(p.location, style: const TextStyle(color: AppColors.textSecondary)),
                  Text(
                    formatStockDetail(p.stock, p.unitPerCase),
                    style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.red),
                  ),
                ],
            ],
            cellAligns: const [null, null, null, TextAlign.right],
          ),
          if (lowStockProducts.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                'Không có sản phẩm nào sắp hết',
                style: TextStyle(color: AppColors.textMuted, fontSize: 13),
              ),
            ),
        ],
      ),
    );
  }

  int _countThisMonth(List<Map<String, dynamic>> entries) {
    final now = DateTime.now();
    return entries.where((e) {
      final dt = DateTime.tryParse(e['createdAt'] as String? ?? '');
      return dt != null && dt.year == now.year && dt.month == now.month;
    }).length;
  }
}

class _DashStat extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color color;
  const _DashStat({required this.icon, required this.label, required this.value, required this.color});

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
      width: 190,
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

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
    );
  }
}

class _ZoneChip extends StatelessWidget {
  final String code;
  const _ZoneChip({required this.code});

  @override
  Widget build(BuildContext context) {
    final color = _zoneColor(code);
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

  Color _zoneColor(String code) {
    if (code.startsWith('A')) return AppColors.primary;
    if (code.startsWith('B')) return AppColors.green;
    if (code.startsWith('C')) return AppColors.orange;
    return Colors.grey;
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

class _AnalystChart extends StatelessWidget {
  final List<Map<String, dynamic>> imports, exports;
  const _AnalystChart({required this.imports, required this.exports});

  @override
  Widget build(BuildContext context) {
    final monthlyData = _aggregateByMonth(imports, exports);
    if (monthlyData.isEmpty) {
      return Card(child: Center(child: Text('Chưa có dữ liệu', style: TextStyle(color: AppColors.textMuted))));
    }

    final entries = monthlyData.entries.toList()..sort((a, b) => a.key.compareTo(b.key));
    final groups = entries.asMap().entries.map((e) {
      final data = e.value.value;
      return BarChartGroupData(
        x: e.key,
        barRods: [
          BarChartRodData(toY: (data['import'] as num).toDouble(), color: AppColors.green, width: 12, borderRadius: const BorderRadius.vertical(top: Radius.circular(4))),
          BarChartRodData(toY: (data['export'] as num).toDouble(), color: AppColors.red, width: 12, borderRadius: const BorderRadius.vertical(top: Radius.circular(4))),
        ],
      );
    }).toList();

    final maxY = entries
        .map((e) => max((e.value['import'] as num).toDouble(), (e.value['export'] as num).toDouble()))
        .fold(0.0, (a, b) => max(a, b));

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
        child: Column(
          children: [
            SizedBox(
              height: 180,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxY * 1.2,
                  barGroups: groups,
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          if (idx < 0 || idx >= entries.length) return const SizedBox.shrink();
                          final label = entries[idx].key.split('-').last;
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text('T$label', style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true, reservedSize: 36, getTitlesWidget: (value, meta) {
                        return Text('${value.toInt()}', style: const TextStyle(fontSize: 10, color: AppColors.textMuted));
                      }),
                    ),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: maxY > 0 ? maxY / 4 : 1),
                  borderData: FlBorderData(show: false),
                  barTouchData: BarTouchData(enabled: true),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                _ChartLegend(color: AppColors.green, label: 'Nhập kho'),
                SizedBox(width: 20),
                _ChartLegend(color: AppColors.red, label: 'Xuất kho'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Map<String, Map<String, int>> _aggregateByMonth(
  List<Map<String, dynamic>> imports,
  List<Map<String, dynamic>> exports,
) {
  final result = <String, Map<String, int>>{};
  for (final e in imports) {
    final month = _monthKey(e['createdAt'] as String?);
    if (month == null) continue;
    result.putIfAbsent(month, () => {'import': 0, 'export': 0});
    result[month]!['import'] = (result[month]!['import'] ?? 0) + ((e['items'] as num?)?.toInt() ?? 0);
  }
  for (final e in exports) {
    final month = _monthKey(e['createdAt'] as String?);
    if (month == null) continue;
    result.putIfAbsent(month, () => {'import': 0, 'export': 0});
    result[month]!['export'] = (result[month]!['export'] ?? 0) + ((e['items'] as num?)?.toInt() ?? 0);
  }
  return result;
}

String? _monthKey(String? createdAt) {
  final dt = DateTime.tryParse(createdAt ?? '');
  if (dt == null) return null;
  return '${dt.year}-${dt.month.toString().padLeft(2, '0')}';
}

class _ChartLegend extends StatelessWidget {
  final Color color;
  final String label;
  const _ChartLegend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      ],
    );
  }
}

class _ZoneSummary extends StatelessWidget {
  final List products;
  const _ZoneSummary({required this.products});

  @override
  Widget build(BuildContext context) {
    final zones = <String, int>{};
    for (final p in products) {
      zones[p.zone] = (zones[p.zone] ?? 0) + (p.stock as int);
    }
    final sortedZones = zones.entries.toList()..sort((a, b) => a.key.compareTo(b.key));
    if (sortedZones.isEmpty) {
      return Card(child: Center(child: Text('Chưa có dữ liệu', style: TextStyle(color: AppColors.textMuted))));
    }
    return Column(
      children: sortedZones.map((e) => Card(
        child: ListTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: _zoneColor(e.key).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
            child: Center(child: Text(e.key, style: TextStyle(color: _zoneColor(e.key), fontSize: 12, fontWeight: FontWeight.bold))),
          ),
          title: Text('Khu ${e.key}', style: const TextStyle(fontWeight: FontWeight.w500)),
          trailing: Text('${e.value}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ),
      )).toList(),
    );
  }

  Color _zoneColor(String code) {
    if (code.startsWith('A')) return AppColors.primary;
    if (code.startsWith('B')) return AppColors.green;
    if (code.startsWith('C')) return AppColors.orange;
    return Colors.grey;
  }
}
