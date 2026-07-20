import 'package:flutter/material.dart';

class ExportScreen extends StatefulWidget {
  const ExportScreen({super.key});

  @override
  State<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends State<ExportScreen> {
  int _tabIndex = 0; // 0 = tạo phiếu xuất, 1 = chọn lệnh xuất

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Xuất kho')),
      body: Column(
        children: [
          // Tab selector
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _tabIndex = 0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: _tabIndex == 0 ? Theme.of(context).colorScheme.primary : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text('Tạo phiếu xuất', textAlign: TextAlign.center, style: TextStyle(color: _tabIndex == 0 ? Colors.white : Colors.grey.shade700, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _tabIndex = 1),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: _tabIndex == 1 ? Theme.of(context).colorScheme.primary : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text('Chọn lệnh xuất', textAlign: TextAlign.center, style: TextStyle(color: _tabIndex == 1 ? Colors.white : Colors.grey.shade700, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(child: _tabIndex == 0 ? const _CreateExportTab() : const _PickingOrderTab()),
        ],
      ),
    );
  }
}

class _CreateExportTab extends StatefulWidget {
  const _CreateExportTab();
  @override
  State<_CreateExportTab> createState() => _CreateExportTabState();
}

class _CreateExportTabState extends State<_CreateExportTab> {
  final _items = <_ExportItem>[];
  final _customerController = TextEditingController();

  @override
  void dispose() {
    _customerController.dispose();
    super.dispose();
  }

  void _addItem() {
    setState(() => _items.add(_ExportItem(name: 'Pepsi 355ml', barcode: '8934567890456', qty: 12)));
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
          FilledButton(onPressed: () { Navigator.pop(ctx); _addItem(); }, child: const Text('Giả lập quét')),
        ],
      ),
    );
  }

  void _save() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xuất kho'),
        content: const Text('Có 3 sản phẩm vượt quá tồn kho thực tế. Bạn có muốn tiếp tục?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Kiểm tra lại')),
          FilledButton(onPressed: () { Navigator.pop(ctx); Navigator.pop(context); }, child: const Text('Xác nhận xuất')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

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
                TextField(
                  controller: _customerController,
                  decoration: InputDecoration(labelText: 'Khách hàng', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)), prefixIcon: const Icon(Icons.person), isDense: true),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: _showScanDialog,
          icon: const Icon(Icons.qr_code_scanner),
          label: const Text('Quét mã sản phẩm'),
          style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        ),
        const SizedBox(height: 8),

        if (_items.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(children: [
                Icon(Icons.inventory_2_outlined, size: 48, color: Colors.grey.shade400),
                const SizedBox(height: 8),
                Text('Chưa có sản phẩm nào', style: TextStyle(color: Colors.grey.shade500)),
              ]),
            ),
          ),

        ..._items.map((item) => Card(
          child: ListTile(
            leading: Container(width: 44, height: 44, decoration: BoxDecoration(color: cs.errorContainer, borderRadius: BorderRadius.circular(10)), child: Icon(Icons.warning, color: cs.onErrorContainer)),
            title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.w500)),
            subtitle: Text('Tồn: 5 — Cần: ${item.qty}', style: TextStyle(color: Colors.red.shade600, fontSize: 12)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(icon: const Icon(Icons.remove_circle_outline, size: 20), onPressed: () => setState(() { if (item.qty > 1) item.qty--; })),
                Text('${item.qty}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                IconButton(icon: const Icon(Icons.add_circle_outline, size: 20), onPressed: () => setState(() => item.qty++)),
              ],
            ),
          ),
        )),

        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity, height: 50,
          child: FilledButton.icon(
            onPressed: _items.isEmpty ? null : _save,
            icon: const Icon(Icons.save),
            label: Text('Lưu phiếu xuất (${_items.length} sản phẩm)'),
            style: FilledButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }
}

class _PickingOrderTab extends StatelessWidget {
  const _PickingOrderTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _PickingOrderCard(
          id: 'PO-2024-001',
          customer: 'Cửa hàng Anh Tuấn',
          items: 5,
          status: 'pending',
          statusColor: Colors.orange,
        ),
        _PickingOrderCard(
          id: 'PO-2024-002',
          customer: 'Tạp hóa Cô Mai',
          items: 3,
          status: 'in_progress',
          statusColor: Colors.blue,
        ),
        _PickingOrderCard(
          id: 'PO-2024-003',
          customer: 'Đại lý Bia Hải',
          items: 8,
          status: 'completed',
          statusColor: Colors.green,
        ),
      ],
    );
  }
}

class _PickingOrderCard extends StatelessWidget {
  final String id, customer, status;
  final int items;
  final Color statusColor;

  const _PickingOrderCard({required this.id, required this.customer, required this.items, required this.status, required this.statusColor});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: () {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: Text('Lệnh $id'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Khách: $customer'),
                  const SizedBox(height: 12),
                  const Text('1. Coca Cola 355ml — 24 thùng', style: TextStyle(fontSize: 13)),
                  const Text('2. Pepsi 355ml — 12 thùng', style: TextStyle(fontSize: 13)),
                  const Text('3. Sting đỏ — 6 thùng', style: TextStyle(fontSize: 13)),
                  const Text('4. Aquafina 500ml — 10 lốc', style: TextStyle(fontSize: 13)),
                  const Text('5. Red Bull — 4 thùng', style: TextStyle(fontSize: 13)),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Đóng')),
                FilledButton(onPressed: () { Navigator.pop(ctx); }, child: const Text('Quét để xuất')),
              ],
            ),
          );
        },
        leading: CircleAvatar(backgroundColor: statusColor.withAlpha(25), child: Icon(_statusIcon(), color: statusColor)),
        title: Text(id, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text('$customer • $items sản phẩm'),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(color: statusColor.withAlpha(25), borderRadius: BorderRadius.circular(8)),
          child: Text(_statusText(), style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }

  IconData _statusIcon() {
    switch (status) {
      case 'pending': return Icons.hourglass_empty;
      case 'in_progress': return Icons.sync;
      case 'completed': return Icons.check_circle;
      default: return Icons.help;
    }
  }

  String _statusText() {
    switch (status) {
      case 'pending': return 'Chờ xử lý';
      case 'in_progress': return 'Đang lấy';
      case 'completed': return 'Hoàn tất';
      default: return status;
    }
  }
}

class _ExportItem {
  final String name, barcode;
  int qty;
  _ExportItem({required this.name, required this.barcode, required this.qty});
}
