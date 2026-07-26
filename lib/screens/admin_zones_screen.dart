import 'package:flutter/material.dart';

class _Zone {
  final String id, code, label, description;
  final int productCount;
  const _Zone({
    required this.id,
    required this.code,
    required this.label,
    required this.description,
    required this.productCount,
  });
}

const _zones = [
  _Zone(
    id: 'z-1',
    code: 'A1',
    label: 'Thiết bị mạng',
    description: 'Router, switch và thiết bị phát sóng',
    productCount: 2,
  ),
  _Zone(
    id: 'z-2',
    code: 'A2',
    label: 'Phụ kiện',
    description: 'Cáp, tai nghe và phụ kiện điện tử',
    productCount: 2,
  ),
  _Zone(
    id: 'z-3',
    code: 'B1',
    label: 'Camera',
    description: 'Camera IP và thiết bị an ninh',
    productCount: 1,
  ),
  _Zone(
    id: 'z-4',
    code: 'B2',
    label: 'Linh kiện',
    description: 'Ổ cứng, RAM và linh kiện máy tính',
    productCount: 1,
  ),
  _Zone(
    id: 'z-5',
    code: 'C1',
    label: 'Thiết bị điện',
    description: 'UPS, ổ cắm và nguồn điện',
    productCount: 1,
  ),
  _Zone(
    id: 'z-6',
    code: 'C2',
    label: 'Hàng tiêu dùng',
    description: 'Sản phẩm bán lẻ và hàng đóng gói',
    productCount: 1,
  ),
];

class AdminZonesScreen extends StatefulWidget {
  final bool embedded;
  const AdminZonesScreen({super.key, this.embedded = false});
  @override
  State<AdminZonesScreen> createState() => _AdminZonesScreenState();
}

class _AdminZonesScreenState extends State<AdminZonesScreen> {
  void _addZone() {
    final codeCtl = TextEditingController();
    final labelCtl = TextEditingController();
    final descCtl = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Thêm khu vực'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: codeCtl,
              decoration: const InputDecoration(
                labelText: 'Mã khu vực',
                hintText: 'VD: D1',
              ),
              textCapitalization: TextCapitalization.characters,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: labelCtl,
              decoration: const InputDecoration(
                labelText: 'Tên',
                hintText: 'VD: Hàng mới',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descCtl,
              decoration: const InputDecoration(labelText: 'Mô tả'),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đã thêm khu vực mới')),
              );
            },
            child: const Text('Thêm'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final body = Column(
      children: [
        // Zone grid (2 columns)
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.6,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: _zones.length,
              itemBuilder: (_, i) {
                final z = _zones[i];
                return Card(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => _editZone(context, z),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _zoneColor(z.code).withAlpha(30),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: _zoneColor(z.code).withAlpha(25),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Text(
                                    z.code,
                                    style: TextStyle(
                                      color: _zoneColor(z.code),
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Text(
                                '${z.productCount} SP',
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            z.label,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            z.description,
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 10,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        // Zone info note
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: Colors.blue.shade600),
                const SizedBox(width: 8),
                Text(
                  'Chạm vào khu vực để sửa',
                  style: TextStyle(color: Colors.blue.shade700, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ],
    );

    if (widget.embedded) return body;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Khu vực kho'),
        actions: [IconButton(icon: const Icon(Icons.add), onPressed: _addZone)],
      ),
      body: body,
    );
  }

  Color _zoneColor(String code) {
    switch (code[0]) {
      case 'A':
        return Colors.blue;
      case 'B':
        return Colors.teal;
      case 'C':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  void _editZone(BuildContext context, _Zone z) {
    final labelCtl = TextEditingController(text: z.label);
    final descCtl = TextEditingController(text: z.description);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Khu vực ${z.code}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: labelCtl,
              decoration: const InputDecoration(labelText: 'Tên'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descCtl,
              decoration: const InputDecoration(labelText: 'Mô tả'),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Đã xóa khu vực ${z.code}'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đã cập nhật khu vực')),
              );
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }
}
