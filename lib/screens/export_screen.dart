import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/zone.dart';
import '../providers/warehouse_provider.dart' show warehouseProvider;
import '../providers/zone_provider.dart' show zonesProvider;
import '../services/zone_service.dart' show ZoneService;

class ExportScreen extends ConsumerStatefulWidget {
  final bool embedded;
  const ExportScreen({super.key, this.embedded = false});

  @override
  ConsumerState<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends ConsumerState<ExportScreen> {
  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final body = Column(
      children: [
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
                      color: _tabIndex == 0
                          ? Theme.of(context).colorScheme.primary
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Tạo phiếu xuất',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _tabIndex == 0
                            ? Colors.white
                            : Colors.grey.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _tabIndex = 1),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: _tabIndex == 1
                          ? Theme.of(context).colorScheme.primary
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Chọn lệnh xuất',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _tabIndex == 1
                            ? Colors.white
                            : Colors.grey.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _tabIndex == 0
              ? const _CreateExportTab()
              : const _PickingOrderTab(),
        ),
      ],
    );

    if (widget.embedded) return body;

    return Scaffold(
      appBar: AppBar(title: const Text('Xuất kho')),
      body: body,
    );
  }
}

class _CreateExportTab extends ConsumerStatefulWidget {
  const _CreateExportTab();
  @override
  ConsumerState<_CreateExportTab> createState() => _CreateExportTabState();
}

class _CreateExportTabState extends ConsumerState<_CreateExportTab> {
  final _items = <_ExportItem>[];
  final _customerController = TextEditingController();

  static const _sampleProducts = [
    // A1 — Nước ngọt có gas
    ('Coca Cola 355ml', '8934567890001', 'A1'),
    ('Pepsi 355ml', '8934567890002', 'A1'),
    ('Sting đỏ 330ml', '8934567890003', 'A1'),
    ('Number 1 355ml', '8934567890004', 'A1'),
    ('7Up 355ml', '8934567890005', 'A1'),
    ('Sprite 355ml', '8934567890006', 'A1'),
    ('Fanta cam 355ml', '8934567890007', 'A1'),
    ('Mirinda Cream Soda 330ml', '8934567890008', 'A1'),
    // A2 — Nước lọc, trà, nước tăng lực
    ('Aquafina 500ml', '8934567890009', 'A2'),
    ('Trà xanh C2 500ml', '8934567890010', 'A2'),
    ('Trà O Long Tea 500ml', '8934567890011', 'A2'),
    ('Nước ép cam Twister 350ml', '8934567890012', 'A2'),
    ('Lavie 500ml', '8934567890013', 'A2'),
    ('Dasani 500ml', '8934567890014', 'A2'),
    ('Red Bull 250ml', '8934567890015', 'A2'),
    ('Monster 355ml', '8934567890016', 'A2'),
    // B1 — Mì, cháo, phở
    ('Mì tôm Hảo Hảo 75g', '8934567890017', 'B1'),
    ('Mì tôm Omachi 75g', '8934567890018', 'B1'),
    ('Mì ly Miliket 65g', '8934567890019', 'B1'),
    ('Cháo gà Vifon 60g', '8934567890020', 'B1'),
    ('Phở bò Vifon 65g', '8934567890021', 'B1'),
    ('Mì Cung Đình 75g', '8934567890022', 'B1'),
    ('Mì tôm Kokomi 80g', '8934567890023', 'B1'),
    ('Bún gạo QBB 70g', '8934567890024', 'B1'),
    // B2 — Bánh, kẹo, snack, sữa
    ('Bánh Oreo 97g', '8934567890025', 'B2'),
    ('Bánh Cosy 120g', '8934567890026', 'B2'),
    ('Khoai tây chiên Poca 90g', '8934567890027', 'B2'),
    ('Kẹo mút Chupa Chups', '8934567890028', 'B2'),
    ('Bánh gạo One One 80g', '8934567890029', 'B2'),
    ('Snack Lays 70g', '8934567890030', 'B2'),
    ('Sữa đậu nành Fami 200ml', '8934567890031', 'B2'),
    ('Sữa Milo hộp 180ml', '8934567890032', 'B2'),
    // C1 — Đồ vệ sinh cá nhân
    ('Dầu gội Clear 200ml', '8934567890033', 'C1'),
    ('Dầu gội Sunsilk 180ml', '8934567890034', 'C1'),
    ('Sữa tắm Lifebuoy 250ml', '8934567890035', 'C1'),
    ('Xà phòng Lifebuoy 90g', '8934567890036', 'C1'),
    ('Kem đánh răng Colgate 120g', '8934567890037', 'C1'),
    ('Lăn khử mùi Rexona 40ml', '8934567890038', 'C1'),
    ('Nước súc miệng Listerine 250ml', '8934567890039', 'C1'),
    ('Khăn giấy ướt Bobby 100 tờ', '8934567890040', 'C1'),
    // C2 — Gia dụng, tẩy rửa
    ('Nước rửa chén Sunlight 750ml', '8934567890041', 'C2'),
    ('Nước lau sàn Vim 500ml', '8934567890042', 'C2'),
    ('Bột giặt Omo 1kg', '8934567890043', 'C2'),
    ('Nước xả Comfort 500ml', '8934567890044', 'C2'),
    ('Thuốc tẩy Javel 500ml', '8934567890045', 'C2'),
    ('Túi rác 50x60 30c', '8934567890046', 'C2'),
    ('Khăn giấy Pulppy 10c', '8934567890047', 'C2'),
    ('Bọc nilon 30cm', '8934567890048', 'C2'),
  ];

  @override
  void dispose() {
    _customerController.dispose();
    super.dispose();
  }

  void _addItem(String name, String barcode, int qty, [String zone = 'A1']) {
    setState(
      () => _items.add(
        _ExportItem(name: name, barcode: barcode, qty: qty, zone: zone),
      ),
    );
  }

  void _showScanDialog(List<Zone> zones) {
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
                Text(
                  'Đưa mã vạch vào khung hình',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Huỷ'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              final rng = Random();
              final product =
                  _sampleProducts[rng.nextInt(_sampleProducts.length)];
              final qty = 1 + rng.nextInt(10);
              _addItem(product.$1, product.$2, qty, product.$3);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Đã quét: ${product.$1} — $qty thùng'),
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 1),
                ),
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
                  decoration: const InputDecoration(
                    labelText: 'Tên sản phẩm',
                    border: OutlineInputBorder(),
                  ),
                  autofocus: true,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: barcodeCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Mã vạch',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: qtyCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Số lượng',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: selectedZone,
                  decoration: const InputDecoration(
                    labelText: 'Khu vực',
                    border: OutlineInputBorder(),
                  ),
                  items: zones
                      .map(
                        (z) => DropdownMenuItem(
                          value: z.code,
                          child: Text(
                            z.label,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (v) =>
                      setDialogState(() => selectedZone = v ?? fallbackZone),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Huỷ'),
            ),
            FilledButton(
              onPressed: () {
                final qty = int.tryParse(qtyCtrl.text) ?? 1;
                if (nameCtrl.text.trim().isEmpty) return;
                _addItem(
                  nameCtrl.text.trim(),
                  barcodeCtrl.text.trim().isEmpty
                      ? 'N/A'
                      : barcodeCtrl.text.trim(),
                  qty,
                  selectedZone,
                );
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

    final overstock = _items.where((i) => i.qty > 100).toList();
    if (overstock.isNotEmpty) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Cảnh báo tồn kho'),
          content: Text(
            '${overstock.length} sản phẩm vượt quá tồn kho thực tế. Bạn có muốn tiếp tục?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Kiểm tra lại'),
            ),
            FilledButton(
              onPressed: () async {
                Navigator.pop(ctx);
                await _doSave(totalQty);
              },
              child: const Text('Xác nhận xuất'),
            ),
          ],
        ),
      );
    } else {
      await _doSave(totalQty);
    }
  }

  Future<void> _doSave(int totalQty) async {
    final zoneCounts = <String, int>{};
    for (final item in _items) {
      zoneCounts[item.zone] = (zoneCounts[item.zone] ?? 0) + 1;
    }
    final mainZone = zoneCounts.entries
        .reduce((a, b) => a.value >= b.value ? a : b)
        .key;

    final productsList = _items
        .map(
          (item) => {
            'name': item.name,
            'barcode': item.barcode,
            'quantity': item.qty,
            'zone': item.zone,
          },
        )
        .toList();

    await ref
        .read(warehouseProvider.notifier)
        .addExport(
          totalQty,
          _customerController.text.trim().isEmpty
              ? 'Khách lẻ'
              : _customerController.text.trim(),
          zone: mainZone,
          products: productsList,
        );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã lưu phiếu xuất — $totalQty sản phẩm'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.orange.shade700,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final zones =
        ref.watch(zonesProvider).valueOrNull ?? ZoneService.defaultZones;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Phiếu xuất kho',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _customerController,
                  decoration: InputDecoration(
                    labelText: 'Khách hàng',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: const Icon(Icons.person),
                    isDense: true,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _showScanDialog(zones),
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text('Quét mã'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton.tonalIcon(
                onPressed: () => _showManualDialog(zones),
                icon: const Icon(Icons.edit),
                label: const Text('Nhập tay'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
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
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 48,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Chưa có sản phẩm nào',
                    style: TextStyle(color: Colors.grey.shade500),
                  ),
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
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 16),
              color: Colors.red,
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            onDismissed: (_) => setState(() => _items.removeAt(i)),
            child: Card(
              child: ListTile(
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: cs.errorContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.warning, color: cs.onErrorContainer),
                ),
                title: Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.name,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '📍 ${item.zone}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
                subtitle: Text(
                  item.barcode,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline, size: 20),
                      onPressed: () => setState(() {
                        if (item.qty > 1) item.qty--;
                      }),
                    ),
                    Text(
                      '${item.qty}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline, size: 20),
                      onPressed: () => setState(() => item.qty++),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),

        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: FilledButton.icon(
            onPressed: _items.isEmpty ? null : _save,
            icon: const Icon(Icons.save),
            label: Text(
              'Lưu phiếu xuất (${_items.length} sản phẩm, ${_items.fold(0, (s, e) => s + e.qty)} lượng)',
            ),
            style: FilledButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
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

  const _PickingOrderCard({
    required this.id,
    required this.customer,
    required this.items,
    required this.status,
    required this.statusColor,
  });

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
                  const Text(
                    '1. Coca Cola 355ml — 24 thùng',
                    style: TextStyle(fontSize: 13),
                  ),
                  const Text(
                    '2. Pepsi 355ml — 12 thùng',
                    style: TextStyle(fontSize: 13),
                  ),
                  const Text(
                    '3. Sting đỏ — 6 thùng',
                    style: TextStyle(fontSize: 13),
                  ),
                  const Text(
                    '4. Aquafina 500ml — 10 lốc',
                    style: TextStyle(fontSize: 13),
                  ),
                  const Text(
                    '5. Red Bull — 4 thùng',
                    style: TextStyle(fontSize: 13),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Đóng'),
                ),
                FilledButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                  },
                  child: const Text('Quét để xuất'),
                ),
              ],
            ),
          );
        },
        leading: CircleAvatar(
          backgroundColor: statusColor.withAlpha(25),
          child: Icon(_statusIcon(), color: statusColor),
        ),
        title: Text(id, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text('$customer • $items sản phẩm'),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withAlpha(25),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            _statusText(),
            style: TextStyle(
              color: statusColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  IconData _statusIcon() {
    switch (status) {
      case 'pending':
        return Icons.hourglass_empty;
      case 'in_progress':
        return Icons.sync;
      case 'completed':
        return Icons.check_circle;
      default:
        return Icons.help;
    }
  }

  String _statusText() {
    switch (status) {
      case 'pending':
        return 'Chờ xử lý';
      case 'in_progress':
        return 'Đang lấy';
      case 'completed':
        return 'Hoàn tất';
      default:
        return status;
    }
  }
}

class _ExportItem {
  final String name, barcode, zone;
  int qty;
  _ExportItem({
    required this.name,
    required this.barcode,
    required this.qty,
    this.zone = 'A1',
  });
}
