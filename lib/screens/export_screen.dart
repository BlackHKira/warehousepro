import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/zone.dart';
import '../providers/warehouse_provider.dart' show warehouseProvider;
import '../providers/zone_provider.dart' show zonesProvider;
import '../models/product.dart';
import '../providers/product_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/barcode_scanner_screen.dart';
import '../services/zone_service.dart' show ZoneService;

class ExportScreen extends ConsumerStatefulWidget {
  final bool embedded;
  const ExportScreen({super.key, this.embedded = false});

  @override
  ConsumerState<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends ConsumerState<ExportScreen> {
  int _tabIndex = 0;

  void _switchToOrdersTab() {
    setState(() => _tabIndex = 1);
  }

  @override
  Widget build(BuildContext context) {
    final body = Column(
      children: [
        Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(12)),
          child: Row(
            children: [
              Expanded(child: GestureDetector(onTap: () => setState(() => _tabIndex = 0), child: Container(padding: const EdgeInsets.symmetric(vertical: 14), decoration: BoxDecoration(color: _tabIndex == 0 ? AppColors.primary : Colors.transparent, borderRadius: BorderRadius.circular(12)), child: Text('Tạo phiếu xuất', textAlign: TextAlign.center, style: TextStyle(color: _tabIndex == 0 ? Colors.white : AppColors.textSecondary, fontWeight: FontWeight.w600))))),
              Expanded(child: GestureDetector(onTap: () => setState(() => _tabIndex = 1), child: Container(padding: const EdgeInsets.symmetric(vertical: 14), decoration: BoxDecoration(color: _tabIndex == 1 ? AppColors.primary : Colors.transparent, borderRadius: BorderRadius.circular(12)), child: Text('Lệnh xuất', textAlign: TextAlign.center, style: TextStyle(color: _tabIndex == 1 ? Colors.white : AppColors.textSecondary, fontWeight: FontWeight.w600))))),
            ],
          ),
        ),
        Expanded(child: _tabIndex == 0 ? _CreateExportTab(onOrderCreated: _switchToOrdersTab) : const _PickingOrderTab()),
      ],
    );

    if (widget.embedded) return body;
    return Scaffold(appBar: AppBar(title: const Text('Xuất kho')), body: body);
  }
}

class _CreateExportTab extends ConsumerStatefulWidget {
  final VoidCallback onOrderCreated;
  const _CreateExportTab({required this.onOrderCreated});
  @override
  ConsumerState<_CreateExportTab> createState() => _CreateExportTabState();
}

class _CreateExportTabState extends ConsumerState<_CreateExportTab> {
  final _items = <_ExportItem>[];
  final _customerController = TextEditingController();
  final _noteController = TextEditingController();
  String _scanZone = '';

  @override
  void dispose() {
    _customerController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _addItem(String name, String barcode, int qty, [String zone = 'A1']) {
    setState(() {
      final existing = _items.where((e) => e.barcode == barcode).firstOrNull;
      if (existing != null) {
        existing.qty += qty;
      } else {
        _items.add(_ExportItem(name: name, barcode: barcode, qty: qty, zone: zone));
      }
    });
  }

  void _showScanDialog(List<Zone> zones) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Quét mã vạch'),
        content: Container(
          height: 200,
          decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(12)),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.qr_code_scanner, color: Colors.white, size: 64),
                SizedBox(height: 12),
                Text('Đưa mã vạch vào khung hình', style: TextStyle(color: Colors.white70)),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Huỷ')),
          FilledButton.icon(
            icon: const Icon(Icons.qr_code_scanner, size: 18),
            onPressed: () async {
              Navigator.pop(ctx);
              final barcode = await Navigator.push<String>(context, MaterialPageRoute(builder: (_) => const BarcodeScannerScreen()));
              if (barcode == null || !mounted) return;
              final product = await ref.read(productByBarcodeProvider(barcode).future);
              if (!mounted) return;
              if (product != null) {
                final qty = 1;
                _addItem(product.name, product.barcode, qty, _scanZone.isNotEmpty ? _scanZone : product.zone);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Đã quét: ${product.name} — $qty thùng'), behavior: SnackBarBehavior.floating, duration: const Duration(seconds: 1)),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Không tìm thấy sản phẩm với mã: $barcode'), behavior: SnackBarBehavior.floating, backgroundColor: AppColors.red),
                );
              }
            },
            label: const Text('Quét camera'),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            icon: const Icon(Icons.shuffle, size: 18),
            onPressed: () {
              Navigator.pop(ctx);
              final rng = Random();
              final products = ref.read(productsProvider).valueOrNull ?? [];
              if (products.isEmpty) return;
              final product = products[rng.nextInt(products.length)];
              final qty = 1 + rng.nextInt(10);
              _addItem(product.name, product.barcode, qty, _scanZone.isNotEmpty ? _scanZone : product.zone);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Đã quét: ${product.name} — $qty thùng'), behavior: SnackBarBehavior.floating, duration: const Duration(seconds: 1)),
              );
            },
            label: const Text('Giả lập quét'),
          ),
        ],
      ),
    );
  }

  void _showManualDialog(List<Zone> zones) {
    final nameCtrl = TextEditingController();
    final barcodeCtrl = TextEditingController();
    final qtyCtrl = TextEditingController(text: '1');
    final fallbackZone = _scanZone.isNotEmpty && zones.any((z) => z.code == _scanZone) ? _scanZone : (zones.isNotEmpty ? zones.first.code : 'A1');
    String selectedZone = fallbackZone;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Thêm sản phẩm thủ công'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Tên sản phẩm',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.search),
                  ),
                  onTap: () async {
                    final products = ref.read(productsProvider).valueOrNull ?? [];
                    final selected = await showModalBottomSheet<Product>(
                      context: ctx,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                      ),
                      builder: (_) => _ProductPickerSheet(products: products),
                    );
                    if (selected != null) {
                      setDialogState(() {
                        nameCtrl.text = selected.name;
                        barcodeCtrl.text = selected.barcode;
                        if (selected.zone.isNotEmpty) selectedZone = selected.zone;
                      });
                    }
                  },
                ),
                const SizedBox(height: 12),
                TextField(controller: barcodeCtrl, decoration: const InputDecoration(labelText: 'Mã vạch', border: OutlineInputBorder())),
                const SizedBox(height: 12),
                TextField(controller: qtyCtrl, decoration: const InputDecoration(labelText: 'Số lượng', border: OutlineInputBorder()), keyboardType: TextInputType.number),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: selectedZone,
                  decoration: const InputDecoration(labelText: 'Khu vực', border: OutlineInputBorder()),
                  items: zones.map((z) => DropdownMenuItem(value: z.code, child: Text(z.label, style: const TextStyle(fontSize: 14)))).toList(),
                  onChanged: (v) => setDialogState(() => selectedZone = v ?? fallbackZone),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Huỷ')),
            FilledButton(
              onPressed: () {
                final qty = int.tryParse(qtyCtrl.text) ?? 1;
                if (nameCtrl.text.trim().isEmpty) return;
                _addItem(nameCtrl.text.trim(), barcodeCtrl.text.trim().isEmpty ? 'N/A' : barcodeCtrl.text.trim(), qty, selectedZone);
                Navigator.pop(ctx);
              },
              child: const Text('Thêm'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (_items.isEmpty) return;
    final totalQty = _items.fold(0, (sum, item) => sum + item.qty);
    final zoneCounts = <String, int>{};
    for (final item in _items) {
      zoneCounts[item.zone] = (zoneCounts[item.zone] ?? 0) + 1;
    }
    final mainZone = zoneCounts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
    final productsList = _items.map((item) => {'name': item.name, 'barcode': item.barcode, 'quantity': item.qty, 'zone': item.zone}).toList();

    final ok = await ref.read(warehouseProvider.notifier).addExport(
          totalQty,
          _customerController.text.trim().isEmpty ? 'Khách lẻ' : _customerController.text.trim(),
          zone: mainZone,
          products: productsList,
        );
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã lưu phiếu xuất — $totalQty sản phẩm'), behavior: SnackBarBehavior.floating, backgroundColor: AppColors.green),
      );
      widget.onOrderCreated();
    } else {
      final err = ref.read(warehouseProvider).syncError ?? 'Không xác định';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi lưu: $err'), behavior: SnackBarBehavior.floating, backgroundColor: AppColors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final zones = ref.watch(zonesProvider).valueOrNull ?? ZoneService.defaultZones;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Phiếu xuất kho', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                TextField(controller: _customerController, decoration: const InputDecoration(labelText: 'Khách hàng', prefixIcon: Icon(Icons.person), isDense: true)),
                const SizedBox(height: 10),
                TextField(controller: _noteController, decoration: const InputDecoration(labelText: 'Ghi chú', prefixIcon: Icon(Icons.note), isDense: true)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Text('Khu vực xuất: ', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _scanZone.isNotEmpty && zones.any((z) => z.code == _scanZone) ? _scanZone : null,
                    isDense: true,
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      border: OutlineInputBorder(),
                    ),
                    hint: const Text('Chọn khu vực', style: TextStyle(fontSize: 13)),
                    items: zones.map((z) => DropdownMenuItem(value: z.code, child: Text(z.label, style: const TextStyle(fontSize: 13)))).toList(),
                    onChanged: (v) => setState(() => _scanZone = v ?? ''),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: OutlinedButton.icon(onPressed: () => _showScanDialog(zones), icon: const Icon(Icons.qr_code_scanner), label: const Text('Quét mã'), style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))))),
            const SizedBox(width: 12),
            Expanded(child: FilledButton.tonalIcon(onPressed: () => _showManualDialog(zones), icon: const Icon(Icons.edit), label: const Text('Nhập tay'), style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))))),
          ],
        ),
        const SizedBox(height: 8),
        if (_items.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(Icons.inventory_2_outlined, size: 48, color: AppColors.textMuted),
                  const SizedBox(height: 8),
                  Text('Chưa có sản phẩm nào', style: TextStyle(color: AppColors.textMuted)),
                ],
              ),
            ),
          ),
        ..._items.asMap().entries.map((entry) {
          final i = entry.key;
          final item = entry.value;
          return Dismissible(
            key: Key('$i-${item.barcode}'),
            direction: DismissDirection.endToStart,
            background: Container(alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 16), color: AppColors.red, child: const Icon(Icons.delete, color: Colors.white)),
            onDismissed: (_) => setState(() => _items.removeAt(i)),
            child: Card(
              child: ListTile(
                leading: Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(color: AppColors.red.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.warning, color: AppColors.red),
                ),
                title: Row(
                  children: [
                    Expanded(child: Text(item.name, style: const TextStyle(fontWeight: FontWeight.w500))),
                    const SizedBox(width: 6),
                    PopupMenuButton<String>(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(item.zone, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary)),
                            Icon(Icons.arrow_drop_down, size: 14, color: AppColors.primary),
                          ],
                        ),
                      ),
                      onSelected: (v) => setState(() => item.zone = v),
                      itemBuilder: (_) => zones.map((z) => PopupMenuItem(
                        value: z.code,
                        child: Text('${z.code} — ${z.label}', style: const TextStyle(fontSize: 13)),
                      )).toList(),
                    ),
                  ],
                ),
                subtitle: Text(item.barcode, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(icon: const Icon(Icons.remove_circle_outline, size: 20), onPressed: () => setState(() { if (item.qty > 1) item.qty--; })),
                    Text('${item.qty}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    IconButton(icon: const Icon(Icons.add_circle_outline, size: 20), onPressed: () => setState(() => item.qty++)),
                    const SizedBox(width: 4),
                    IconButton(icon: Icon(Icons.delete_outline, size: 20, color: AppColors.red), onPressed: () => setState(() => _items.removeAt(i))),
                  ],
                ),
              ),
            ),
          );
        }),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity, height: 50,
          child: FilledButton.icon(
            onPressed: _items.isEmpty ? null : _save,
            icon: const Icon(Icons.save),
            label: Text('Lưu phiếu xuất (${_items.length} SP, ${_items.fold(0, (s, e) => s + e.qty)} lượng)'),
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }
}

class _PickingOrderTab extends ConsumerWidget {
  const _PickingOrderTab();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final warehouse = ref.watch(warehouseProvider);
    final exports = warehouse.recentExports.where((e) => e['type'] == 'export').toList();

    if (exports.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.receipt_long_outlined, size: 64, color: AppColors.textMuted),
            const SizedBox(height: 12),
            Text('Chưa có lệnh xuất nào', style: TextStyle(color: AppColors.textMuted, fontSize: 15)),
            const SizedBox(height: 4),
            Text('Tạo phiếu xuất để bắt đầu', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: exports.reversed.map((order) => _PickingOrderCard(order: order)).toList(),
    );
  }
}

class _PickingOrderCard extends ConsumerWidget {
  final Map<String, dynamic> order;
  const _PickingOrderCard({required this.order});

  String get _displayId {
    final firestoreId = order['firestoreId'] as String?;
    if (firestoreId != null && firestoreId.isNotEmpty) {
      if (firestoreId.length >= 8) return 'PX-${firestoreId.substring(0, 8).toUpperCase()}';
      return 'PX-$firestoreId';
    }
    final idStr = '${order['id']}';
    if (idStr.length >= 8) return 'PX-${idStr.substring(0, 8).toUpperCase()}';
    return 'PX-${idStr.padLeft(8, '0')}';
  }

  String get _customer => order['customer'] as String? ?? 'Khách lẻ';
  int get _items => (order['items'] as num?)?.toInt() ?? 0;
  String get _status => order['status'] as String? ?? 'pending';
  List<dynamic> get _products => order['products'] as List<dynamic>? ?? [];
  String get _note => order['note'] as String? ?? '';
  String get _zone => order['zone'] as String? ?? 'A1';
  String get _createdAt => order['createdAt'] as String? ?? '';

  Color get _statusColor {
    switch (_status) {
      case 'pending': return AppColors.orange;
      case 'in_progress': return AppColors.primary;
      case 'completed': return AppColors.green;
      case 'error': return AppColors.red;
      case 'cancelled': return AppColors.textMuted;
      default: return AppColors.textMuted;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: ListTile(
        onTap: () => _showDetail(context, ref),
        leading: CircleAvatar(backgroundColor: _statusColor.withValues(alpha: 0.1), child: Icon(_statusIcon(), color: _statusColor)),
        title: Text(_displayId, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text('$_customer • $_items sản phẩm • $_createdAt'),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(color: _statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
          child: Text(_statusText(), style: TextStyle(color: _statusColor, fontSize: 12, fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }

  void _showDetail(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(warehouseProvider.notifier);
    final isTerminal = _status == 'completed' || _status == 'cancelled' || _status == 'error';
    final checked = List.filled(_products.length, false);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Row(
            children: [
              Icon(_statusIcon(), color: _statusColor, size: 22),
              const SizedBox(width: 10),
              Expanded(child: Text('Lệnh $_displayId', style: const TextStyle(fontSize: 16))),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _detailRow(Icons.person, 'Khách hàng', _customer),
                const SizedBox(height: 8),
                _detailRow(Icons.calendar_today, 'Ngày tạo', _createdAt),
                const SizedBox(height: 8),
                _detailRow(Icons.map, 'Khu vực', _zone),
                if (_note.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _detailRow(Icons.note, 'Ghi chú', _note),
                ],
                const Divider(height: 24),
                Text('Sản phẩm ($_items)', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 8),
                if (_products.isEmpty)
                  Text('Không có thông tin sản phẩm', style: TextStyle(color: AppColors.textMuted, fontSize: 13))
                else
                  ..._products.asMap().entries.map((entry) {
                    final i = entry.key;
                    final p = entry.value as Map<String, dynamic>;
                    final name = p['name'] as String? ?? 'SP ${i + 1}';
                    final qty = (p['quantity'] as num?)?.toInt() ?? 0;
                    return CheckboxListTile(
                      value: checked[i],
                      onChanged: isTerminal ? null : (v) => setDialogState(() => checked[i] = v ?? false),
                      title: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(text: '$name — ', style: TextStyle(color: AppColors.textPrimary)),
                            TextSpan(text: '$qty', style: TextStyle(fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                    );
                  }),
              ],
            ),
          ),
          actions: [
            if (!isTerminal)
              FilledButton.icon(
                onPressed: () async {
                  final allChecked = checked.every((c) => c);
                  Navigator.pop(ctx);

                  String nextStatus;
                  if (allChecked) {
                    nextStatus = _status == 'pending' ? 'in_progress' : 'completed';
                  } else {
                    nextStatus = 'error';
                  }

                  await notifier.updateExportStatus(order, nextStatus);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(allChecked
                            ? 'Lệnh $_displayId ${_status == 'pending' ? 'đang xuất' : 'hoàn thành'}'
                            : 'Lệnh $_displayId bị lỗi do thiếu hàng'),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: allChecked ? AppColors.green : AppColors.red,
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.check_circle, size: 18),
                label: const Text('Xác nhận lệnh xuất'),
                style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
              ),
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Đóng')),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textMuted),
        const SizedBox(width: 8),
        Text('$label: ', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13))),
      ],
    );
  }

  IconData _statusIcon() {
    switch (_status) {
      case 'pending': return Icons.hourglass_empty;
      case 'in_progress': return Icons.sync;
      case 'completed': return Icons.check_circle;
      case 'error': return Icons.error_outline;
      case 'cancelled': return Icons.cancel;
      default: return Icons.help;
    }
  }

  String _statusText() {
    switch (_status) {
      case 'pending': return 'Chờ xử lý';
      case 'in_progress': return 'Đang xuất';
      case 'completed': return 'Hoàn thành';
      case 'error': return 'Lỗi';
      case 'cancelled': return 'Hủy bỏ';
      default: return _status;
    }
  }
}

class _ExportItem {
  final String name, barcode;
  String zone;
  int qty;
  _ExportItem({required this.name, required this.barcode, required this.qty, this.zone = 'A1'});
}

class _ProductPickerSheet extends StatefulWidget {
  final List<Product> products;
  const _ProductPickerSheet({required this.products});

  @override
  State<_ProductPickerSheet> createState() => _ProductPickerSheetState();
}

class _ProductPickerSheetState extends State<_ProductPickerSheet> {
  final _searchCtrl = TextEditingController();
  List<Product> _filtered = [];

  @override
  void initState() {
    super.initState();
    _filtered = widget.products;
  }

  void _filter(String q) {
    final query = q.toLowerCase();
    setState(() {
      _filtered = widget.products.where((p) =>
          p.name.toLowerCase().contains(query) ||
          p.barcode.contains(query) ||
          p.sku.toLowerCase().contains(query)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (_, scrollCtrl) => Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 40, height: 4,
            decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Tìm sản phẩm...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                isDense: true,
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(icon: const Icon(Icons.clear, size: 18), onPressed: () { _searchCtrl.clear(); _filter(''); })
                    : null,
              ),
              onChanged: _filter,
            ),
          ),
          if (_filtered.isEmpty)
            Expanded(
              child: Center(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.inventory_2_outlined, size: 48, color: AppColors.textMuted),
                  const SizedBox(height: 8),
                  Text('Không tìm thấy sản phẩm', style: TextStyle(color: AppColors.textMuted)),
                ]),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                controller: scrollCtrl,
                itemCount: _filtered.length,
                itemBuilder: (_, i) {
                  final p = _filtered[i];
                  return ListTile(
                    title: Text(p.name),
                    subtitle: Text('${p.barcode} • ${p.zone} • Tồn: ${formatStock(p.stock, p.unitPerCase)}'),
                    onTap: () => Navigator.pop(context, p),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }
}
