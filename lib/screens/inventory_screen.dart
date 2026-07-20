import 'package:flutter/material.dart';

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kiểm kê & Cảnh báo'),
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // New stocktake button
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.assignment_add),
                label: const Text('Tạo phiếu kiểm kê mới'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
            const SizedBox(height: 20),

            Text('Cảnh báo tồn kho', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),

            _AlertCard(
              icon: Icons.warning,
              product: 'Bia Heineken 330ml',
              stock: 2,
              threshold: 10,
              status: 'Nguy cấp',
              color: cs.error,
            ),
            _AlertCard(
              icon: Icons.notifications_active,
              product: 'Sting đỏ 330ml',
              stock: 5,
              threshold: 15,
              status: 'Nguy cấp',
              color: cs.error,
            ),
            _AlertCard(
              icon: Icons.notifications_outlined,
              product: 'Red Bull 250ml',
              stock: 18,
              threshold: 20,
              status: 'Sắp hết',
              color: cs.secondary,
            ),
            _AlertCard(
              icon: Icons.notifications_outlined,
              product: 'Oishi Xoài 180g',
              stock: 12,
              threshold: 15,
              status: 'Sắp hết',
              color: cs.secondary,
            ),
            const SizedBox(height: 16),

            // Recent stocktake results
            Text('Kiểm kê gần đây', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),

            _StocktakeResult(
              date: '18/07/2026',
              items: 15,
              diff: 2,
              diffItems: 'Coca (-3), Sting (+1)',
            ),
            _StocktakeResult(
              date: '11/07/2026',
              items: 20,
              diff: 0,
              diffItems: 'Không có chênh lệch',
            ),
            _StocktakeResult(
              date: '04/07/2026',
              items: 12,
              diff: 5,
              diffItems: 'Pepsi (-4), Aquafina (-1)',
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

class _AlertCard extends StatelessWidget {
  final IconData icon;
  final String product;
  final int stock;
  final int threshold;
  final String status;
  final Color color;

  const _AlertCard({
    required this.icon,
    required this.product,
    required this.stock,
    required this.threshold,
    required this.status,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withAlpha(25),
          child: Icon(icon, color: color),
        ),
        title: Text(product, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text('Tồn: $stock / Ngưỡng: $threshold'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: color.withAlpha(25),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(status, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
            ),
            const SizedBox(height: 4),
            Text('Nhập thêm', style: TextStyle(color: color, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

class _StocktakeResult extends StatelessWidget {
  final String date;
  final int items;
  final int diff;
  final String diffItems;

  const _StocktakeResult({
    required this.date,
    required this.items,
    required this.diff,
    required this.diffItems,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 6),
                Text(date, style: TextStyle(color: Colors.grey.shade600)),
                const Spacer(),
                Text('$items mặt hàng', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text('Chênh lệch: ', style: TextStyle(color: Colors.grey.shade700)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: diff == 0 ? Colors.green.withAlpha(25) : cs.error.withAlpha(25),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    diff == 0 ? 'Không có' : '$diff SP',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: diff == 0 ? Colors.green : cs.error,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(diffItems, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
          ],
        ),
      ),
    );
  }
}
