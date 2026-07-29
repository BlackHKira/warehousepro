import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/product_provider.dart';
import '../providers/warehouse_provider.dart' show warehouseProvider;
import '../theme/app_theme.dart';

class ProductDetailScreen extends ConsumerWidget {
  final String productId;
  const ProductDetailScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productAsync = ref.watch(productByIdProvider(productId));
    final product = productAsync.valueOrNull;
    final warehouse = ref.watch(warehouseProvider);

    if (productAsync.isLoading) {
      return Scaffold(appBar: AppBar(title: const Text('Chi tiết')), body: const Center(child: CircularProgressIndicator()));
    }

    if (product == null) {
      return Scaffold(appBar: AppBar(title: const Text('Chi tiết')), body: const Center(child: Text('Không tìm thấy sản phẩm')));
    }

    final available = product.stock > 0 ? product.stock - (product.stock ~/ 10) : 0;
    final discrepancy = product.stock - product.serverStock;

    final allTxns = [...warehouse.recentImports, ...warehouse.recentExports];
    final relatedTxns = allTxns.where((t) {
      final products = t['products'] as List<dynamic>? ?? [];
      return products.any((p) {
        if (p is Map<String, dynamic>) {
          return p['barcode'] == product.barcode || p['name'] == product.name;
        }
        return false;
      });
    }).toList();

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
                  if (product.sku.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text('SKU: ${product.sku}', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                  ],
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _stockChip(label: 'Tồn kho', value: '${product.stockInCases} thùng', bgColor: AppColors.primaryLight, textColor: AppColors.primary),
                      _stockChip(label: 'Khả dụng', value: '$available', bgColor: AppColors.successLight, textColor: AppColors.successDark),
                      _stockChip(label: 'Chênh lệch', value: discrepancy >= 0 ? '+$discrepancy' : '$discrepancy', bgColor: AppColors.errorLight, textColor: AppColors.error),
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
          _infoRow(label: 'Quy đổi', value: '1 thùng = ${product.unitPerCase} ${product.unit}'),
          _infoRow(label: 'Tồn kho', value: formatStockDetail(product.stock, product.unitPerCase)),
          _infoRow(label: 'Giá nhập', value: '${product.unitPricePerCase.toStringAsFixed(0)}đ/thùng'),
          _infoRow(label: 'Giá bán', value: '${product.exportPricePerCase.toStringAsFixed(0)}đ/thùng'),
          _infoRow(label: 'Ngưỡng tồn', value: formatStockDetail(product.minStock, product.unitPerCase)),
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
                  Expanded(child: Text('Sản phẩm sắp hết hàng (tồn ${formatStockDetail(product.stock, product.unitPerCase)}, ngưỡng ${formatStockDetail(product.minStock, product.unitPerCase)})', style: const TextStyle(color: AppColors.orange, fontSize: 13))),
                ],
              ),
            ),
          const SizedBox(height: 16),

          // Transaction history
          Text('Lịch sử giao dịch', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          if (relatedTxns.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Text('Chưa có giao dịch nào', style: TextStyle(color: AppColors.textMuted)),
                ),
              ),
            )
          else
            ...relatedTxns.take(10).map((t) {
              final isImport = t['type'] == 'import';
              final qty = t['items'] ?? 0;
              final label = isImport ? t['supplier'] ?? 'Nhà cung cấp' : t['customer'] ?? 'Khách hàng';
              return Card(
                child: ListTile(
                  dense: true,
                  leading: CircleAvatar(
                    radius: 16,
                    backgroundColor: (isImport ? AppColors.green : AppColors.red).withValues(alpha: 0.1),
                    child: Icon(isImport ? Icons.arrow_downward : Icons.arrow_upward, color: isImport ? AppColors.green : AppColors.red, size: 18),
                  ),
                  title: Text('${isImport ? "Nhập kho" : "Xuất kho"} — $label', style: const TextStyle(fontSize: 13)),
                  trailing: Text('${isImport ? "+" : "-"}$qty', style: TextStyle(fontWeight: FontWeight.bold, color: isImport ? AppColors.green : AppColors.red)),
                ),
              );
            }),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _stockChip({required String label, required String value, required Color bgColor, required Color textColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: textColor)),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 12, color: textColor.withValues(alpha: 0.8))),
        ],
      ),
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