import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:excel/excel.dart' hide Border;
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

        return LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 800) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 14,
                      runSpacing: 14,
                      children: [
                        _WebStat(icon: Icons.inventory_2, label: 'Tổng tồn', value: '$totalStock', color: AppColors.primary),
                        _WebStat(icon: Icons.category, label: 'Sản phẩm', value: '${products.length}', color: AppColors.green),
                        _WebStat(icon: Icons.warning_amber, label: 'Sắp hết', value: '$lowStock', color: AppColors.orange),
                        _WebStat(icon: Icons.swap_horiz, label: 'Xuất hôm nay', value: '${warehouse.todayExports}', color: AppColors.red),
                      ],
                    ),
                    const SizedBox(height: 22),
                    _ExportForm(
                      onExport: (type) => _exportExcel(context, ref, products, type),
                      onCopy: () => _copyReport(context, products, warehouse),
                    ),
                  ],
                ),
              );
            }
            return _mobileList(context, ref, products, warehouse, totalStock, lowStock);
          },
        );
      },
    );

    if (embedded) return body;
    return Scaffold(appBar: AppBar(title: const Text('Xuất báo cáo')), body: body);
  }

  Widget _mobileList(
    BuildContext context,
    WidgetRef ref,
    List<Product> products,
    WarehouseState warehouse,
    int totalStock,
    int lowStock,
  ) {
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
                        onPressed: () => _exportExcel(context, ref, products, 'Tồn kho'),
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
  }

  Future<void> _exportExcel(
    BuildContext context,
    WidgetRef ref,
    List<Product> products,
    String type,
  ) async {
    final warehouse = ref.read(warehouseProvider);

    if (kIsWeb) {
      if (!context.mounted) return;
      _showWebFallback(context, products, warehouse);
      return;
    }

    try {
      final bytes = _buildExcel(products, warehouse, type);
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

  List<int> _buildExcel(List<Product> products, WarehouseState warehouse, String type) {
    final excel = Excel.createExcel();

    // Always create base sheets
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

    // Add financial sheets when type is "Chi phí & Giá trị kho"
    if (type == 'Chi phí & Giá trị kho') {
      final totalImportValue = products.fold<int>(0, (t, p) => t + p.stock * p.unitPrice);
      final totalExportValue = products.fold<int>(0, (t, p) => t + p.stock * p.exportPrice);
      final grossProfit = totalExportValue - totalImportValue;
      final profitRate = totalImportValue > 0 ? (grossProfit / totalImportValue * 100) : 0.0;

      final costSheet = excel['Chi phí'];
      costSheet.appendRow([TextCellValue('Chỉ tiêu'), TextCellValue('Giá trị')]);
      costSheet.appendRow([TextCellValue('Tổng GT tồn (giá nhập)'), TextCellValue(_formatVND(totalImportValue))]);
      costSheet.appendRow([TextCellValue('Tổng GT tồn (giá bán)'), TextCellValue(_formatVND(totalExportValue))]);
      costSheet.appendRow([TextCellValue('Lãi gross trên tồn kho'), TextCellValue(_formatVND(grossProfit))]);
      costSheet.appendRow([TextCellValue('Tỷ lệ lãi'), TextCellValue('${profitRate.toStringAsFixed(1)}%')]);
      costSheet.appendRow([TextCellValue('Thời điểm xuất'), TextCellValue(DateTime.now().toString())]);

      final costDetailSheet = excel['Chi phí theo SP'];
      costDetailSheet.appendRow([
        TextCellValue('Tên sản phẩm'),
        TextCellValue('Mã vạch'),
        TextCellValue('Khu vực'),
        TextCellValue('Tồn (thùng)'),
        TextCellValue('Giá nhập'),
        TextCellValue('Giá bán'),
        TextCellValue('GT tồn (nhập)'),
        TextCellValue('GT tồn (bán)'),
      ]);
      final sorted = List<Product>.from(products)
        ..sort((a, b) => (b.stock * b.unitPrice).compareTo(a.stock * a.unitPrice));
      for (final p in sorted) {
        final cases = p.unitPerCase > 0 ? p.stock ~/ p.unitPerCase : p.stock;
        costDetailSheet.appendRow([
          TextCellValue(p.name),
          TextCellValue(p.barcode),
          TextCellValue(p.zone),
          IntCellValue(cases),
          TextCellValue(_formatVND(p.unitPrice)),
          TextCellValue(_formatVND(p.exportPrice)),
          TextCellValue(_formatVND(p.stock * p.unitPrice)),
          TextCellValue(_formatVND(p.stock * p.exportPrice)),
        ]);
      }
      costDetailSheet.appendRow([
        TextCellValue('TỔNG CỘNG'),
        TextCellValue(''),
        TextCellValue(''),
        IntCellValue(sorted.fold<int>(0, (t, p) => t + (p.unitPerCase > 0 ? p.stock ~/ p.unitPerCase : p.stock))),
        TextCellValue(''),
        TextCellValue(''),
        TextCellValue(_formatVND(totalImportValue)),
        TextCellValue(_formatVND(totalExportValue)),
      ]);
    }

    final bytes = excel.save();
    if (bytes == null) throw Exception('Không tạo được file');
    return bytes;
  }

  static String _formatVND(int amount) {
    final formatted = amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
    return '$formattedđ';
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
    final totalImportValue = products.fold<int>(0, (t, p) => t + p.stock * p.unitPrice);
    final totalExportValue = products.fold<int>(0, (t, p) => t + p.stock * p.exportPrice);
    final grossProfit = totalExportValue - totalImportValue;
    final profitRate = totalImportValue > 0 ? (grossProfit / totalImportValue * 100) : 0.0;

    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);

    int todayImportCost = 0;
    for (final t in warehouse.recentImports) {
      final createdAt = DateTime.tryParse(t['createdAt'] ?? '');
      if (createdAt == null || createdAt.isBefore(todayStart)) continue;
      final items = t['products'] as List<dynamic>? ?? [];
      for (final item in items) {
        if (item is Map<String, dynamic>) {
          final barcode = item['barcode'] as String? ?? '';
          final qty = (item['quantity'] as num?)?.toInt() ?? 0;
          final product = products.where((p) => p.barcode == barcode).firstOrNull;
          if (product != null) todayImportCost += qty * product.unitPrice;
        }
      }
    }

    int todayExportRevenue = 0;
    for (final t in warehouse.recentExports) {
      final createdAt = DateTime.tryParse(t['createdAt'] ?? '');
      if (createdAt == null || createdAt.isBefore(todayStart)) continue;
      final items = t['products'] as List<dynamic>? ?? [];
      for (final item in items) {
        if (item is Map<String, dynamic>) {
          final barcode = item['barcode'] as String? ?? '';
          final qty = (item['quantity'] as num?)?.toInt() ?? 0;
          final product = products.where((p) => p.barcode == barcode).firstOrNull;
          if (product != null) todayExportRevenue += qty * product.exportPrice;
        }
      }
    }

    final buffer = StringBuffer()
      ..writeln('BÁO CÁO TỒN KHO')
      ..writeln('Thời điểm: ${DateTime.now()}')
      ..writeln('----------------------------')
      ..writeln('Tổng tồn kho: $totalStock')
      ..writeln('Số sản phẩm: ${products.length}')
      ..writeln('Sản phẩm sắp hết: $lowStock')
      ..writeln('Nhập hôm nay: ${warehouse.todayImports}')
      ..writeln('Xuất hôm nay: ${warehouse.todayExports}')
      ..writeln('Tiền nhập hôm nay: ${_formatVND(todayImportCost)}')
      ..writeln('Tiền xuất hôm nay: ${_formatVND(todayExportRevenue)}')
      ..writeln('----------------------------')
      ..writeln('GIÁ TRỊ TỒN KHO:')
      ..writeln('Tồn kho (giá nhập): ${_formatVND(totalImportValue)}')
      ..writeln('Tồn kho (giá bán): ${_formatVND(totalExportValue)}')
      ..writeln('Lãi gross: ${_formatVND(grossProfit)} (${profitRate.toStringAsFixed(1)}%)')
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

class _WebStat extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color color;
  const _WebStat({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
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

class _ExportForm extends StatefulWidget {
  final ValueChanged<String> onExport;
  final VoidCallback onCopy;
  const _ExportForm({required this.onExport, required this.onCopy});

  @override
  State<_ExportForm> createState() => _ExportFormState();
}

class _ExportFormState extends State<_ExportForm> {
  String _type = 'Tồn kho';
  final _startCtrl = TextEditingController();
  final _endCtrl = TextEditingController();
  bool _includeValue = true;

  static const _reportTypes = [
    'Tồn kho',
    'Lịch sử nhập / xuất',
    'Giá trị theo khu vực',
    'Tổng hợp theo tháng',
    'Chi phí & Giá trị kho',
  ];

  @override
  void dispose() {
    _startCtrl.dispose();
    _endCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 520,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Xuất báo cáo',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          const Text(
            'File Excel dùng cho kế toán và quản lý',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 18),
          Text(
            'Loại báo cáo',
            style: _labelStyle,
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _type,
                isExpanded: true,
                style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
                items: _reportTypes
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) => setState(() => _type = v!),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _dateField('Từ ngày', _startCtrl, '01/08/2026'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _dateField('Đến ngày', _endCtrl, '31/08/2026'),
              ),
            ],
          ),
          const SizedBox(height: 6),
          CheckboxListTile(
            value: _includeValue,
            onChanged: (v) => setState(() => _includeValue = v ?? false),
            title: const Text(
              'Bao gồm giá trị thành tiền',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
            ),
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            dense: true,
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 46,
              child: FilledButton.icon(
                onPressed: () => widget.onExport(_type),
                icon: const Icon(Icons.file_download_outlined, size: 18),
              label: const Text('Xuất file Excel'),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: OutlinedButton.icon(
              onPressed: widget.onCopy,
              icon: const Icon(Icons.copy_outlined, size: 18),
              label: const Text('Sao chép nội dung'),
            ),
          ),
        ],
      ),
    );
  }

  TextStyle get _labelStyle => const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
      );

  Widget _dateField(String label, TextEditingController ctrl, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: _labelStyle),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          decoration: InputDecoration(hintText: hint, isDense: true),
        ),
      ],
    );
  }
}
