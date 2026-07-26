import 'dart:math';
import 'package:flutter/material.dart';
import 'product_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  final bool embedded;
  const SearchScreen({super.key, this.embedded = false});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  bool _showBarcodeSearch = false;

  static const _allProducts = [
    // A1 — Nước ngọt có gas
    ('Coca Cola 355ml', '8934567890001', 84, 'A1-01'),
    ('Pepsi 355ml', '8934567890002', 62, 'A1-01'),
    ('Sting đỏ 330ml', '8934567890003', 41, 'A1-02'),
    ('Number 1 355ml', '8934567890004', 55, 'A1-02'),
    ('7Up 355ml', '8934567890005', 33, 'A1-03'),
    ('Sprite 355ml', '8934567890006', 28, 'A1-03'),
    ('Fanta cam 355ml', '8934567890007', 19, 'A1-04'),
    ('Mirinda Cream Soda 330ml', '8934567890008', 22, 'A1-04'),
    // A2 — Nước lọc, trà, nước tăng lực
    ('Aquafina 500ml', '8934567890009', 96, 'A2-01'),
    ('Trà xanh C2 500ml', '8934567890010', 72, 'A2-01'),
    ('Trà O Long Tea 500ml', '8934567890011', 48, 'A2-02'),
    ('Nước ép cam Twister 350ml', '8934567890012', 35, 'A2-02'),
    ('Lavie 500ml', '8934567890013', 50, 'A2-03'),
    ('Dasani 500ml', '8934567890014', 27, 'A2-03'),
    ('Red Bull 250ml', '8934567890015', 63, 'A2-04'),
    ('Monster 355ml', '8934567890016', 13, 'A2-04'),
    // B1 — Mì, cháo, phở
    ('Mì tôm Hảo Hảo 75g', '8934567890017', 120, 'B1-01'),
    ('Mì tôm Omachi 75g', '8934567890018', 85, 'B1-01'),
    ('Mì ly Miliket 65g', '8934567890019', 60, 'B1-02'),
    ('Cháo gà Vifon 60g', '8934567890020', 44, 'B1-02'),
    ('Phở bò Vifon 65g', '8934567890021', 38, 'B1-03'),
    ('Mì Cung Đình 75g', '8934567890022', 52, 'B1-03'),
    ('Mì tôm Kokomi 80g', '8934567890023', 71, 'B1-04'),
    ('Bún gạo QBB 70g', '8934567890024', 29, 'B1-04'),
    // B2 — Bánh, kẹo, snack, sữa
    ('Bánh Oreo 97g', '8934567890025', 67, 'B2-01'),
    ('Bánh Cosy 120g', '8934567890026', 43, 'B2-01'),
    ('Khoai tây chiên Poca 90g', '8934567890027', 58, 'B2-02'),
    ('Kẹo mút Chupa Chups', '8934567890028', 90, 'B2-02'),
    ('Bánh gạo One One 80g', '8934567890029', 37, 'B2-03'),
    ('Snack Lays 70g', '8934567890030', 46, 'B2-03'),
    ('Sữa đậu nành Fami 200ml', '8934567890031', 75, 'B2-04'),
    ('Sữa Milo hộp 180ml', '8934567890032', 81, 'B2-04'),
    // C1 — Đồ vệ sinh cá nhân
    ('Dầu gội Clear 200ml', '8934567890033', 40, 'C1-01'),
    ('Dầu gội Sunsilk 180ml', '8934567890034', 35, 'C1-01'),
    ('Sữa tắm Lifebuoy 250ml', '8934567890035', 28, 'C1-02'),
    ('Xà phòng Lifebuoy 90g', '8934567890036', 55, 'C1-02'),
    ('Kem đánh răng Colgate 120g', '8934567890037', 48, 'C1-03'),
    ('Lăn khử mùi Rexona 40ml', '8934567890038', 32, 'C1-03'),
    ('Nước súc miệng Listerine 250ml', '8934567890039', 20, 'C1-04'),
    ('Khăn giấy ướt Bobby 100 tờ', '8934567890040', 15, 'C1-04'),
    // C2 — Gia dụng, tẩy rửa
    ('Nước rửa chén Sunlight 750ml', '8934567890041', 64, 'C2-01'),
    ('Nước lau sàn Vim 500ml', '8934567890042', 42, 'C2-01'),
    ('Bột giặt Omo 1kg', '8934567890043', 38, 'C2-02'),
    ('Nước xả Comfort 500ml', '8934567890044', 51, 'C2-02'),
    ('Thuốc tẩy Javel 500ml', '8934567890045', 25, 'C2-03'),
    ('Túi rác 50x60 30c', '8934567890046', 70, 'C2-03'),
    ('Khăn giấy Pulppy 10c', '8934567890047', 33, 'C2-04'),
    ('Bọc nilon 30cm', '8934567890048', 18, 'C2-04'),
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
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.qr_code_scanner, color: Colors.white, size: 56),
                SizedBox(height: 8),
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

    final body = Column(
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
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {});
                            },
                          )
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
              Text(
                '${results.length} kết quả',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
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
                      Icon(
                        Icons.search_off,
                        size: 48,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Không tìm thấy sản phẩm',
                        style: TextStyle(color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: results
                      .map(
                        (p) => _ProductResult(
                          name: p.$1,
                          barcode: p.$2,
                          stock: p.$3,
                          location: p.$4,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ProductDetailScreen(
                                productName: p.$1,
                                barcode: p.$2,
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
        ),
      ],
    );

    if (widget.embedded) return body;

    return Scaffold(
      appBar: AppBar(title: const Text('Tra cứu sản phẩm')),
      body: body,
    );
  }
}

class _ProductResult extends StatelessWidget {
  final String name, barcode, location;
  final int stock;
  final VoidCallback onTap;

  const _ProductResult({
    required this.name,
    required this.barcode,
    required this.stock,
    required this.location,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final stockColor = stock <= 10
        ? Colors.red
        : (stock <= 30 ? Colors.orange : Colors.green);
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.inventory_2_outlined,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Row(
          children: [
            Icon(Icons.qr_code, size: 12, color: Colors.grey.shade500),
            const SizedBox(width: 4),
            Text(
              barcode,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            const SizedBox(width: 12),
            Icon(Icons.location_on, size: 12, color: Colors.grey.shade500),
            const SizedBox(width: 2),
            Text(
              location,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '$stock',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: stockColor,
                fontSize: 16,
              ),
            ),
            Text(
              'tồn',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }
}
