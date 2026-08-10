import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/product_provider.dart';
import '../providers/zone_provider.dart';
import '../models/zone.dart';
import '../theme/app_theme.dart';
import '../widgets/web_table.dart';
import 'admin_zone_detail_screen.dart';

class AdminZonesScreen extends ConsumerWidget {
  final bool embedded;
  const AdminZonesScreen({super.key, this.embedded = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final zonesAsync = ref.watch(zonesProvider);
    final productsAsync = ref.watch(productsProvider);

    final body = zonesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Lỗi: $e', style: const TextStyle(color: AppColors.red))),
      data: (zones) {
        final products = productsAsync.valueOrNull ?? [];
        return _ZonesGrid(
          zones: zones,
          products: products,
          onAdd: () => _showAddZoneDialog(context, ref, zones),
          onEdit: (z) => _showEditZoneDialog(context, ref, z),
          onDelete: (z) {
            final count = products.where((p) => (p.zone as String?) == z.code).length;
            _showDeleteConfirm(context, ref, z, count);
          },
        );
      },
    );

    return Scaffold(
      appBar: embedded ? null : AppBar(title: const Text('Khu vực kho')),
      body: body,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddZoneDialog(context, ref, null),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddZoneDialog(BuildContext context, WidgetRef ref, List<Zone>? existingZones) {
    final codeCtrl = TextEditingController();
    final labelCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final sortCtrl = TextEditingController(text: '${(existingZones?.length ?? 0) + 1}');
    final existingCodes = existingZones?.map((z) => z.code).toSet() ?? {};

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Thêm khu vực'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: codeCtrl,
                decoration: const InputDecoration(labelText: 'Mã khu vực', border: OutlineInputBorder(), hintText: 'VD: D1, KhoLạnh'),
                textCapitalization: TextCapitalization.characters,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: labelCtrl,
                decoration: const InputDecoration(labelText: 'Tên khu vực', border: OutlineInputBorder(), hintText: 'VD: Khu D1 - Kho đông lạnh'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descCtrl,
                decoration: const InputDecoration(labelText: 'Mô tả (không bắt buộc)', border: OutlineInputBorder()),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: sortCtrl,
                decoration: const InputDecoration(labelText: 'Thứ tự', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Huỷ')),
          FilledButton(
            onPressed: () async {
              final code = codeCtrl.text.trim().toUpperCase();
              final label = labelCtrl.text.trim();
              if (code.isEmpty || label.isEmpty) {
                ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Vui lòng nhập mã và tên'), behavior: SnackBarBehavior.floating));
                return;
              }
              if (existingCodes.contains(code)) {
                ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Mã khu vực đã tồn tại'), behavior: SnackBarBehavior.floating));
                return;
              }
              final sortOrder = int.tryParse(sortCtrl.text.trim()) ?? 0;
              await ref.read(zoneServiceProvider).addZone(Zone(
                id: '',
                code: code,
                label: label,
                description: descCtrl.text.trim(),
                sortOrder: sortOrder,
              ));
              if (ctx.mounted) Navigator.pop(ctx);
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Đã thêm khu vực $code'), behavior: SnackBarBehavior.floating));
            },
            child: const Text('Thêm'),
          ),
        ],
      ),
    );
  }

  void _showEditZoneDialog(BuildContext context, WidgetRef ref, Zone zone) {
    final codeCtrl = TextEditingController(text: zone.code);
    final labelCtrl = TextEditingController(text: zone.label);
    final descCtrl = TextEditingController(text: zone.description);
    final sortCtrl = TextEditingController(text: '${zone.sortOrder}');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sửa khu vực'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: codeCtrl,
                decoration: const InputDecoration(labelText: 'Mã khu vực', border: OutlineInputBorder()),
                textCapitalization: TextCapitalization.characters,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: labelCtrl,
                decoration: const InputDecoration(labelText: 'Tên khu vực', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descCtrl,
                decoration: const InputDecoration(labelText: 'Mô tả', border: OutlineInputBorder()),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: sortCtrl,
                decoration: const InputDecoration(labelText: 'Thứ tự', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Huỷ')),
          FilledButton(
            onPressed: () async {
              final code = codeCtrl.text.trim().toUpperCase();
              final label = labelCtrl.text.trim();
              if (code.isEmpty || label.isEmpty) {
                ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Vui lòng nhập mã và tên'), behavior: SnackBarBehavior.floating));
                return;
              }
              final sortOrder = int.tryParse(sortCtrl.text.trim()) ?? 0;
              await ref.read(zoneServiceProvider).updateZone(zone.id, {
                'code': code,
                'label': label,
                'description': descCtrl.text.trim(),
                'sortOrder': sortOrder,
              });
              if (ctx.mounted) Navigator.pop(ctx);
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Đã cập nhật khu vực $code'), behavior: SnackBarBehavior.floating));
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirm(BuildContext context, WidgetRef ref, Zone zone, int productCount) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa khu vực'),
        content: productCount > 0
            ? Text('Khu vực ${zone.code} đang có $productCount sản phẩm. Xóa sẽ không ảnh hưởng đến sản phẩm. Tiếp tục?')
            : Text('Xóa khu vực ${zone.code}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Huỷ')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.red),
            onPressed: () async {
              await ref.read(zoneServiceProvider).deleteZone(zone.id);
              if (ctx.mounted) Navigator.pop(ctx);
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Đã xóa khu vực ${zone.code}'), behavior: SnackBarBehavior.floating));
            },
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }
}

class _ZonesGrid extends StatefulWidget {
  final List<Zone> zones;
  final List products;
  final VoidCallback? onAdd;
  final void Function(Zone)? onEdit;
  final void Function(Zone)? onDelete;

  const _ZonesGrid({
    required this.zones,
    required this.products,
    this.onAdd,
    this.onEdit,
    this.onDelete,
  });

  @override
  State<_ZonesGrid> createState() => _ZonesGridState();
}

class _ZonesGridState extends State<_ZonesGrid> {
  String _search = '';

  Map<String, int> get _productCounts {
    final counts = <String, int>{};
    for (final p in widget.products) {
      final zone = (p.zone as String?) ?? '';
      counts[zone] = (counts[zone] ?? 0) + 1;
    }
    return counts;
  }

  List<Zone> get _filtered {
    final q = _search.trim().toLowerCase();
    if (q.isEmpty) return widget.zones;
    return widget.zones.where((z) =>
        z.code.toLowerCase().contains(q) ||
        z.label.toLowerCase().contains(q) ||
        z.description.toLowerCase().contains(q)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final counts = _productCounts;

    if (widget.zones.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.map_outlined, size: 64, color: AppColors.textMuted),
            const SizedBox(height: 12),
            Text('Chưa có khu vực nào', style: TextStyle(color: AppColors.textMuted, fontSize: 16)),
            const SizedBox(height: 4),
            Text('Bấm "+" để thêm khu vực mới', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 800) return _web(counts);
        return _mobile(counts);
      },
    );
  }

  Widget _mobile(Map<String, int> counts) {
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final rows = (widget.zones.length / 2).ceil();
                const spacing = 10.0;
                final availH = constraints.maxHeight - (rows - 1) * spacing;
                final rowH = availH / rows;
                final cellW = (constraints.maxWidth - spacing) / 2;
                final ratio = cellW / rowH;

                return GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: ratio,
                    crossAxisSpacing: spacing,
                    mainAxisSpacing: spacing,
                  ),
                  itemCount: widget.zones.length,
                  itemBuilder: (_, i) {
                    final z = widget.zones[i];
                    final productCount = counts[z.code] ?? 0;

                    return Card(
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AdminZoneDetailScreen(zone: z))),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: _zoneColor(z.code).withValues(alpha: 0.3)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 32, height: 32,
                                    decoration: BoxDecoration(color: _zoneColor(z.code).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                                    child: Center(child: Text(z.code, style: TextStyle(color: _zoneColor(z.code), fontSize: 12, fontWeight: FontWeight.bold))),
                                  ),
                                  const Spacer(),
                                  Text('$productCount SP', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                                  if (widget.onEdit != null || widget.onDelete != null) ...[
                                    const SizedBox(width: 4),
                                    PopupMenuButton<String>(
                                      padding: EdgeInsets.zero,
                                      iconSize: 18,
                                      icon: Icon(Icons.more_vert, size: 16, color: AppColors.textMuted),
                                      onSelected: (v) {
                                        if (v == 'edit') widget.onEdit?.call(z);
                                        if (v == 'delete') widget.onDelete?.call(z);
                                      },
                                      itemBuilder: (_) => [
                                        const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, size: 16), SizedBox(width: 8), Text('Sửa')])),
                                        const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, size: 16, color: AppColors.red), SizedBox(width: 8), Text('Xóa', style: TextStyle(color: AppColors.red))])),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(z.label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                              if (z.description.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(z.description, style: const TextStyle(color: AppColors.textMuted, fontSize: 10), maxLines: 2, overflow: TextOverflow.ellipsis),
                              ],
                              const Spacer(),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Icon(Icons.arrow_forward_ios, size: 10, color: AppColors.textMuted),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(8)),
            child: Row(
              children: [
                const Icon(Icons.info_outline, size: 16, color: AppColors.primary),
                const SizedBox(width: 8),
                Text('Tổng cộng ${widget.zones.length} khu vực · ${widget.products.length} sản phẩm', style: TextStyle(color: AppColors.primary, fontSize: 12)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _web(Map<String, int> counts) {
    final filtered = _filtered;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(22),
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
                    hintText: 'Tìm khu vực...',
                    prefixIcon: Icon(Icons.search, size: 20),
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                  ),
                  onChanged: (v) => setState(() => _search = v),
                ),
              ),
              FilledButton.icon(
                onPressed: widget.onAdd,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Thêm khu vực'),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            '${filtered.length} khu vực · ${widget.products.length} sản phẩm',
            style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
          ),
          const SizedBox(height: 10),
          WebTable(
            minWidth: 800,
            headers: const ['Mã', 'Tên khu vực', 'Số sản phẩm', 'Thứ tự', 'Thao tác'],
            rows: [
              for (final z in filtered)
                [
                  _ZoneCodeChip(code: z.code, color: _zoneColor(z.code)),
                  InkWell(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AdminZoneDetailScreen(zone: z))),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(z.label, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.primary)),
                        if (z.description.isNotEmpty)
                          Text(z.description, style: const TextStyle(fontSize: 11, color: AppColors.textMuted), maxLines: 2, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                  Text(
                    '${counts[z.code] ?? 0}',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: (counts[z.code] ?? 0) > 0 ? AppColors.primary : AppColors.textMuted,
                    ),
                  ),
                  Text('${z.sortOrder}', style: const TextStyle(color: AppColors.textSecondary)),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        tooltip: 'Sửa',
                        icon: const Icon(Icons.edit, size: 18, color: AppColors.textSecondary),
                        onPressed: widget.onEdit == null ? null : () => widget.onEdit!(z),
                      ),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        tooltip: 'Xóa',
                        icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.red),
                        onPressed: widget.onDelete == null ? null : () => widget.onDelete!(z),
                      ),
                    ],
                  ),
                ],
            ],
            cellAligns: const [null, null, TextAlign.right, null, null],
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

class _ZoneCodeChip extends StatelessWidget {
  final String code;
  final Color color;
  const _ZoneCodeChip({required this.code, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(code, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color)),
    );
  }
}
