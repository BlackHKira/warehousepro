import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../providers/product_provider.dart';
import '../providers/warehouse_provider.dart';
import '../models/product.dart';
import '../theme/app_theme.dart';

class ReportExportScreen extends ConsumerWidget {
  final bool embedded;
  const ReportExportScreen({super.key, this.embedded = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productsProvider);
    final warehouse = ref.watch(warehouseProvider);

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
                Expanded(child: _ReportStat(icon: Icons.inventory_2, label: 'Tổng tồn', value: '$totalStock', color: AppColors.primary)),
                const SizedBox(width: 10),
                Expanded(child: _ReportStat(icon: Icons.category, label: 'Sản phẩm', value: '${products.length}', color: AppColors.green)),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _ReportStat(icon: Icons.warning_amber, label: 'Sắp hết', value: '$lowStock', color: AppColors.orange)),
                const SizedBox(width: 10),
                Expanded(child: _ReportStat(icon: Icons.swap_horiz, label: 'Xuất hôm nay', value: '${warehouse.todayExports}', color: AppColors.red)),
              ],
            ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Báo cáo tồn kho', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    const Text(
                      'Xuất file Excel gồm sheet Tồn kho, Thống kê và Giao dịch gần nhất.',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: FilledButton.icon(
                        onPressed: () => _exportExcel(context, ref, products),
                        icon: const Icon(Icons.file_download_outlined),
                        label: const Text('Xuất báo cáo Excel'),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton.icon(
                        onPressed: () => _copyReport(context, products, warehouse),
                        icon: const Icon(Icons.copy_outlined),
                        label: const Text('Sao chép nội dung'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('Sản phẩm tồn thấp', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            ...products.where((p) => p.isLowStock).take(5).map((p) => Card(
              child: ListTile(
                leading: CircleAvatar(backgroundColor: AppColors.orange.withValues(alpha: 0.1), child: const Icon(Icons.warning_amber, color: AppColors.orange, size: 18)),
                title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
                subtitle: Text('${p.zone} · ${p.location}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                trailing: Text(formatStockDetail(p.stock, p.unitPerCase), style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.red, fontSize: 12)),
              ),
            )),
          ],
        );
      },
    );

    if (embedded) return body;
    return Scaffold(appBar: AppBar(title: const Text('Xuất báo cáo')), body: body);
  }

  Future<void> _exportExcel(
    BuildContext context,
    WidgetRef ref,
    List<Product> products,
  ) async {
    final warehouse = ref.read(warehouseProvider);

    if (kIsWeb) {
      if (!context.mounted) return;
      _showWebFallback(context, products, warehouse);
      return;
    }

    try {
      final bytes = _buildExcel(products, warehouse);
      final dir = await getApplicationDocumentsDirectory();
      final now = DateTime.now();
      final stamp =
          '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
      final file = File('${dir.path}/BaoCaoTonKho_$stamp.xlsx');
      await file.writeAsBytes(bytes);

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã lưu báo cáo: ${file.path}'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.green,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi xuất báo cáo: $e'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.red,
        ),
      );
    }
  }

  List<int> _buildExcel(List<Product> products, WarehouseState warehouse) {
    final excel = Excel.createExcel();

    final invSheet = excel['Tồn kho'];
    invSheet.appendRow([
      TextCellValue('Mã vạch'),
      TextCellValue('Tên sản phẩm'),
      TextCellValue('Khu vực'),
      TextCellValue('Vị trí'),
      TextCellValue('Tồn kho'),
      TextCellValue('Đơn vị'),
    ]);
    for (final p in products) {
      invSheet.appendRow([
        TextCellValue(p.barcode),
        TextCellValue(p.name),
        TextCellValue(p.zone),
        TextCellValue(p.location),
        IntCellValue(p.stock),
        TextCellValue(p.unit),
      ]);
    }

    final statSheet = excel['Thống kê'];
    final totalStock = products.fold(0, (s, p) => s + p.stock);
    final lowStock = products.where((p) => p.isLowStock).length;
    statSheet.appendRow([TextCellValue('Chỉ tiêu'), TextCellValue('Giá trị')]);
    statSheet.appendRow([TextCellValue('Tổng tồn kho'), IntCellValue(totalStock)]);
    statSheet.appendRow([TextCellValue('Số sản phẩm'), IntCellValue(products.length)]);
    statSheet.appendRow([TextCellValue('Sản phẩm sắp hết'), IntCellValue(lowStock)]);
    statSheet.appendRow([TextCellValue('Nhập hôm nay'), IntCellValue(warehouse.todayImports)]);
    statSheet.appendRow([TextCellValue('Xuất hôm nay'), IntCellValue(warehouse.todayExports)]);
    statSheet.appendRow([
      TextCellValue('Thời điểm xuất'),
      TextCellValue(DateTime.now().toString()),
    ]);

    final txSheet = excel['Giao dịch'];
    txSheet.appendRow([
      TextCellValue('Loại'),
      TextCellValue('Khách/NCC'),
      TextCellValue('Số lượng'),
      TextCellValue('Khu vực'),
      TextCellValue('Thời điểm'),
    ]);
    for (final e in [...warehouse.recentImports, ...warehouse.recentExports].take(200)) {
      final isImport = e['type'] == 'import';
      txSheet.appendRow([
        TextCellValue(isImport ? 'Nhập' : 'Xuất'),
        TextCellValue((isImport ? e['supplier'] : e['customer']) as String? ?? ''),
        IntCellValue((e['items'] as num?)?.toInt() ?? 0),
        TextCellValue(e['zone'] as String? ?? ''),
        TextCellValue(e['createdAt'] as String? ?? ''),
      ]);
    }

    final bytes = excel.save();
    if (bytes == null) throw Exception('Không tạo được file');
    return bytes;
  }

  void _showWebFallback(BuildContext context, List<Product> products, WarehouseState warehouse) {
    final report = _buildTextReport(products, warehouse);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Báo cáo tồn kho'),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: SelectableText(report, style: const TextStyle(fontSize: 12, fontFamily: 'monospace')),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: report));
              Navigator.pop(ctx);
            },
            child: const Text('Sao chép'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  Future<void> _copyReport(
    BuildContext context,
    List<Product> products,
    WarehouseState warehouse,
  ) async {
    final report = _buildTextReport(products, warehouse);
    await Clipboard.setData(ClipboardData(text: report));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã sao chép báo cáo vào bộ nhớ tạm'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.green,
      ),
    );
  }

  String _buildTextReport(List<Product> products, WarehouseState warehouse) {
    final totalStock = products.fold(0, (s, p) => s + p.stock);
    final lowStock = products.where((p) => p.isLowStock).length;
    final buffer = StringBuffer()
      ..writeln('BÁO CÁO TỒN KHO')
      ..writeln('Thời điểm: ${DateTime.now()}')
      ..writeln('----------------------------')
      ..writeln('Tổng tồn kho: $totalStock')
      ..writeln('Số sản phẩm: ${products.length}')
      ..writeln('Sản phẩm sắp hết: $lowStock')
      ..writeln('Nhập hôm nay: ${warehouse.todayImports}')
      ..writeln('Xuất hôm nay: ${warehouse.todayExports}')
      ..writeln('----------------------------')
      ..writeln('SẢN PHẨM TỒN THẤP:');
    for (final p in products.where((p) => p.isLowStock).take(10)) {
      buffer.writeln('- ${p.name} (${p.zone}): ${formatStockDetail(p.stock, p.unitPerCase)}');
    }
    return buffer.toString();
  }
}

class _ReportStat extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color color;
  const _ReportStat({required this.icon, required this.label, required this.value, required this.color});

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
