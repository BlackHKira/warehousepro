import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/product_provider.dart';
import '../theme/app_theme.dart';
import 'product_detail_screen.dart';

class SearchScreen extends ConsumerStatefulWidget {
  final bool embedded;
  const SearchScreen({super.key, this.embedded = false});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();
  bool _showBarcodeSearch = false;

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

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.trim();
    final productsAsync = ref.watch(productsProvider);
    final products = productsAsync.valueOrNull ?? [];
    final filtered = query.isEmpty
        ? products
        : products.where((p) {
            if (_showBarcodeSearch) return p.barcode.toLowerCase().contains(query.toLowerCase());
            return p.name.toLowerCase().contains(query.toLowerCase()) || p.barcode.contains(query);
          }).toList();

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
                    suffixIcon: _searchController.text.isNotEmpty ? IconButton(icon: const Icon(Icons.clear), onPressed: () { _searchController.clear(); setState(() {}); }) : null,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              CircleAvatar(
                backgroundColor: AppColors.primary,
                child: IconButton(
                  icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
                  onPressed: () {
                    // TODO: implement real barcode scan
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Quét barcode — đang phát triển'), behavior: SnackBarBehavior.floating),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              ChoiceChip(label: const Text('Tìm bằng text'), selected: !_showBarcodeSearch, onSelected: (_) => setState(() => _showBarcodeSearch = false)),
              const SizedBox(width: 8),
              ChoiceChip(label: const Text('Tìm bằng Barcode'), selected: _showBarcodeSearch, onSelected: (_) => setState(() => _showBarcodeSearch = true)),
              const Spacer(),
              Text('${filtered.length} kết quả', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: filtered.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.search_off, size: 48, color: AppColors.textMuted),
                      const SizedBox(height: 8),
                      Text('Không tìm thấy sản phẩm', style: TextStyle(color: AppColors.textMuted)),
                    ],
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: filtered.map((p) => Card(
                    child: ListTile(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailScreen(productId: p.id))),
                      leading: Container(
                        width: 44, height: 44,
                        decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                        child: const Icon(Icons.inventory_2_outlined, color: AppColors.primary),
                      ),
                      title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.w500)),
                      subtitle: Row(
                        children: [
                          const Icon(Icons.qr_code, size: 12, color: AppColors.textMuted),
                          const SizedBox(width: 4),
                          Text(p.barcode, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                          const SizedBox(width: 12),
                          const Icon(Icons.location_on, size: 12, color: AppColors.textMuted),
                          const SizedBox(width: 2),
                          Text(p.location, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        ],
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('${p.stock}', style: TextStyle(fontWeight: FontWeight.bold, color: p.isLowStock ? AppColors.red : AppColors.green, fontSize: 16)),
                          const Text('tồn', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                        ],
                      ),
                    ),
                  )).toList(),
                ),
        ),
      ],
    );

    if (widget.embedded) return body;
    return Scaffold(appBar: AppBar(title: const Text('Tra cứu sản phẩm')), body: body);
  }
}
