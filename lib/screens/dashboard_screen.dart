import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../providers/warehouse_provider.dart' show warehouseProvider;
import '../providers/product_provider.dart';
import '../providers/user_profile_provider.dart';
import '../theme/app_theme.dart';
import 'import_screen.dart';
import 'export_screen.dart';
import 'search_screen.dart';
import 'bulk_scan_screen.dart';
import 'activity_history_screen.dart';
import '../widgets/pending_sync_sheet.dart';

class DashboardScreen extends ConsumerWidget {
  final bool embedded;
  const DashboardScreen({super.key, this.embedded = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final warehouse = ref.watch(warehouseProvider);
    final productsAsync = ref.watch(productsProvider);
    final profile = ref.watch(userProfileProvider);
    final products = productsAsync.valueOrNull ?? [];
    final totalStock = products.fold(0, (sum, p) => sum + p.stock);
    final userName = profile?.name ?? 'Người dùng';

    final db = FirebaseFirestore.instanceFor(
      app: Firebase.app(),
      databaseId: 'warehousepro-db',
    );

    final body = SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DashboardHeader(userName: userName, profile: profile),

          if (warehouse.pendingSync > 0)
            GestureDetector(
              onTap: warehouse.isSyncing
                  ? null
                  : () => showPendingSyncSheet(context),
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.warningLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.cloud_upload_outlined, color: AppColors.orange, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        warehouse.isSyncing
                            ? 'Đang đồng bộ...'
                            : '${warehouse.pendingSync} bản ghi chờ đồng bộ — Nhấn để xem & đồng bộ',
                        style: const TextStyle(color: AppColors.warningDark, fontWeight: FontWeight.w500, fontSize: 13),
                      ),
                    ),
                    if (warehouse.isSyncing)
                      const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.orange)),
                  ],
                ),
              ),
            ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text('THỐNG KÊ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMuted, letterSpacing: 1)),
          ),
          const SizedBox(height: 12),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(child: _StatCard(icon: Icons.inventory_2_outlined, iconBgColor: AppColors.primaryLight, iconColor: AppColors.primary, label: 'Sản phẩm', value: '$totalStock sản phẩm')),
                    const SizedBox(width: 10),
                    Expanded(child: _StatCard(icon: Icons.arrow_downward, iconBgColor: AppColors.successLight, iconColor: AppColors.green, label: 'Nhập hôm nay', value: '${warehouse.todayImports}')),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: _StatCard(icon: Icons.arrow_upward, iconBgColor: AppColors.errorLight, iconColor: AppColors.red, label: 'Xuất hôm nay', value: '${warehouse.todayExports}')),
                    const SizedBox(width: 10),
                    Expanded(child: _StatCard(icon: Icons.cloud_outlined, iconBgColor: AppColors.warningLight, iconColor: AppColors.orange, label: 'Chờ đồng bộ', value: '${warehouse.pendingSync}')),
                  ],
                ),
              ],
            ),
          ),

          if (profile?.isAdmin != true) ...[
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text('THAO TÁC NHANH', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMuted, letterSpacing: 1)),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(child: _QuickActionButton(icon: Icons.download_outlined, label: 'Nhập kho', color: AppColors.green, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ImportScreen())))),
                  const SizedBox(width: 8),
                  Expanded(child: _QuickActionButton(icon: Icons.upload_outlined, label: 'Xuất kho', color: AppColors.red, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ExportScreen())))),
                  const SizedBox(width: 8),
                  Expanded(child: _QuickActionButton(icon: Icons.qr_code_scanner_outlined, label: 'Kiểm kê', color: const Color(0xFF8B5CF6), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BulkScanScreen())))),
                  const SizedBox(width: 8),
                  Expanded(child: _QuickActionButton(icon: Icons.search_outlined, label: 'Tra cứu', color: AppColors.primary, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen())))),
                ],
              ),
            ),
          ],

          const SizedBox(height: 24),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text('HOẠT ĐỘNG GẦN ĐÂY', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMuted, letterSpacing: 1)),
                const Spacer(),
                TextButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ActivityHistoryScreen())),
                  child: const Text('Xem tất cả', style: TextStyle(fontSize: 13)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          StreamBuilder<QuerySnapshot>(
            stream: db.collection('stock_transactions')
                .orderBy('createdAt', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: Text('Chưa có hoạt động nào', style: TextStyle(color: AppColors.textMuted, fontSize: 14)),
                    ),
                  ),
                );
              }
              final now = DateTime.now();
              final twoDaysAgo = DateTime(now.year, now.month, now.day - 2);
              final docs = snapshot.data!.docs.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final ts = data['createdAt'] as Timestamp?;
                if (ts == null) return false;
                return ts.toDate().isAfter(twoDaysAgo);
              }).toList();
              if (docs.isEmpty) {
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: Text('Chưa có hoạt động nào trong 2 ngày gần đây', style: TextStyle(color: AppColors.textMuted, fontSize: 14)),
                    ),
                  ),
                );
              }
              return ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 400),
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: docs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 4),
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final isImport = data['type'] == 'import';
                    final products = data['products'] as List<dynamic>? ?? [];
                    String productName = '';
                    if (products.isNotEmpty) {
                      productName = products[0]['name'] as String? ?? '';
                    }
                    if (productName.isEmpty) {
                      productName = isImport
                          ? (data['supplier'] as String? ?? 'Nhập kho')
                          : (data['customer'] as String? ?? 'Xuất kho');
                    }
                    final ts = data['createdAt'] as Timestamp?;
                    final timeStr = ts != null
                        ? '${ts.toDate().hour.toString().padLeft(2, '0')}:${ts.toDate().minute.toString().padLeft(2, '0')}'
                        : '';
                    final createdBy = data['createdBy'] as String? ?? '';
                    final deliveredBy = data['deliveredBy'] as String? ?? '';
                    return _ActivityTile(item: _ActivityItem(
                      type: isImport ? 'import' : 'export',
                      productName: productName,
                      detail: '',
                      time: timeStr,
                      zone: data['zone'] as String? ?? 'D',
                      docId: doc.id,
                      rawData: data,
                      createdBy: createdBy,
                      deliveredBy: deliveredBy,
                    ));
                  },
                ),
              );
            },
          ),

          if (profile?.isAdmin == true) ...[
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text('NHẬP / XUẤT THEO THÁNG', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMuted, letterSpacing: 1)),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 260,
              child: _ImportExportChart(imports: warehouse.recentImports, exports: warehouse.recentExports),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text('XUẤT KHO THEO THÁNG', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMuted, letterSpacing: 1)),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 260,
              child: _ExportChart(exports: warehouse.recentExports),
            ),
          ],

          const SizedBox(height: 40),
        ],
      ),
    );

    if (embedded) return body;
    return Scaffold(body: body);
  }
}

class _DashboardHeader extends ConsumerWidget {
  final String userName;
  final UserProfileState? profile;
  const _DashboardHeader({required this.userName, this.profile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 12, 8),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFFED7AA),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.inventory_2, color: Color(0xFFF97316), size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('WarehousePro', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: AppColors.textPrimary)),
                Text('Xin chào, $userName', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF3B82F6)),
            tooltip: 'Làm mới',
            onPressed: () => ref.read(warehouseProvider.notifier).refreshFromFirestore(),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final String label;
  final String value;

  const _StatCard({
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary), overflow: TextOverflow.ellipsis),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: iconColor)),
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

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 6),
              Text(label, style: TextStyle(fontWeight: FontWeight.w600, color: color, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActivityItem {
  final String type;
  final String productName;
  final String detail;
  final String time;
  final String zone;
  final String docId;
  final Map<String, dynamic> rawData;
  final String createdBy;
  final String deliveredBy;
  const _ActivityItem({
    required this.type,
    required this.productName,
    required this.detail,
    required this.time,
    required this.zone,
    required this.docId,
    required this.rawData,
    this.createdBy = '',
    this.deliveredBy = '',
  });
}

class _ActivityTile extends StatelessWidget {
  final _ActivityItem item;
  const _ActivityTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final isImport = item.type == 'import';
    final dotColor = isImport ? AppColors.green : AppColors.red;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showDetail(context, item),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          child: Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.productName, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14, color: AppColors.textPrimary)),
                    const SizedBox(height: 2),
                    Text(_activitySubtitle(item), style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(item.time, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
            ],
          ),
        ),
      ),
    );
  }

  String _activitySubtitle(_ActivityItem item) {
    final isImport = item.type == 'import';
    final prefix = isImport ? 'NK' : 'XK';
    final zoneLabel = 'Khu ${item.zone}';
    final itemsLabel = '${item.rawData['items'] ?? 0} sp';
    final codeLabel = '$prefix-${item.docId.length >= 4 ? item.docId.substring(0, 4).toUpperCase() : '0000'}';
    final byLabel = item.createdBy.isNotEmpty ? ' — ${item.createdBy}' : '';
    final deliverLabel = item.deliveredBy.isNotEmpty ? ' — Giao: ${item.deliveredBy}' : '';
    return '$zoneLabel — $itemsLabel — $codeLabel$byLabel$deliverLabel';
  }

  void _showDetail(BuildContext context, _ActivityItem item) {
    final data = item.rawData;
    final isImport = item.type == 'import';
    final products = data['products'] as List<dynamic>? ?? [];
    final createdAt = data['createdAt'];
    String timeStr = '';
    if (createdAt is Timestamp) {
      final dt = createdAt.toDate();
      timeStr = '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } else if (createdAt is String) {
      final dt = DateTime.tryParse(createdAt);
      if (dt != null) timeStr = '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    }
    final prefix = isImport ? 'NK' : 'XK';
    final code = '$prefix-${item.docId.length >= 4 ? item.docId.substring(0, 4).toUpperCase() : '0000'}';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(isImport ? Icons.download_rounded : Icons.upload_rounded, color: isImport ? AppColors.green : AppColors.red, size: 22),
                    const SizedBox(width: 8),
                    Text(isImport ? 'Phiếu nhập kho' : 'Phiếu xuất kho', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  ],
                ),
                const SizedBox(height: 16),
                _detailRow('Mã phiếu', code),
                _detailRow('Khu vực', 'Khu ${item.zone}'),
                _detailRow('Số lượng', '${data['items'] ?? 0} sản phẩm'),
                if (isImport) _detailRow('Nhà cung cấp', (data['supplier'] as String?)?.isNotEmpty == true ? data['supplier'] : 'NCC không tên'),
                if (!isImport) _detailRow('Khách hàng', (data['customer'] as String?)?.isNotEmpty == true ? data['customer'] : 'Khách lẻ'),
                _detailRow('Ghi chú', (data['note'] as String?)?.isNotEmpty == true ? data['note'] : 'Không có'),
                _detailRow('Trạng thái', _mapStatus((data['status'] as String?))),
                if (timeStr.isNotEmpty) _detailRow('Thời gian', timeStr),
                if (item.createdBy.isNotEmpty) _detailRow('Người tạo', item.createdBy),
                if (item.deliveredBy.isNotEmpty) _detailRow('Người giao', item.deliveredBy),
                if (products.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  const Text('Sản phẩm', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  const SizedBox(height: 8),
                  ...products.map((p) => Card(
                    margin: const EdgeInsets.only(bottom: 6),
                    child: ListTile(
                      dense: true,
                      leading: CircleAvatar(
                        backgroundColor: isImport ? AppColors.successLight : AppColors.errorLight,
                        child: Icon(isImport ? Icons.add : Icons.remove, color: isImport ? AppColors.green : AppColors.red, size: 18),
                      ),
                      title: Text(p['name'] as String? ?? '', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                      subtitle: Text('Barcode: ${p['barcode'] ?? ''} — SL: ${p['quantity'] ?? 0} — Khu: ${p['zone'] ?? ''}', style: const TextStyle(fontSize: 11)),
                    ),
                  )),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _mapStatus(String? status) {
    switch (status) {
      case 'pending':
        return 'Chờ xử lý';
      case 'completed':
        return 'Hoàn thành';
      default:
        return 'Đã hoàn thành';
    }
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          ),
        ],
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

class _ExportChart extends StatelessWidget {
  final List<Map<String, dynamic>> exports;
  const _ExportChart({required this.exports});

  @override
  Widget build(BuildContext context) {
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
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      ],
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
