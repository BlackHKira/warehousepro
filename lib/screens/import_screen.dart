import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/warehouse_provider.dart';

class ImportScreen extends ConsumerStatefulWidget {
  const ImportScreen({super.key});

  @override
  ConsumerState<ImportScreen> createState() => _ImportScreenState();
}

class _ImportScreenState extends ConsumerState<ImportScreen> {
  final _items = <_ImportItem>[];
  final _supplierController = TextEditingController();
  final _noteController = TextEditingController();

  static const _sampleProducts = [
    ('Coca Cola 355ml', '8934567890123'),
    ('Pepsi 355ml', '8934567890456'),
    ('Sting đỏ 330ml', '8934567890789'),
    ('Aquafina 500ml', '8934567890111'),
    ('Number 1 355ml', '8934567890222'),
    ('Bia Tiger 330ml', '8934567890333'),
    ('Red Bull 250ml', '8934567890444'),
    ('Trà xanh C2 500ml', '8934567890555'),
    ('Monster 355ml', '8934567890666'),
    ('Sữa đậu nành Fami', '8934567890777'),
  ];

  @override
  void dispose() {
    _supplierController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _addItem(String name, String barcode, int qty) {
    setState(() => _items.add(_ImportItem(name: name, barcode: barcode, qty: qty)));
  }

  void _showScanDialog() {
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
              final product = _sampleProducts[rng.nextInt(_sampleProducts.length)];
              final qty = 1 + rng.nextInt(10);
              _addItem(product.$1, product.$2, qty);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Đã quét: ${product.$1} — $qty thùng'), behavior: SnackBarBehavior.floating, duration: const Duration(seconds: 1)));
            },
            child: const Text('Giả lập quét'),
          ),
        ],
      ),
    );
  }

  void _showManualDialog() {
    final nameCtrl = TextEditingController();
    final barcodeCtrl = TextEditingController();
    final qtyCtrl = TextEditingController(text: '1');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Thêm sản phẩm thủ công'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Tên sản phẩm', border: OutlineInputBorder()), autofocus: true),
              const SizedBox(height: 12),
              TextField(controller: barcodeCtrl, decoration: const InputDecoration(labelText: 'Mã vạch', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(controller: qtyCtrl, decoration: const InputDecoration(labelText: 'Số lượng', border: OutlineInputBorder()), keyboardType: TextInputType.number),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Huỷ')),
          FilledButton(
            onPressed: () {
              final qty = int.tryParse(qtyCtrl.text) ?? 1;
              if (nameCtrl.text.trim().isEmpty) return;
              _addItem(nameCtrl.text.trim(), barcodeCtrl.text.trim().isEmpty ? 'N/A' : barcodeCtrl.text.trim(), qty);
              Navigator.pop(ctx);
            },
            child: const Text('Thêm'),
          ),
        ],
      ),
    );
  }

  void _save() {
    if (_items.isEmpty) return;
    final totalQty = _items.fold(0, (sum, item) => sum + item.qty);
    ref.read(warehouseProvider.notifier).addImport(totalQty, _supplierController.text.trim().isEmpty ? 'NCC không tên' : _supplierController.text.trim());
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Đã lưu phiếu nhập — $totalQty sản phẩm'), behavior: SnackBarBehavior.floating, backgroundColor: Colors.green.shade700),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Nhập kho')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text('Phiếu nhập kho', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600))),
                      Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.orange.shade100, borderRadius: BorderRadius.circular(8)), child: Text('MỚI', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.orange.shade800))),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _supplierController,
                    decoration: InputDecoration(labelText: 'Nhà cung cấp', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)), prefixIcon: const Icon(Icons.business), isDense: true),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _noteController,
                    decoration: InputDecoration(labelText: 'Ghi chú', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)), prefixIcon: const Icon(Icons.note), isDense: true),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _showScanDialog,
                  icon: const Icon(Icons.qr_code_scanner),
                  label: const Text('Quét mã'),
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.tonalIcon(
                  onPressed: _showManualDialog,
                  icon: const Icon(Icons.edit),
                  label: const Text('Nhập tay'),
                  style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          if (_items.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(Icons.inventory_2_outlined, size: 48, color: Colors.grey.shade400),
                    const SizedBox(height: 8),
                    Text('Chưa có sản phẩm nào', style: TextStyle(color: Colors.grey.shade500)),
                    Text('Bấm "Quét mã" hoặc "Nhập tay" để thêm', style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
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
              background: Container(alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 16), color: Colors.red, child: const Icon(Icons.delete, color: Colors.white)),
              onDismissed: (_) => setState(() => _items.removeAt(i)),
              child: Card(
                child: ListTile(
                  leading: Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(color: cs.primaryContainer, borderRadius: BorderRadius.circular(10)),
                    child: Icon(Icons.qr_code, color: cs.onPrimaryContainer),
                  ),
                  title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.w500)),
                  subtitle: Text(item.barcode, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
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
              label: Text('Lưu phiếu nhập (${_items.length} sản phẩm, ${_items.fold(0, (s, e) => s + e.qty)} lượng)'),
              style: FilledButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _ImportItem {
  final String name, barcode;
  int qty;
  _ImportItem({required this.name, required this.barcode, required this.qty});
}
