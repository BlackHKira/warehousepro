import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/product_provider.dart';
import '../models/product.dart';
import '../theme/app_theme.dart';

class AdminInventoryScreen extends ConsumerWidget {
  final bool embedded;
  const AdminInventoryScreen({super.key, this.embedded = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productsProvider);
    final body = productsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Lỗi: $e')),
      data: (products) => _InventoryBody(products: products),
    );

    if (embedded) return body;
    return Scaffold(appBar: AppBar(title: const Text('Tồn kho')), body: body);
  }
}

class _InventoryBody extends StatefulWidget {
  final List<Product> products;
  const _InventoryBody({required this.products});

  @override
  State<_InventoryBody> createState() => _InventoryBodyState();
}

class _InventoryBodyState extends State<_InventoryBody> {
  String _search = '';
  String _filterZone = 'Tất cả';
  String _sortBy = 'name';

  List<Product> get _filtered {
    final list = widget.products.where((p) {
      if (_search.isNotEmpty) {
        final q = _search.toLowerCase();
        if (!p.name.toLowerCase().contains(q) && !p.sku.toLowerCase().contains(q)) return false;
      }
      if (_filterZone != 'Tất cả' && p.zone != _filterZone) return false;
      return true;
    }).toList();
    switch (_sortBy) {
      case 'stock': list.sort((a, b) => a.stock.compareTo(b.stock));
      case 'name': list.sort((a, b) => a.name.compareTo(b.name));
      case 'zone': list.sort((a, b) => a.zone.compareTo(b.zone));
    }
    return list;
  }

  List<String> get _zoneList {
    final zones = widget.products.map((p) => p.zone).toSet().toList()..sort();
    return ['Tất cả', ...zones];
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(hintText: 'Tìm kiếm...', prefixIcon: Icon(Icons.search, size: 20), contentPadding: EdgeInsets.symmetric(vertical: 10), isDense: true),
                  onChanged: (v) => setState(() => _search = v),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 100,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(10)),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _filterZone,
                    isDense: true,
                    items: _zoneList.map((z) => DropdownMenuItem(value: z, child: Text(z, style: const TextStyle(fontSize: 13)))).toList(),
                    onChanged: (v) => setState(() => _filterZone = v!),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              PopupMenuButton<String>(
                icon: const Icon(Icons.sort, size: 22),
                onSelected: (v) => setState(() => _sortBy = v),
                itemBuilder: (_) => [
                  PopupMenuItem(value: 'name', child: Text('Tên A-Z', style: TextStyle(fontWeight: _sortBy == 'name' ? FontWeight.bold : FontWeight.normal))),
                  PopupMenuItem(value: 'stock', child: Text('Tồn kho tăng dần', style: TextStyle(fontWeight: _sortBy == 'stock' ? FontWeight.bold : FontWeight.normal))),
                  PopupMenuItem(value: 'zone', child: Text('Theo khu vực', style: TextStyle(fontWeight: _sortBy == 'zone' ? FontWeight.bold : FontWeight.normal))),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Text('${filtered.length} sản phẩm', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              const Spacer(),
              Text('${filtered.fold(0, (s, p) => s + p.stock)} tồn kho', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: filtered.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final p = filtered[i];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: ListTile(
                  leading: Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(color: _zoneColor(p.zone).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                    child: Center(child: Text(p.zone, style: TextStyle(color: _zoneColor(p.zone), fontSize: 12, fontWeight: FontWeight.bold))),
                  ),
                  title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  subtitle: Text('${p.category} · ${p.location}', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(formatStock(p.stock, p.unitPerCase), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: p.isLowStock ? AppColors.red : AppColors.green)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Color _zoneColor(String code) {
    if (code.startsWith('A')) return AppColors.primary;
    if (code.startsWith('B')) return AppColors.green;
    if (code.startsWith('C')) return AppColors.orange;
    return Colors.grey;
  }
}
