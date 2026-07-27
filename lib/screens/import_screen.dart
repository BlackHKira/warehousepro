import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/zone.dart';
import '../providers/warehouse_provider.dart' show warehouseProvider;
import '../providers/zone_provider.dart' show zonesProvider;
import '../models/product.dart';
import '../providers/product_provider.dart';
import '../services/zone_service.dart' show ZoneService;
import '../theme/app_theme.dart';

class ImportScreen extends ConsumerStatefulWidget {
  final bool embedded;
  const ImportScreen({super.key, this.embedded = false});

  @override
  ConsumerState<ImportScreen> createState() => _ImportScreenState();
}

class _ImportScreenState extends ConsumerState<ImportScreen> {
  final _items = <_ImportItem>[];
  final _supplierController = TextEditingController();
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _supplierController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _addItem(String name, String barcode, int qty, [String zone = 'A1']) {
    setState(() => _items.add(_ImportItem(name: name, barcode: barcode, qty: qty, zone: zone)));
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
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              final rng = Random();
              final products = ref.read(productsProvider).valueOrNull ?? [];
              if (products.isEmpty) return;
              final product = products[rng.nextInt(products.length)];
              final qty = 1 + rng.nextInt(10);
              _addItem(product.name, product.barcode, qty, product.zone);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Đã quét: ${product.name} — $qty ${product.unit}'), behavior: SnackBarBehavior.floating, duration: const Duration(seconds: 1)),
              );
            },
            child: const Text('Giả lập quét'),
          ),
        ],
      ),
    );
  }

  void _showManualDialog(List<Zone> zones) {
    final nameCtrl = TextEditingController();
    final barcodeCtrl = TextEditingController();
    final qtyCtrl = TextEditingController(text: '1');
    final fallbackZone = zones.isNotEmpty ? zones.first.code : 'A1';
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
                final qty = int.tryParse(qtyCtrl.text) ?? 0;
                if (nameCtrl.text.trim().isEmpty) return;
                if (qty <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Số lượng phải lớn hơn 0'), behavior: SnackBarBehavior.floating),
                  );
                  return;
                }
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

    final ok = await ref.read(warehouseProvider.notifier).addImport(
          totalQty,
          _supplierController.text.trim().isEmpty ? 'NCC không tên' : _supplierController.text.trim(),
          zone: mainZone,
          products: productsList,
          note: _noteController.text.trim(),
        );
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã lưu phiếu nhập — $totalQty sản phẩm'), behavior: SnackBarBehavior.floating, backgroundColor: AppColors.green),
      );
      Navigator.pop(context);
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

    final body = ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Phiếu nhập kho', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                TextField(controller: _supplierController, decoration: const InputDecoration(labelText: 'Nhà cung cấp', prefixIcon: Icon(Icons.business), isDense: true)),
                const SizedBox(height: 10),
                TextField(controller: _noteController, decoration: const InputDecoration(labelText: 'Ghi chú', prefixIcon: Icon(Icons.note), isDense: true)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: OutlinedButton.icon(onPressed: () => _showScanDialog(zones), icon: const Icon(Icons.qr_code_scanner), label: const Text('Quét mã'), style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), side: const BorderSide(color: AppColors.primary), foregroundColor: AppColors.primary).copyWith(elevation: ButtonStyleButton.allOrNull(0), shadowColor: ButtonStyleButton.allOrNull(AppColors.primary.withValues(alpha: 0.25))))),
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
                  Text('Bấm "Quét mã" hoặc "Nhập tay" để thêm', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
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
                  decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.qr_code, color: AppColors.primary),
                ),
                title: Row(
                  children: [
                    Expanded(child: Text(item.name, style: const TextStyle(fontWeight: FontWeight.w500))),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                      child: Text(item.zone, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary)),
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
                  ],
                ),
              ),
            ),
          );
        }),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity, height: 50,
          child: FilledButton.icon(
            onPressed: _items.isEmpty ? null : _save,
            icon: const Icon(Icons.save),
            label: Text('Lưu phiếu nhập (${_items.length} SP, ${_items.fold(0, (s, e) => s + e.qty)} lượng)'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.green,
              elevation: 0,
              shadowColor: AppColors.green.withValues(alpha: 0.3),
            ),
          ),
        ),
        const SizedBox(height: 40),
      ],
    );

    if (widget.embedded) return body;
    return Scaffold(appBar: AppBar(title: const Text('Nhập kho')), body: body);
  }
}

class _ImportItem {
  final String name, barcode, zone;
  int qty;
  _ImportItem({required this.name, required this.barcode, required this.qty, this.zone = 'A1'});
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
                    subtitle: Text('${p.barcode} • ${p.zone} • Tồn: ${p.stock}'),
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
