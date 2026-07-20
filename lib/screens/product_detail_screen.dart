import 'package:flutter/material.dart';

class ProductDetailScreen extends StatelessWidget {
  final String productName, barcode;

  const ProductDetailScreen({super.key, required this.productName, required this.barcode});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(productName)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Stock info card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    width: 72, height: 72,
                    decoration: BoxDecoration(color: cs.primaryContainer, borderRadius: BorderRadius.circular(20)),
                    child: Icon(Icons.inventory_2, color: cs.onPrimaryContainer, size: 40),
                  ),
                  const SizedBox(height: 16),
                  Text(productName, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.qr_code, size: 14, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text('Mã: $barcode', style: TextStyle(color: Colors.grey.shade600)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _stockChip(label: 'Tồn cục bộ', value: '84', color: Colors.green),
                      _stockChip(label: 'Tồn server', value: '84', color: Colors.blue),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Sync status
          Card(
            child: ListTile(
              leading: const Icon(Icons.sync, color: Colors.green),
              title: const Text('Đã đồng bộ', style: TextStyle(fontWeight: FontWeight.w500)),
              trailing: Text('19/07/2026 14:30', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
            ),
          ),
          const SizedBox(height: 16),

          // Info fields
          Text('Thông tin chi tiết', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          _infoRow(label: 'Danh mục', value: 'Nước ngọt'),
          _infoRow(label: 'Đơn vị tính', value: 'Thùng (24 lon)'),
          _infoRow(label: 'Vị trí kho', value: 'Khu A1 - Kệ 1 - Ô 01'),
          _infoRow(label: 'Giá nhập', value: '168.000đ'),
          _infoRow(label: 'Giá bán', value: '192.000đ'),
          _infoRow(label: 'Ngưỡng tồn tối thiểu', value: '10'),
          const SizedBox(height: 16),

          // Transaction history
          Text('Lịch sử giao dịch', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          _transactionRow(date: '19/07', type: 'Nhập kho', qty: '+50', color: Colors.green, ref: 'PN-2024-089'),
          _transactionRow(date: '18/07', type: 'Xuất kho', qty: '-24', color: Colors.orange, ref: 'PX-2024-156'),
          _transactionRow(date: '17/07', type: 'Xuất kho', qty: '-12', color: Colors.orange, ref: 'PX-2024-148'),
          _transactionRow(date: '16/07', type: 'Nhập kho', qty: '+30', color: Colors.green, ref: 'PN-2024-082'),
          _transactionRow(date: '15/07', type: 'Điều chỉnh', qty: '-2', color: Colors.red, ref: 'Điều chỉnh kiểm kê'),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _stockChip({required String label, required String value, required Color color}) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28, color: color)),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
      ],
    );
  }

  Widget _infoRow({required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(width: 140, child: Text(label, style: TextStyle(color: Colors.grey.shade600))),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  Widget _transactionRow({required String date, required String type, required String qty, required Color color, required String ref}) {
    return Card(
      child: ListTile(
        dense: true,
        leading: CircleAvatar(radius: 16, backgroundColor: color.withAlpha(25), child: Icon(type == 'Nhập kho' ? Icons.arrow_downward : Icons.arrow_upward, color: color, size: 18)),
        title: Text('$type • $ref', style: const TextStyle(fontSize: 14)),
        subtitle: Text(date, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
        trailing: Text(qty, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
      ),
    );
  }
}
