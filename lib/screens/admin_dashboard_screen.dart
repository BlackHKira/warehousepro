import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/warehouse_provider.dart' show warehouseProvider, WarehouseState;
import '../providers/product_provider.dart';
import '../providers/users_provider.dart';
import '../providers/zone_provider.dart';
import '../providers/user_profile_provider.dart';
import '../theme/app_theme.dart';

class AdminDashboardScreen extends ConsumerWidget {
  final bool embedded;
  const AdminDashboardScreen({super.key, this.embedded = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final warehouse = ref.watch(warehouseProvider);
    final productsAsync = ref.watch(productsProvider);
    final usersAsync = ref.watch(usersProvider);
    final zonesAsync = ref.watch(zonesProvider);
    final profile = ref.watch(userProfileProvider);
    final products = productsAsync.valueOrNull ?? [];
    final users = usersAsync.valueOrNull ?? [];
    final zones = zonesAsync.valueOrNull ?? [];
    final totalStock = products.fold(0, (s, p) => s + p.stock);
    final lowStock = products.where((p) => p.isLowStock).length;
    final staffCount = users.where((u) => u['status'] != 'inactive').length;
    final userName = profile?.name ?? 'Người dùng';

    final body = LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 800;
        if (!isWide) {
          return _mobileBody(userName, totalStock, staffCount, lowStock, zones.length, warehouse, products);
        }
        return _webBody(totalStock, staffCount, lowStock, zones.length, warehouse, products);
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
    int staffCount,
    int lowStock,
    int zoneCount,
    WarehouseState warehouse,
    List products,
  ) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Xin chào, $userName',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(
          'Tổng quan kho hàng',
          style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _DashStat(icon: Icons.inventory_2_outlined, label: 'Tổng tồn', value: '$totalStock', color: AppColors.primary)),
            const SizedBox(width: 10),
            Expanded(child: _DashStat(icon: Icons.group_outlined, label: 'Nhân sự', value: '$staffCount', color: AppColors.purple)),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _DashStat(icon: Icons.warning_amber, label: 'Sắp hết', value: '$lowStock', color: AppColors.orange)),
            const SizedBox(width: 10),
            Expanded(child: _DashStat(icon: Icons.map_outlined, label: 'Khu vực', value: '$zoneCount', color: AppColors.primary)),
          ],
        ),
        if (lowStock > 0) ...[
          const SizedBox(height: 16),
          _LowStockBanner(count: lowStock),
        ],
        const SizedBox(height: 16),
        const Text('Nhập / Xuất theo tháng', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        _AdminBarChart(warehouse: warehouse),
        const SizedBox(height: 16),
        const Text('Xuất kho theo tháng', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        _AdminLineChart(warehouse: warehouse),
        const SizedBox(height: 16),
        const Text('Tồn kho theo khu vực', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        _ZoneSummary(products: products),
      ],
    );
  }

  Widget _webBody(
    int totalStock,
    int staffCount,
    int lowStock,
    int zoneCount,
    WarehouseState warehouse,
    List products,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _WebStat(icon: Icons.inventory_2_outlined, label: 'Tổng tồn', value: '$totalStock', color: AppColors.primary)),
              const SizedBox(width: 12),
              Expanded(child: _WebStat(icon: Icons.group_outlined, label: 'Nhân sự', value: '$staffCount', color: AppColors.purple)),
              const SizedBox(width: 12),
              Expanded(child: _WebStat(icon: Icons.warning_amber, label: 'Sắp hết', value: '$lowStock', color: AppColors.orange)),
              const SizedBox(width: 12),
              Expanded(child: _WebStat(icon: Icons.map_outlined, label: 'Khu vực', value: '$zoneCount', color: AppColors.primary)),
            ],
          ),
          if (lowStock > 0) ...[
            const SizedBox(height: 14),
            _LowStockBanner(count: lowStock),
          ],
          const SizedBox(height: 16),
          const Text('Nhập / Xuất theo tháng', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          _AdminBarChart(warehouse: warehouse),
          const SizedBox(height: 16),
          const Text('Xuất kho theo tháng', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          _AdminLineChart(warehouse: warehouse),
        ],
      ),
    );
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
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: color, size: 20),
            ),
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
                Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textMuted), overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -0.6, color: color),
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

class _LowStockBanner extends StatelessWidget {
  final int count;
  const _LowStockBanner({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.red.withValues(alpha: 0.08),
        border: Border.all(color: AppColors.red.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: AppColors.red, size: 20),
          const SizedBox(width: 8),
          Text(
            '$count sản phẩm sắp hết hàng',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.red),
          ),
        ],
      ),
    );
  }
}

class _AdminBarChart extends StatelessWidget {
  final WarehouseState warehouse;
  const _AdminBarChart({required this.warehouse});

  @override
  Widget build(BuildContext context) {
    final imports = warehouse.recentImports;
    final exports = warehouse.recentExports;
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
              children: [
                _LegendDot(color: AppColors.green, label: 'Nhập kho'),
                const SizedBox(width: 20),
                _LegendDot(color: AppColors.red, label: 'Xuất kho'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminLineChart extends StatelessWidget {
  final WarehouseState warehouse;
  const _AdminLineChart({required this.warehouse});

  @override
  Widget build(BuildContext context) {
    final exports = warehouse.recentExports;
    final monthlyQty = _calculateMonthlyExportQty(exports);
    if (monthlyQty.isEmpty) {
      return Card(child: Center(child: Text('Chưa có dữ liệu', style: TextStyle(color: AppColors.textMuted))));
    }

    final entries = monthlyQty.entries.toList()..sort((a, b) => a.key.compareTo(b.key));
    final maxQty = entries.map((e) => e.value).reduce(max).toDouble();
    final spots = entries.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.value.toDouble())).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
        child: Column(
          children: [
            SizedBox(
              height: 180,
              child: LineChart(
                LineChartData(
                  minY: 0,
                  maxY: maxQty * 1.2,
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
                        return Text('${value.toInt()}', style: const TextStyle(fontSize: 10, color: AppColors.textMuted));
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
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _LegendDot(color: AppColors.primary, label: 'Số lượng xuất'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
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

Map<String, int> _calculateMonthlyExportQty(
  List<Map<String, dynamic>> exports,
) {
  final result = <String, int>{};
  for (final t in exports) {
    final createdAt = DateTime.tryParse(t['createdAt'] ?? '');
    if (createdAt == null) continue;
    final key = '${createdAt.year}-${createdAt.month.toString().padLeft(2, '0')}';
    result.putIfAbsent(key, () => 0);
    final items = (t['items'] as num?)?.toInt() ?? 0;
    result[key] = (result[key] ?? 0) + items;
  }
  return result;
}

String? _monthKey(String? createdAt) {
  final dt = DateTime.tryParse(createdAt ?? '');
  if (dt == null) return null;
  return '${dt.year}-${dt.month.toString().padLeft(2, '0')}';
}
