import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/product_provider.dart';
import '../models/zone.dart';
import '../models/product.dart';
import '../theme/app_theme.dart';
import 'product_detail_screen.dart';

class AdminZoneDetailScreen extends ConsumerWidget {
  final Zone zone;
  const AdminZoneDetailScreen({super.key, required this.zone});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productsProvider);
    final products = productsAsync.valueOrNull ?? [];
    final zoneProducts = products.where((p) => p.zone == zone.code).toList();

    return Scaffold(
      appBar: AppBar(title: Text('Khu ${zone.code}')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: _zoneColor(zone.code).withValues(alpha: 0.05),
            child: Row(
              children: [
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(color: _zoneColor(zone.code).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                  child: Center(child: Text(zone.code, style: TextStyle(color: _zoneColor(zone.code), fontSize: 16, fontWeight: FontWeight.bold))),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(zone.label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                      if (zone.description.isNotEmpty)
                        Text(zone.description, style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                      Text('${zoneProducts.length} sản phẩm', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          productsAsync.when(
            loading: () => const Expanded(child: Center(child: CircularProgressIndicator())),
            error: (e, _) => Expanded(child: Center(child: Text('Lỗi: $e'))),
            data: (_) {
              if (zoneProducts.isEmpty) {
                return Expanded(child: Center(child: Text('Khu vực này chưa có sản phẩm', style: TextStyle(color: AppColors.textMuted))));
              }

              return Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: zoneProducts.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 6),
                  itemBuilder: (_, i) {
                    final p = zoneProducts[i];
                    return _ProductCard(product: p, zoneColor: _zoneColor(zone.code));
                  },
                ),
              );
            },
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

class _ProductCard extends StatelessWidget {
  final Product product;
  final Color zoneColor;
  const _ProductCard({required this.product, required this.zoneColor});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailScreen(productId: product.id))),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(color: zoneColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                child: Center(child: Icon(Icons.inventory_2_outlined, color: zoneColor, size: 22)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.qr_code, size: 12, color: AppColors.textMuted),
                        const SizedBox(width: 4),
                        Flexible(child: Text(product.barcode, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary), overflow: TextOverflow.ellipsis)),
                        const SizedBox(width: 10),
                        const Icon(Icons.location_on, size: 12, color: AppColors.textMuted),
                        const SizedBox(width: 2),
                        Flexible(child: Text(product.location, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary), overflow: TextOverflow.ellipsis)),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(formatStock(product.stock, product.unitPerCase), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: product.isLowStock ? AppColors.red : AppColors.green)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
