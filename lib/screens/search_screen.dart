import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/product_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/barcode_scanner_screen.dart';
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
  String _selectedZone = '';
  String _selectedCategory = '';

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

  void _showScanDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Quét mã vạch'),
        content: Container(
          height: 200,
          decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(12)),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.qr_code_scanner, color: Colors.white, size: 64),
                SizedBox(height: 12),
                Text('Đưa mã vạch vào khung hình', style: TextStyle(color: Colors.white70)),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Huỷ')),
          FilledButton.icon(
            icon: const Icon(Icons.qr_code_scanner, size: 18),
            onPressed: () async {
              Navigator.pop(ctx);
              final barcode = await Navigator.push<String>(context, MaterialPageRoute(builder: (_) => const BarcodeScannerScreen()));
              if (barcode == null || !mounted) return;
              final product = await ref.read(productByBarcodeProvider(barcode).future);
              if (!mounted) return;
              if (product != null) {
                Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailScreen(productId: product.id)));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Không tìm thấy sản phẩm với mã: $barcode'), behavior: SnackBarBehavior.floating, backgroundColor: AppColors.red),
                );
              }
            },
            label: const Text('Quét camera'),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            icon: const Icon(Icons.shuffle, size: 18),
            onPressed: () {
              Navigator.pop(ctx);
              final rng = Random();
              final products = ref.read(productsProvider).valueOrNull ?? [];
              if (products.isEmpty || !mounted) return;
              final product = products[rng.nextInt(products.length)];
              Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailScreen(productId: product.id)));
            },
            label: const Text('Giả lập quét'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.trim();
    final productsAsync = ref.watch(productsProvider);
    final products = productsAsync.valueOrNull ?? [];
    final zones = products.map((p) => p.zone).where((z) => z.isNotEmpty).toSet().toList()..sort();
    final categories = products.map((p) => p.category).where((c) => c.isNotEmpty).toSet().toList()..sort();
    final filtered = products.where((p) {
      if (query.isNotEmpty) {
        if (_showBarcodeSearch) {
          if (!p.barcode.toLowerCase().contains(query.toLowerCase())) return false;
        } else {
          if (!p.name.toLowerCase().contains(query.toLowerCase()) && !p.barcode.contains(query)) return false;
        }
      }
      if (_selectedZone.isNotEmpty && p.zone != _selectedZone) return false;
      if (_selectedCategory.isNotEmpty && p.category != _selectedCategory) return false;
      return true;
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
                    hintText: _showBarcodeSearch ? 'Nhập mã barcode...' : 'Tìm theo tên sản phẩm...',
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
                  onPressed: () => _showScanDialog(),
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
                label: Text('Text', style: TextStyle(fontSize: 13, color: !_showBarcodeSearch ? Colors.white : AppColors.textPrimary)),
                selected: !_showBarcodeSearch,
                onSelected: (_) => setState(() => _showBarcodeSearch = false),
                selectedColor: AppColors.primary,
                backgroundColor: const Color(0xFFE8ECF4),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: Text('Barcode', style: TextStyle(fontSize: 13, color: _showBarcodeSearch ? Colors.white : AppColors.textPrimary)),
                selected: _showBarcodeSearch,
                onSelected: (_) => setState(() => _showBarcodeSearch = true),
                selectedColor: AppColors.primary,
                backgroundColor: const Color(0xFFE8ECF4),
              ),
              const Spacer(),
              Text('${filtered.length} kết quả', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                if (zones.isNotEmpty) ...[
                  ChoiceChip(
                    label: Text('Khu vực', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    selected: false,
                    onSelected: (_) {},
                    selectedColor: AppColors.primary.withValues(alpha: 0.3),
                    disabledColor: const Color(0xFFE8ECF4),
                    backgroundColor: const Color(0xFFE8ECF4),
                  ),
                  const SizedBox(width: 4),
                  ...zones.map((z) => Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: FilterChip(
                      label: Text(z, style: TextStyle(fontSize: 12, color: _selectedZone == z ? Colors.white : AppColors.textPrimary)),
                      selected: _selectedZone == z,
                      onSelected: (v) => setState(() => _selectedZone = v ? z : ''),
                      selectedColor: AppColors.primary,
                      backgroundColor: const Color(0xFFE8ECF4),
                    ),
                  )),
                  const SizedBox(width: 12),
                ],
                if (categories.isNotEmpty) ...[
                  ChoiceChip(
                    label: Text('Danh mục', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    selected: false,
                    onSelected: (_) {},
                    selectedColor: AppColors.primary.withValues(alpha: 0.3),
                    disabledColor: const Color(0xFFE8ECF4),
                    backgroundColor: const Color(0xFFE8ECF4),
                  ),
                  const SizedBox(width: 4),
                  ...categories.map((c) => Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: FilterChip(
                      label: Text(c, style: TextStyle(fontSize: 12, color: _selectedCategory == c ? Colors.white : AppColors.textPrimary)),
                      selected: _selectedCategory == c,
                      onSelected: (v) => setState(() => _selectedCategory = v ? c : ''),
                      selectedColor: AppColors.primary,
                      backgroundColor: const Color(0xFFE8ECF4),
                    ),
                  )),
                ],
              ],
            ),
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
                          Text(formatStock(p.stock, p.unitPerCase), style: TextStyle(fontWeight: FontWeight.bold, color: p.isLowStock ? AppColors.red : AppColors.green, fontSize: 16)),
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
