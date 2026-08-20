import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/product_provider.dart';
import '../providers/zone_provider.dart' show zonesProvider;
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

  void _showFilterSheet(BuildContext context, String title, List<String> items, String current, ValueChanged<String> onSelect) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.8,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const Spacer(),
                  if (current.isNotEmpty)
                    TextButton(
                      onPressed: () {
                        onSelect('');
                        Navigator.pop(context);
                      },
                      child: const Text('Xoá bộ lọc', style: TextStyle(color: AppColors.red)),
                    ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: items.length,
                itemBuilder: (_, i) {
                  final item = items[i];
                  final isSelected = item == current;
                  return ListTile(
                    leading: Icon(
                      isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                      color: isSelected ? AppColors.primary : AppColors.textMuted,
                    ),
                    title: Text(item, style: TextStyle(fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal)),
                    trailing: isSelected ? const Icon(Icons.check, color: AppColors.primary) : null,
                    onTap: () {
                      onSelect(isSelected ? '' : item);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.trim();
    final productsAsync = ref.watch(productsProvider);
    final products = productsAsync.valueOrNull ?? [];
    final zonesAsync = ref.watch(zonesProvider);
    final zonesList = zonesAsync.valueOrNull?.map((z) => z.code).toList() ?? [];
    zonesList.sort();
    final zones = zonesList;
    final categories = products.map((p) => p.category).where((c) => c.isNotEmpty).toSet().toList()..sort();
    final filtered = products.where((p) {
      if (query.isNotEmpty) {
        if (_showBarcodeSearch) {
          if (!p.barcode.toLowerCase().contains(query.toLowerCase())) return false;
        } else {
          if (!p.name.toLowerCase().contains(query.toLowerCase()) && !p.barcode.contains(query)) return false;
        }
      }
      if (_selectedZone.isNotEmpty && p.getStockInZone(_selectedZone) == 0) return false;
      if (_selectedCategory.isNotEmpty && p.category != _selectedCategory) return false;
      return true;
    }).toList();

    final body = ClipRect(
      child: Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
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
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              ChoiceChip(
                label: Text('Text', style: TextStyle(fontSize: 12, color: !_showBarcodeSearch ? Colors.white : AppColors.textPrimary)),
                selected: !_showBarcodeSearch,
                onSelected: (_) => setState(() => _showBarcodeSearch = false),
                selectedColor: AppColors.primary,
                backgroundColor: const Color(0xFFE8ECF4),
                visualDensity: VisualDensity.compact,
              ),
              ChoiceChip(
                label: Text('Barcode', style: TextStyle(fontSize: 12, color: _showBarcodeSearch ? Colors.white : AppColors.textPrimary)),
                selected: _showBarcodeSearch,
                onSelected: (_) => setState(() => _showBarcodeSearch = true),
                selectedColor: AppColors.primary,
                backgroundColor: const Color(0xFFE8ECF4),
                visualDensity: VisualDensity.compact,
              ),
              Text('${filtered.length} kết quả', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
              ActionChip(
                avatar: Icon(Icons.location_on, size: 16, color: _selectedZone.isNotEmpty ? Colors.white : AppColors.primary),
                label: Text(
                  _selectedZone.isNotEmpty ? 'Khu: $_selectedZone' : 'Khu vực',
                  style: TextStyle(fontSize: 12, color: _selectedZone.isNotEmpty ? Colors.white : AppColors.textPrimary),
                ),
                onPressed: () => _showFilterSheet(context, 'Khu vực', zones, _selectedZone, (v) => setState(() => _selectedZone = v)),
                backgroundColor: _selectedZone.isNotEmpty ? AppColors.primary : const Color(0xFFE8ECF4),
                side: BorderSide.none,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                visualDensity: VisualDensity.compact,
              ),
              ActionChip(
                avatar: Icon(Icons.category_outlined, size: 16, color: _selectedCategory.isNotEmpty ? Colors.white : AppColors.primary),
                label: Text(
                  _selectedCategory.isNotEmpty ? 'Loại: $_selectedCategory' : 'Danh mục',
                  style: TextStyle(fontSize: 12, color: _selectedCategory.isNotEmpty ? Colors.white : AppColors.textPrimary),
                ),
                onPressed: () => _showFilterSheet(context, 'Danh mục', categories, _selectedCategory, (v) => setState(() => _selectedCategory = v)),
                backgroundColor: _selectedCategory.isNotEmpty ? AppColors.primary : const Color(0xFFE8ECF4),
                side: BorderSide.none,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                visualDensity: VisualDensity.compact,
              ),
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
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: p.imageUrl.isNotEmpty
                            ? Image.network(p.imageUrl, width: 44, height: 44, fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => Container(
                                  width: 44, height: 44,
                                  color: AppColors.primary.withValues(alpha: 0.1),
                                  child: const Icon(Icons.inventory_2_outlined, color: AppColors.primary),
                                ))
                            : Container(
                                width: 44, height: 44,
                                color: AppColors.primary.withValues(alpha: 0.1),
                                child: const Icon(Icons.inventory_2_outlined, color: AppColors.primary),
                              ),
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
                          Text(_selectedZone.isNotEmpty ? _selectedZone : p.stockByZone.keys.where((z) => (p.stockByZone[z] ?? 0) > 0).join(', '), style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        ],
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(formatStock(_selectedZone.isNotEmpty ? p.getStockInZone(_selectedZone) : p.stock, p.unitPerCase, p.unit), style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.green, fontSize: 16)),
                        ],
                      ),
                    ),
                  )).toList(),
                ),
        ),
      ],
      ),
    );

    if (widget.embedded) return body;
    return Scaffold(appBar: AppBar(title: const Text('Tra cứu sản phẩm')), body: body);
  }
}
