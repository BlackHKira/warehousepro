import 'package:flutter/material.dart';

class WarehouseScreen extends StatelessWidget {
  const WarehouseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Nhập / Xuất kho')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quick actions
            Row(
              children: [
                Expanded(
                  child: _ActionCard(
                    icon: Icons.arrow_circle_down,
                    label: 'Nhập kho',
                    color: Colors.green,
                    onTap: () {},
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ActionCard(
                    icon: Icons.arrow_circle_up,
                    label: 'Xuất kho',
                    color: Colors.orange,
                    onTap: () {},
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ActionCard(
                    icon: Icons.qr_code_scanner,
                    label: 'Scan QR',
                    color: cs.primary,
                    onTap: () {},
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            Text('Lịch sử giao dịch', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),

            _TransactionItem(
              type: 'Nhập kho',
              product: 'Coca Cola 355ml',
              qty: '+50 thùng',
              date: '19/07/2026',
              color: Colors.green,
              supplier: 'Tổng đại lý CTCP NGC',
            ),
            _TransactionItem(
              type: 'Xuất kho',
              product: 'Pepsi 355ml',
              qty: '-12 thùng',
              date: '19/07/2026',
              color: Colors.orange,
              supplier: 'Khách lẻ',
            ),
            _TransactionItem(
              type: 'Nhập kho',
              product: 'Sting đỏ 330ml',
              qty: '+30 thùng',
              date: '18/07/2026',
              color: Colors.green,
              supplier: 'Tổng đại lý CTCP NGC',
            ),
            _TransactionItem(
              type: 'Xuất kho',
              product: 'Aquafina 500ml',
              qty: '-24 lốc',
              date: '18/07/2026',
              color: Colors.orange,
              supplier: 'Khách lẻ',
            ),
            _TransactionItem(
              type: 'Xuất kho',
              product: 'Trà xanh C2',
              qty: '-8 lốc',
              date: '17/07/2026',
              color: Colors.orange,
              supplier: 'Khách lẻ',
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            children: [
              Icon(icon, color: color, size: 36),
              const SizedBox(height: 8),
              Text(label, style: TextStyle(fontWeight: FontWeight.w500, color: color)),
            ],
          ),
        ),
      ),
    );
  }
}

class _TransactionItem extends StatelessWidget {
  final String type;
  final String product;
  final String qty;
  final String date;
  final Color color;
  final String supplier;

  const _TransactionItem({
    required this.type,
    required this.product,
    required this.qty,
    required this.date,
    required this.color,
    required this.supplier,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withAlpha(25),
          child: Icon(type == 'Nhập kho' ? Icons.arrow_downward : Icons.arrow_upward, color: color),
        ),
        title: Text(product, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text('$type • $supplier\n$date', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
        trailing: Text(qty, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 15)),
        isThreeLine: true,
      ),
    );
  }
}
