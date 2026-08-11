import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/warehouse_provider.dart';
import '../theme/app_theme.dart';

class DeliveryScreen extends ConsumerWidget {
  final bool embedded;
  const DeliveryScreen({super.key, this.embedded = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final warehouse = ref.watch(warehouseProvider);
    final pendingExports = warehouse.recentExports
        .where((e) => e['status'] == 'pending')
        .toList()
      ..sort((a, b) {
        final tA = a['createdAt'] as String? ?? '';
        final tB = b['createdAt'] as String? ?? '';
        return tB.compareTo(tA);
      });

    final body = pendingExports.isEmpty
        ? Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.local_shipping_outlined, size: 64, color: AppColors.textMuted.withValues(alpha: 0.4)),
                const SizedBox(height: 12),
                Text(
                  'Không có phiếu chờ giao',
                  style: TextStyle(fontSize: 16, color: AppColors.textMuted),
                ),
                const SizedBox(height: 4),
                Text(
                  'Phiếu xuất kho ở trạng thái "Chờ xử lý" sẽ hiển thị ở đây',
                  style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        : ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: pendingExports.length,
            separatorBuilder: (_, a) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final data = pendingExports[index];
              final customer = (data['customer'] as String?)?.isNotEmpty == true
                  ? data['customer']
                  : 'Khách lẻ';
              final zone = data['zone'] as String? ?? 'N/A';
              final items = data['items'] ?? 0;
              final note = (data['note'] as String?)?.isNotEmpty == true
                  ? data['note']
                  : '';
              final timeStr = data['createdAt'] as String? ?? '';

              return Card(
                margin: EdgeInsets.zero,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => _showDetailBottomSheet(context, ref, data),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.orange.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.local_shipping_outlined, color: AppColors.orange),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '$customer — Khu $zone',
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '$items sản phẩm${note.isNotEmpty ? ' · $note' : ''}',
                                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                              ),
                              if (timeStr.isNotEmpty)
                                Text(
                                  timeStr,
                                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                ),
                            ],
                          ),
                        ),
                        Icon(Icons.chevron_right, color: AppColors.textMuted),
                      ],
                    ),
                  ),
                ),
              );
            },
          );

    if (embedded) return body;
    return Scaffold(
      appBar: AppBar(title: const Text('Giao hàng')),
      body: body,
    );
  }

  void _showDetailBottomSheet(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> data,
  ) {
    final products = (data['products'] as List<dynamic>?) ?? [];
    final customer = (data['customer'] as String?)?.isNotEmpty == true
        ? data['customer']!
        : 'Khách lẻ';
    final zone = data['zone'] as String? ?? 'N/A';
    final items = data['items'] ?? 0;
    final note = (data['note'] as String?)?.isNotEmpty == true
        ? data['note']!
        : '';
    final timeStr = data['createdAt'] as String? ?? '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.55,
        minChildSize: 0.3,
        maxChildSize: 0.85,
        expand: false,
        builder: (ctx, scrollController) => Padding(
          padding: const EdgeInsets.all(20),
          child: ListView(
            controller: scrollController,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textMuted.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Chi tiết phiếu giao',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _detailRow('Khách hàng', customer),
              _detailRow('Khu vực', 'Khu $zone'),
              _detailRow('Số lượng', '$items sản phẩm'),
              if (note.isNotEmpty) _detailRow('Ghi chú', note),
              _detailRow('Trạng thái', 'Chờ xử lý'),
              if (timeStr.isNotEmpty) _detailRow('Thời gian', timeStr),
              if (products.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text('Sản phẩm', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 8),
                ...products.map((p) {
                  final map = p as Map<String, dynamic>;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        Icon(Icons.inventory_2_outlined, size: 16, color: AppColors.textMuted),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${map['name'] ?? ''} — ${map['quantity'] ?? 0} — Khu ${map['zone'] ?? ''}',
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () async {
                    final nameController = TextEditingController();
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Hoàn thành giao hàng'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('Nhập tên người giao hàng:'),
                            const SizedBox(height: 12),
                            TextField(
                              controller: nameController,
                              decoration: const InputDecoration(
                                labelText: 'Tên người giao',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('Huỷ'),
                          ),
                          FilledButton(
                            onPressed: () {
                              if (nameController.text.trim().isEmpty) return;
                              Navigator.pop(ctx, true);
                            },
                            child: const Text('Hoàn thành'),
                          ),
                        ],
                      ),
                    );
                    if (confirmed == true) {
                      final deliveredByName = nameController.text.trim();
                      await ref
                          .read(warehouseProvider.notifier)
                          .updateExportStatus(data, 'completed', deliveredBy: deliveredByName);
                      if (ctx.mounted) Navigator.pop(ctx);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Đã hoàn thành phiếu xuất'),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: AppColors.green,
                          ),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Hoàn thành giao hàng'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
