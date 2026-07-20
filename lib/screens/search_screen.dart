import 'dart:math';
import 'package:flutter/material.dart';
import 'product_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  bool _showBarcodeSearch = false;

  static const _allProducts = [
    ('Coca Cola 355ml', '8934567890123', 84, 'A1-01'),
    ('Pepsi 355ml', '8934567890456', 62, 'A1-02'),
    ('Sting đỏ 330ml', '8934567890789', 5, 'B1-03'),
    ('Aquafina 500ml', '8934567890111', 96, 'C2-01'),
    ('Number 1 355ml', '8934567890222', 41, 'A2-01'),
    ('Bia Tiger 330ml', '8934567890333', 28, 'B2-01'),
    ('Red Bull 250ml', '8934567890444', 55, 'C1-02'),
    ('Trà xanh C2 500ml', '8934567890555', 72, 'A1-03'),
    ('Monster 355ml', '8934567890666', 13, 'B1-01'),
    ('Sữa đậu nành Fami', '8934567890777', 33, 'C2-02'),
  ];

  List<(String, String, int, String)> get _filteredProducts {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return _allProducts;
    return _allProducts.where((p) {
      if (_showBarcodeSearch) {
        return p.$2.toLowerCase().contains(query);
      }
      return p.$1.toLowerCase().contains(query) || p.$2.contains(query);
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _scanBarcode() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Quét mã vạch'),
        content: Container(
          height: 180,
          decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(12)),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.qr_code_scanner, color: Colors.white, size: 56),
                SizedBox(height: 8),
                Text('Đưa mã vạch vào khung hình', style: TextStyle(color: Colors.white70)),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Huỷ')),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              final rng = Random();
              final product = _allProducts[rng.nextInt(_allProducts.length)];
              _searchController.text = product.$2;
              setState(() => _showBarcodeSearch = true);
            },
            child: const Text('Giả lập quét'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final results = _filteredProducts;

    return Scaffold(
      appBar: AppBar(title: const Text('Tra cứu sản phẩm')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Tìm theo tên hoặc mã sản phẩm...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(icon: const Icon(Icons.clear), onPressed: () { _searchController.clear(); setState(() {}); })
                          : null,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: IconButton(
                    icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
                    onPressed: _scanBarcode,
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                ChoiceChip(
                  label: const Text('Tìm bằng text'),
                  selected: !_showBarcodeSearch,
                  onSelected: (_) => setState(() => _showBarcodeSearch = false),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Tìm bằng Barcode'),
                  selected: _showBarcodeSearch,
                  onSelected: (_) => setState(() => _showBarcodeSearch = true),
                ),
                const Spacer(),
                Text('${results.length} kết quả', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
              ],
            ),
          ),
          const SizedBox(height: 8),

          Expanded(
            child: results.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.search_off, size: 48, color: Colors.grey.shade400),
                        const SizedBox(height: 8),
                        Text('Không tìm thấy sản phẩm', style: TextStyle(color: Colors.grey.shade500)),
                      ],
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: results.map((p) => _ProductResult(
                      name: p.$1,
                      barcode: p.$2,
                      stock: p.$3,
                      location: p.$4,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailScreen(productName: p.$1, barcode: p.$2))),
                    )).toList(),
                  ),
          ),
        ],
      ),
    );
  }
}

class _ProductResult extends StatelessWidget {
  final String name, barcode, location;
  final int stock;
  final VoidCallback onTap;

  const _ProductResult({required this.name, required this.barcode, required this.stock, required this.location, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final stockColor = stock <= 10 ? Colors.red : (stock <= 30 ? Colors.orange : Colors.green);
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 44, height: 44,
          decoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer, borderRadius: BorderRadius.circular(10)),
          child: Icon(Icons.inventory_2_outlined, color: Theme.of(context).colorScheme.onPrimaryContainer),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Row(
          children: [
            Icon(Icons.qr_code, size: 12, color: Colors.grey.shade500),
            const SizedBox(width: 4),
            Text(barcode, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
            const SizedBox(width: 12),
            Icon(Icons.location_on, size: 12, color: Colors.grey.shade500),
            const SizedBox(width: 2),
            Text(location, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('$stock', style: TextStyle(fontWeight: FontWeight.bold, color: stockColor, fontSize: 16)),
            Text('tồn', style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
          ],
        ),
      ),
    );
  }
}
