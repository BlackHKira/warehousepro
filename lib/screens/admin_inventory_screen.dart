import 'package:flutter/material.dart';

class _Product {
  final String id, sku, name, barcode, category, zone, location, unit;
  final int localStock, serverStock, value;
  final String updatedAt;
  const _Product({
    required this.id,
    required this.sku,
    required this.name,
    required this.barcode,
    required this.category,
    required this.zone,
    required this.location,
    required this.localStock,
    required this.serverStock,
    required this.unit,
    required this.value,
    required this.updatedAt,
  });
}

const _products = [
  _Product(
    id: 'p-1',
    sku: 'SP-1024',
    name: 'Bộ phát Wi-Fi AX3000',
    barcode: '8938500010248',
    category: 'Thiết bị mạng',
    zone: 'A1',
    location: 'A1-01',
    localStock: 128,
    serverStock: 128,
    unit: 'cái',
    value: 1890000,
    updatedAt: '2 phút trước',
  ),
  _Product(
    id: 'p-2',
    sku: 'SP-1025',
    name: 'Cáp mạng Cat6 20m',
    barcode: '8938500010255',
    category: 'Phụ kiện',
    zone: 'A2',
    location: 'A2-03',
    localStock: 42,
    serverStock: 47,
    unit: 'sợi',
    value: 145000,
    updatedAt: '8 phút trước',
  ),
  _Product(
    id: 'p-3',
    sku: 'SP-1026',
    name: 'Camera IP trong nhà 2MP',
    barcode: '8938500010262',
    category: 'Camera',
    zone: 'B1',
    location: 'B1-02',
    localStock: 16,
    serverStock: 16,
    unit: 'cái',
    value: 820000,
    updatedAt: '12 phút trước',
  ),
  _Product(
    id: 'p-4',
    sku: 'SP-1027',
    name: 'Ổ cứng SSD 1TB NVMe',
    barcode: '8938500010279',
    category: 'Linh kiện',
    zone: 'B2',
    location: 'B2-01',
    localStock: 9,
    serverStock: 12,
    unit: 'cái',
    value: 1650000,
    updatedAt: '25 phút trước',
  ),
  _Product(
    id: 'p-5',
    sku: 'SP-1028',
    name: 'Bộ lưu điện UPS 650VA',
    barcode: '8938500010286',
    category: 'Thiết bị điện',
    zone: 'C1',
    location: 'C1-03',
    localStock: 31,
    serverStock: 31,
    unit: 'bộ',
    value: 970000,
    updatedAt: '31 phút trước',
  ),
  _Product(
    id: 'p-6',
    sku: 'SP-1029',
    name: 'Tai nghe Bluetooth Pro',
    barcode: '8938500010293',
    category: 'Phụ kiện',
    zone: 'C2',
    location: 'C2-02',
    localStock: 74,
    serverStock: 74,
    unit: 'cái',
    value: 490000,
    updatedAt: '44 phút trước',
  ),
  _Product(
    id: 'p-7',
    sku: 'SP-1030',
    name: 'Switch 8 port Gigabit',
    barcode: '8938500010309',
    category: 'Thiết bị mạng',
    zone: 'A1',
    location: 'A1-02',
    localStock: 22,
    serverStock: 22,
    unit: 'cái',
    value: 615000,
    updatedAt: '1 giờ trước',
  ),
  _Product(
    id: 'p-8',
    sku: 'SP-1031',
    name: 'Bàn phím cơ văn phòng',
    barcode: '8938500010316',
    category: 'Phụ kiện',
    zone: 'A2',
    location: 'A2-01',
    localStock: 5,
    serverStock: 5,
    unit: 'cái',
    value: 780000,
    updatedAt: '2 giờ trước',
  ),
];

class AdminInventoryScreen extends StatefulWidget {
  final bool embedded;
  const AdminInventoryScreen({super.key, this.embedded = false});
  @override
  State<AdminInventoryScreen> createState() => _AdminInventoryScreenState();
}

class _AdminInventoryScreenState extends State<AdminInventoryScreen> {
  String _search = '';
  String _filterZone = 'Tất cả';
  String _sortBy = 'name';

  List<_Product> get _filtered {
    final list = _products.where((p) {
      if (_search.isNotEmpty) {
        final q = _search.toLowerCase();
        if (!p.name.toLowerCase().contains(q) &&
            !p.sku.toLowerCase().contains(q))
          return false;
      }
      if (_filterZone != 'Tất cả' && p.zone != _filterZone) return false;
      return true;
    }).toList();
    switch (_sortBy) {
      case 'stock':
        list.sort((a, b) => a.localStock.compareTo(b.localStock));
      case 'name':
        list.sort((a, b) => a.name.compareTo(b.name));
      case 'age':
        list.sort((a, b) => a.updatedAt.compareTo(b.updatedAt));
    }
    return list;
  }

  int _stockAgeDays(String updatedAt) {
    if (updatedAt.contains('phút') || updatedAt.contains('giờ')) return 0;
    if (updatedAt.contains('hôm qua')) return 1;
    if (updatedAt.contains('ngày')) {
      final parts = updatedAt.split(' ');
      final n = int.tryParse(parts[0]);
      if (n != null) return n;
    }
    return 0;
  }

  List<String> get _zoneList {
    final zones = _products.map((p) => p.zone).toSet().toList()..sort();
    return ['Tất cả', ...zones];
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    final zoneList = _zoneList;

    final body = Column(
      children: [
        // Search + filter + sort
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    isDense: true,
                  ),
                  onChanged: (v) => setState(() => _search = v),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 100,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _filterZone,
                    isDense: true,
                    items: zoneList
                        .map(
                          (z) => DropdownMenuItem(
                            value: z,
                            child: Text(
                              z,
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _filterZone = v!),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              PopupMenuButton<String>(
                icon: const Icon(Icons.sort, size: 22),
                onSelected: (v) => setState(() => _sortBy = v),
                itemBuilder: (_) => [
                  PopupMenuItem(
                    value: 'name',
                    child: Text(
                      'Tên A-Z',
                      style: TextStyle(
                        fontWeight: _sortBy == 'name'
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                  PopupMenuItem(
                    value: 'stock',
                    child: Text(
                      'Tồn kho tăng dần',
                      style: TextStyle(
                        fontWeight: _sortBy == 'stock'
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                  PopupMenuItem(
                    value: 'age',
                    child: Text(
                      'Tuổi tồn giảm dần',
                      style: TextStyle(
                        fontWeight: _sortBy == 'age'
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Summary row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Text(
                '${filtered.length} sản phẩm',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
              const Spacer(),
              Icon(Icons.inventory_2, size: 14, color: Colors.grey.shade400),
              const SizedBox(width: 4),
              Text(
                '${filtered.fold(0, (s, p) => s + p.localStock)} tồn kho',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Product list
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: filtered.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final p = filtered[i];
              final age = _stockAgeDays(p.updatedAt);
              final isOld = age > 30;
              final isSlow = age > 14;

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => _showDetail(context, p),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: _categoryColor(p.category).withAlpha(25),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.inventory_2,
                            color: _categoryColor(p.category),
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                p.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  _ZoneChip(p.zone),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${p.localStock} ${p.unit}',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 12,
                                    ),
                                  ),
                                  if (p.localStock != p.serverStock)
                                    Text(
                                      ' · ${p.serverStock} cloud',
                                      style: TextStyle(
                                        color: Colors.orange.shade600,
                                        fontSize: 11,
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        _AgeBadge(age: age, isOld: isOld, isSlow: isSlow),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );

    if (widget.embedded) return body;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tồn kho'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            onSelected: (v) => setState(() => _sortBy = v),
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'name',
                child: Text(
                  'Tên A-Z',
                  style: TextStyle(
                    fontWeight: _sortBy == 'name'
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
              PopupMenuItem(
                value: 'stock',
                child: Text(
                  'Tồn kho tăng dần',
                  style: TextStyle(
                    fontWeight: _sortBy == 'stock'
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
              PopupMenuItem(
                value: 'age',
                child: Text(
                  'Tuổi tồn giảm dần',
                  style: TextStyle(
                    fontWeight: _sortBy == 'age'
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      body: body,
    );
  }

  Color _categoryColor(String cat) {
    switch (cat) {
      case 'Thiết bị mạng':
        return Colors.blue;
      case 'Phụ kiện':
        return Colors.purple;
      case 'Camera':
        return Colors.teal;
      case 'Linh kiện':
        return Colors.indigo;
      case 'Thiết bị điện':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  void _showDetail(BuildContext context, _Product p) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              p.name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'SKU: ${p.sku} · Mã vạch: ${p.barcode}',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
            const Divider(height: 24),
            _DetailRow('Khu vực', p.zone, Icons.map),
            _DetailRow('Vị trí', p.location, Icons.location_on),
            _DetailRow('Danh mục', p.category, Icons.category),
            _DetailRow(
              'Tồn kho',
              '${p.localStock} ${p.unit}',
              Icons.inventory_2,
            ),
            _DetailRow(
              'Đơn giá',
              '${(p.value / 1000).toStringAsFixed(0)}.000 ₫',
              Icons.attach_money,
            ),
            _DetailRow('Cập nhật', p.updatedAt, Icons.access_time),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _ZoneChip extends StatelessWidget {
  final String zone;
  const _ZoneChip(this.zone);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFeef3f7),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        zone,
        style: TextStyle(
          color: const Color(0xFF58728c),
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _AgeBadge extends StatelessWidget {
  final int age;
  final bool isOld, isSlow;
  const _AgeBadge({
    required this.age,
    required this.isOld,
    required this.isSlow,
  });
  @override
  Widget build(BuildContext context) {
    if (isOld) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          '>30 ngày',
          style: TextStyle(
            color: Colors.red.shade700,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }
    if (isSlow) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.amber.shade50,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          '>14 ngày',
          style: TextStyle(
            color: Colors.amber.shade800,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        'Mới',
        style: TextStyle(
          color: Colors.green.shade700,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label, value;
  final IconData icon;
  const _DetailRow(this.label, this.value, this.icon);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade500),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
