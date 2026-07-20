import 'package:flutter/material.dart';

class ImportScreen extends StatefulWidget {
  const ImportScreen({super.key});

  @override
  State<ImportScreen> createState() => _ImportScreenState();
}

class _ImportScreenState extends State<ImportScreen> {
  final _items = <_ImportItem>[];
  final _supplierController = TextEditingController();
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _supplierController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _addItem() {
    setState(() => _items.add(_ImportItem(name: 'Coca Cola 355ml', barcode: '8934567890123', qty: 50)));
  }

  void _showScanDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Quét mã vạch'),
        content: Container(
          height: 200,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(12),
          ),
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
          FilledButton(onPressed: () { Navigator.pop(ctx); _addItem(); }, child: const Text('Giả lập quét')),
        ],
      ),
    );
  }

  void _save() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã lưu phiếu nhập kho'), behavior: SnackBarBehavior.floating),
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
          // Voucher header
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

          // Scan button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _showScanDialog,
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('Quét mã sản phẩm'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Items list
          if (_items.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(Icons.inventory_2_outlined, size: 48, color: Colors.grey.shade400),
                    const SizedBox(height: 8),
                    Text('Chưa có sản phẩm nào', style: TextStyle(color: Colors.grey.shade500)),
                    Text('Bấm "Quét mã sản phẩm" để thêm', style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
                  ],
                ),
              ),
            ),

          ..._items.asMap().entries.map((entry) {
            final item = entry.value;
            return Card(
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
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline, size: 20),
                      onPressed: () => setState(() { if (item.qty > 1) item.qty--; }),
                    ),
                    Text('${item.qty}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline, size: 20),
                      onPressed: () => setState(() => item.qty++),
                    ),
                  ],
                ),
              ),
            );
          }),

          const SizedBox(height: 20),

          // Save button
          SizedBox(
            width: double.infinity, height: 50,
            child: FilledButton.icon(
              onPressed: _items.isEmpty ? null : _save,
              icon: const Icon(Icons.save),
              label: Text('Lưu phiếu nhập (${_items.length} sản phẩm)'),
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
