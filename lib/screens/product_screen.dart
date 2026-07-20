import 'package:flutter/material.dart';

class ProductScreen extends StatelessWidget {
  const ProductScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý sản phẩm'),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          IconButton(icon: const Icon(Icons.filter_list), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          // Category chips
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: ['Tất cả', 'Nước ngọt', 'Bia', 'Nước suối', 'Trà', 'Nước tăng lực', 'Sữa']
                  .map((cat) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Chip(
                          label: Text(cat, style: const TextStyle(fontSize: 13)),
                          backgroundColor: cat == 'Tất cả' ? cs.primaryContainer : cs.surface,
                          side: BorderSide.none,
                        ),
                      ))
                  .toList(),
            ),
          ),
          const Divider(height: 1),

          // Product list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 4, bottom: 80),
              itemCount: _products.length,
              itemBuilder: (ctx, i) {
                final p = _products[i];
                final stockColor = p.stock <= 10 ? Colors.red : (p.stock <= 30 ? cs.secondary : Colors.green);
                return Card(
                  child: ListTile(
                    leading: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: cs.primaryContainer,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.inventory_2_outlined, color: cs.onPrimaryContainer),
                    ),
                    title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.w500)),
                    subtitle: Row(
                      children: [
                        Text('Mã: ${p.code}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                        const SizedBox(width: 12),
                        Text('ĐVT: ${p.unit}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                      ],
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('${p.stock}', style: TextStyle(fontWeight: FontWeight.bold, color: stockColor, fontSize: 16)),
                        Text('tồn', style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _Product {
  final String name;
  final String code;
  final String unit;
  final int stock;
  const _Product({required this.name, required this.code, required this.unit, required this.stock});
}

const _products = [
  _Product(name: 'Coca Cola 355ml', code: 'COCA-001', unit: 'Thùng', stock: 84),
  _Product(name: 'Pepsi 355ml', code: 'PEPSI-002', unit: 'Thùng', stock: 62),
  _Product(name: 'Sting đỏ 330ml', code: 'STING-003', unit: 'Thùng', stock: 5),
  _Product(name: 'Number 1 355ml', code: 'NUM1-004', unit: 'Thùng', stock: 41),
  _Product(name: 'Trà xanh C2 500ml', code: 'C2-005', unit: 'Lốc', stock: 120),
  _Product(name: 'Bia Heineken 330ml', code: 'HEINE-006', unit: 'Thùng', stock: 2),
  _Product(name: 'Aquafina 500ml', code: 'AQUA-007', unit: 'Lốc', stock: 96),
  _Product(name: 'Red Bull 250ml', code: 'RB-008', unit: 'Thùng', stock: 18),
  _Product(name: 'Sữa đậu nành Fami', code: 'FAMI-009', unit: 'Thùng', stock: 33),
  _Product(name: 'Oishi Xoài 180g', code: 'OISHI-010', unit: 'Thùng', stock: 12),
];
