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
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ProductDetailScreen(productName: 'Coca Cola 355ml', barcode: '8934567890123')));
            },
            child: const Text('Giả lập quét'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tra cứu sản phẩm')),
      body: Column(
        children: [
          // Search bar
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

          // Toggle text / barcode search
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
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Results
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _ProductResult(
                  name: 'Coca Cola 355ml',
                  barcode: '8934567890123',
                  stock: 84,
                  location: 'A1-01',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProductDetailScreen(productName: 'Coca Cola 355ml', barcode: '8934567890123'))),
                ),
                _ProductResult(
                  name: 'Pepsi 355ml',
                  barcode: '8934567890456',
                  stock: 62,
                  location: 'A1-02',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProductDetailScreen(productName: 'Pepsi 355ml', barcode: '8934567890456'))),
                ),
                _ProductResult(
                  name: 'Sting đỏ 330ml',
                  barcode: '8934567890789',
                  stock: 5,
                  location: 'B1-03',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProductDetailScreen(productName: 'Sting đỏ 330ml', barcode: '8934567890789'))),
                ),
                _ProductResult(
                  name: 'Aquafina 500ml',
                  barcode: '8934567890111',
                  stock: 96,
                  location: 'C2-01',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProductDetailScreen(productName: 'Aquafina 500ml', barcode: '8934567890111'))),
                ),
                _ProductResult(
                  name: 'Number 1 355ml',
                  barcode: '8934567890222',
                  stock: 41,
                  location: 'A2-01',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProductDetailScreen(productName: 'Number 1 355ml', barcode: '8934567890222'))),
                ),
              ],
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
