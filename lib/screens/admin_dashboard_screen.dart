import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/product_provider.dart';
import '../providers/zone_provider.dart';
import '../providers/users_provider.dart';
import '../providers/warehouse_provider.dart' show warehouseProvider;
import '../theme/app_theme.dart';

class AdminDashboardScreen extends ConsumerWidget {
  final bool embedded;
  const AdminDashboardScreen({super.key, this.embedded = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productsProvider);
    final zonesAsync = ref.watch(zonesProvider);
    final usersAsync = ref.watch(usersProvider);
    final warehouse = ref.watch(warehouseProvider);

    final products = productsAsync.valueOrNull ?? [];
    final zones = zonesAsync.valueOrNull ?? [];
    final users = usersAsync.valueOrNull ?? [];

    final totalStock = products.fold(0, (s, p) => s + p.stock);
    final totalValue = products.fold(0.0, (s, p) => s + p.stock * p.unitPrice);
    final lowStockCount = products.where((p) => p.isLowStock).length;

    final body = SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: _StatCard(icon: Icons.inventory_2, label: 'Tổng tồn', value: '$totalStock', color: AppColors.primary)),
              const SizedBox(width: 10),
              Expanded(child: _StatCard(icon: Icons.attach_money, label: 'Giá trị tồn', value: '${(totalValue / 1000000).toStringAsFixed(1)} tr', color: AppColors.green)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _StatCard(icon: Icons.people, label: 'Nhân sự', value: '${users.length}', color: Colors.purple)),
              const SizedBox(width: 10),
              Expanded(child: _StatCard(icon: Icons.map, label: 'Khu vực', value: '${zones.length}', color: AppColors.orange)),
            ],
          ),
          if (lowStockCount > 0) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.red.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.red.withValues(alpha: 0.3))),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber, color: AppColors.red, size: 20),
                  const SizedBox(width: 8),
                  Text('$lowStockCount sản phẩm sắp hết hàng', style: const TextStyle(color: AppColors.red, fontWeight: FontWeight.w500, fontSize: 14)),
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),

          // Import/Export chart
          Text('Nhập / Xuất theo tháng', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          SizedBox(
            height: 220,
            child: _ImportExportChart(imports: warehouse.recentImports, exports: warehouse.recentExports),
          ),
          const SizedBox(height: 24),

          // Revenue chart
          Text('Doanh thu theo tháng', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          SizedBox(
            height: 220,
            child: _RevenueChart(imports: warehouse.recentImports, exports: warehouse.recentExports, products: products),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );

    if (embedded) return body;
    return Scaffold(appBar: AppBar(title: const Text('Trang chủ')), body: body);
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
                Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: color)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ImportExportChart extends StatelessWidget {
  final List<Map<String, dynamic>> imports, exports;
  const _ImportExportChart({required this.imports, required this.exports});

  @override
  Widget build(BuildContext context) {
    final monthlyData = _aggregateByMonth(imports, exports);
    if (monthlyData.isEmpty) {
      return Card(child: Center(child: Text('Chưa có dữ liệu', style: TextStyle(color: AppColors.textMuted))));
    }

    final entries = monthlyData.entries.toList()..sort((a, b) => a.key.compareTo(b.key));
    final groups = entries.asMap().entries.map((e) {
      final idx = e.key;
      final data = e.value.value;
      return BarChartGroupData(
        x: idx,
        barRods: [
          BarChartRodData(toY: (data['import'] as num).toDouble(), color: AppColors.green, width: 12, borderRadius: const BorderRadius.vertical(top: Radius.circular(4))),
          BarChartRodData(toY: (data['export'] as num).toDouble(), color: AppColors.red, width: 12, borderRadius: const BorderRadius.vertical(top: Radius.circular(4))),
        ],
      );
    }).toList();

    final maxY = entries.map((e) => max((e.value['import'] as num).toDouble(), (e.value['export'] as num).toDouble())).fold(0.0, (a, b) => max(a, b));

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
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
    );
  }
}

class _RevenueChart extends StatelessWidget {
  final List<Map<String, dynamic>> imports, exports;
  final List products;
  const _RevenueChart({required this.imports, required this.exports, required this.products});

  @override
  Widget build(BuildContext context) {
    final monthlyRevenue = _calculateMonthlyRevenue(exports, products);
    if (monthlyRevenue.isEmpty) {
      return Card(child: Center(child: Text('Chưa có dữ liệu', style: TextStyle(color: AppColors.textMuted))));
    }

    final entries = monthlyRevenue.entries.toList()..sort((a, b) => a.key.compareTo(b.key));
    final maxRev = entries.map((e) => e.value).reduce(max);
    final spots = entries.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.value.toDouble())).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
        child: LineChart(
          LineChartData(
            minY: 0,
            maxY: maxRev * 1.2,
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                color: AppColors.primary,
                barWidth: 3,
                dotData: const FlDotData(show: true),
                belowBarData: BarAreaData(show: true, color: AppColors.primary.withValues(alpha: 0.1)),
              ),
            ],
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
                sideTitles: SideTitles(showTitles: true, reservedSize: 48, getTitlesWidget: (value, meta) {
                  if (value == 0) return const SizedBox.shrink();
                  return Text('${(value / 1000000).toStringAsFixed(0)}tr', style: const TextStyle(fontSize: 10, color: AppColors.textMuted));
                }),
              ),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            gridData: FlGridData(show: true, drawVerticalLine: false),
            borderData: FlBorderData(show: false),
            lineTouchData: LineTouchData(enabled: true),
          ),
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
  void add(String type, List<Map<String, dynamic>> list) {
    for (final t in list) {
      final createdAt = DateTime.tryParse(t['createdAt'] ?? '');
      if (createdAt == null) continue;
      final key = '${createdAt.year}-${createdAt.month.toString().padLeft(2, '0')}';
      result.putIfAbsent(key, () => {'import': 0, 'export': 0});
      final items = (t['items'] as num?)?.toInt() ?? 0;
      result[key]![type] = (result[key]![type] ?? 0) + items;
    }
  }
  add('import', imports);
  add('export', exports);
  return result;
}

Map<String, double> _calculateMonthlyRevenue(
  List<Map<String, dynamic>> exports,
  List products,
) {
  final priceMap = <String, double>{};
  for (final p in products) {
    final barcode = p.barcode as String?;
    final exportPrice = (p.exportPrice as num?)?.toDouble() ?? 0;
    if (barcode != null && barcode.isNotEmpty) {
      priceMap[barcode] = exportPrice;
    }
  }

  final result = <String, double>{};
  for (final t in exports) {
    final createdAt = DateTime.tryParse(t['createdAt'] ?? '');
    if (createdAt == null) continue;
    final key = '${createdAt.year}-${createdAt.month.toString().padLeft(2, '0')}';
    result.putIfAbsent(key, () => 0);

    final productsList = t['products'] as List<dynamic>? ?? [];
    double revenue = 0;
    for (final p in productsList) {
      final barcode = p['barcode'] as String? ?? '';
      final quantity = (p['quantity'] as num?)?.toInt() ?? 0;
      final unitPrice = priceMap[barcode] ?? 0;
      revenue += quantity * unitPrice;
    }
    if (revenue == 0) {
      final items = (t['items'] as num?)?.toInt() ?? 0;
      revenue = items * 50000;
    }
    result[key] = (result[key] ?? 0) + revenue;
  }
  return result;
}
