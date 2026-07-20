import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('WarehousePro')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: cs.secondaryContainer,
                      child: Icon(Icons.person, color: cs.onSecondaryContainer),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Xin chào, Admin', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                        Text('Đại lý nước giải khát', style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey.shade600)),
                      ],
                    ),
                    const Spacer(),
                    Icon(Icons.notifications_outlined, color: cs.primary),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Stats grid
            Text('Tổng quan kho', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _StatCard(icon: Icons.inventory_2, label: 'Tổng SP', value: '486', color: cs.primary)),
                const SizedBox(width: 10),
                Expanded(child: _StatCard(icon: Icons.inventory, label: 'Tổng tồn', value: '12.340', color: cs.primary)),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _StatCard(icon: Icons.warning_amber, label: 'Sắp hết', value: '23', color: cs.secondary)),
                const SizedBox(width: 10),
                Expanded(child: _StatCard(icon: Icons.error_outline, label: 'Chênh lệch', value: '5', color: cs.error)),
              ],
            ),
            const SizedBox(height: 12),

            // Activity
            Text('Giao dịch hôm nay', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            _ActivityRow(icon: Icons.arrow_downward, label: 'Nhập kho', count: '3 phiếu', color: Colors.green),
            _ActivityRow(icon: Icons.arrow_upward, label: 'Xuất kho', count: '12 phiếu', color: Colors.orange),
            _ActivityRow(icon: Icons.swap_horiz, label: 'Kiểm kê', count: '1 phiếu', color: cs.primary),

            const SizedBox(height: 12),

            // Top products
            Text('Hàng bán chạy', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            _ProductRank(index: 1, name: 'Coca Cola 355ml', sold: '24 thùng'),
            _ProductRank(index: 2, name: 'Pepsi 355ml', sold: '18 thùng'),
            _ProductRank(index: 3, name: 'Sting đỏ', sold: '15 thùng'),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
            Text(label, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
          ],
        ),
      ),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String count;
  final Color color;

  const _ActivityRow({required this.icon, required this.label, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(backgroundColor: color.withAlpha(30), child: Icon(icon, color: color)),
        title: Text(label),
        trailing: Text(count, style: TextStyle(fontWeight: FontWeight.w600, color: color)),
      ),
    );
  }
}

class _ProductRank extends StatelessWidget {
  final int index;
  final String name;
  final String sold;

  const _ProductRank({required this.index, required this.name, required this.sold});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: index == 1 ? Colors.amber.shade100 : Colors.grey.shade100,
          child: Text('$index', style: TextStyle(fontWeight: FontWeight.bold, color: index == 1 ? Colors.amber.shade800 : Colors.grey.shade700)),
        ),
        title: Text(name),
        trailing: Text(sold, style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
      ),
    );
  }
}
