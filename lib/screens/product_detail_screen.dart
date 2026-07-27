import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/product_provider.dart';
import '../theme/app_theme.dart';

class ProductDetailScreen extends ConsumerWidget {
  final String productId;
  const ProductDetailScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productAsync = ref.watch(productByIdProvider(productId));
    final product = productAsync.valueOrNull;

    if (productAsync.isLoading) {
      return Scaffold(appBar: AppBar(title: const Text('Chi tiết')), body: const Center(child: CircularProgressIndicator()));
    }

    if (product == null) {
      return Scaffold(appBar: AppBar(title: const Text('Chi tiết')), body: const Center(child: Text('Không tìm thấy sản phẩm')));
    }

    return Scaffold(
      appBar: AppBar(title: Text(product.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Stock info card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    width: 72, height: 72,
                    decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                    child: const Icon(Icons.inventory_2, color: AppColors.primary, size: 40),
                  ),
                  const SizedBox(height: 16),
                  Text(product.name, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.qr_code, size: 14, color: AppColors.textMuted),
                      const SizedBox(width: 4),
                      Text('Mã: ${product.barcode}', style: const TextStyle(color: AppColors.textSecondary)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _stockChip(label: 'Tồn cục bộ', value: '${product.stock}', color: AppColors.green),
                      _stockChip(label: 'Tồn server', value: '${product.serverStock}', color: AppColors.primary),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Info fields
          Text('Thông tin chi tiết', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          _infoRow(label: 'Danh mục', value: product.category),
          _infoRow(label: 'Khu vực', value: product.zone),
          _infoRow(label: 'Vị trí', value: product.location),
          _infoRow(label: 'Đơn vị', value: product.unit),
          _infoRow(label: 'Giá nhập', value: '${product.unitPrice.toStringAsFixed(0)}đ'),
          _infoRow(label: 'Giá bán', value: '${product.exportPrice.toStringAsFixed(0)}đ'),
          _infoRow(label: 'Ngưỡng tồn tối thiểu', value: '${product.minStock}'),
          if (product.note.isNotEmpty) _infoRow(label: 'Ghi chú', value: product.note),
          const SizedBox(height: 16),

          // Low stock warning
          if (product.isLowStock)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.orange.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber, color: AppColors.orange, size: 20),
                  const SizedBox(width: 8),
                  Expanded(child: Text('Sản phẩm sắp hết hàng (tồn ${product.stock}, ngưỡng ${product.minStock})', style: const TextStyle(color: AppColors.orange, fontSize: 13))),
                ],
              ),
            ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _stockChip({required String label, required String value, required Color color}) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28, color: color)),
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _infoRow({required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(width: 140, child: Text(label, style: const TextStyle(color: AppColors.textSecondary))),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}
