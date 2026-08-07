import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/product_provider.dart';
import '../models/product.dart';
import '../theme/app_theme.dart';
import '../widgets/web_table.dart';

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

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 800;
        if (!isWide) return _mobile(filtered);
        return _web(filtered);
      },
    );
  }

  Widget _mobile(List<Product> filtered) {
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
              Text('${filtered.fold(0, (s, p) => s + p.stock)} sản phẩm', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
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
                  subtitle: Text('${p.category} · ${p.zone}', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(formatStock(p.stock, p.unitPerCase, p.unit), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: p.isLowStock ? AppColors.red : AppColors.green)),
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

  Widget _web(List<Product> filtered) {
    final total = filtered.fold(0, (s, p) => s + p.stock);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(
                width: 260,
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Tìm sản phẩm...',
                    prefixIcon: Icon(Icons.search, size: 20),
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                  ),
                  onChanged: (v) => setState(() => _search = v),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _filterZone,
                    style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                    items: _zoneList.map((z) => DropdownMenuItem(value: z, child: Text(z))).toList(),
                    onChanged: (v) => setState(() => _filterZone = v!),
                  ),
                ),
              ),
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
          const SizedBox(height: 8),
          Text(
            '${filtered.length} sản phẩm · Tổng: $total sản phẩm',
            style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
          ),
          const SizedBox(height: 8),
          WebTable(
            minWidth: 900,
            headers: const ['Sản phẩm', 'Khu vực', 'Đơn vị', 'Tồn kho', 'Trạng thái'],
            rows: [
              for (final p in filtered)
                [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                      if (p.sku.isNotEmpty)
                        Text(p.sku, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                    ],
                  ),
                  _ZoneChip(code: p.zone, color: _zoneColor(p.zone)),
                  Text(p.unit, style: const TextStyle(color: AppColors.textSecondary)),
                  Text(
                    formatStockDetail(p.stock, p.unitPerCase, p.unit),
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: p.isLowStock ? AppColors.red : AppColors.green,
                    ),
                  ),
                  _StatusChip(low: p.isLowStock, out: p.isOutOfStock),
                ],
            ],
            cellAligns: const [null, null, null, TextAlign.right, null],
          ),
        ],
      ),
    );
  }

  Color _zoneColor(String code) {
    if (code.startsWith('A')) return AppColors.primary;
    if (code.startsWith('B')) return AppColors.green;
    if (code.startsWith('C')) return AppColors.orange;
    return Colors.grey;
  }
}

class _ZoneChip extends StatelessWidget {
  final String code;
  final Color color;
  const _ZoneChip({required this.code, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        code,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final bool low;
  final bool out;
  const _StatusChip({required this.low, required this.out});

  @override
  Widget build(BuildContext context) {
    final Color color;
    final String label;
    if (out) {
      color = AppColors.red;
      label = 'Hết hàng';
    } else if (low) {
      color = AppColors.orange;
      label = 'Tồn thấp';
    } else {
      color = AppColors.green;
      label = 'Còn hàng';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color),
      ),
    );
  }
}
