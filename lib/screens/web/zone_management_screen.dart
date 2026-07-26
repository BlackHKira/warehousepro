import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/zone.dart';
import '../../providers/zone_provider.dart';

class ZoneManagementScreen extends ConsumerWidget {
  const ZoneManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final zonesAsync = ref.watch(zonesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('📍 Quản lý khu vực kho'),
        actions: [
          FilledButton.icon(
            onPressed: () => _showZoneDialog(context, ref, null),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Thêm zone'),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: zonesAsync.when(
        data: (zones) => _buildTable(context, ref, zones),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Lỗi: $e')),
      ),
    );
  }

  Widget _buildTable(BuildContext context, WidgetRef ref, List<Zone> zones) {
    if (zones.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.map_outlined, size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'Chưa có khu vực nào',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 18),
            ),
            const SizedBox(height: 8),
            FilledButton.tonal(
              onPressed: () => _showZoneDialog(context, ref, null),
              child: const Text('Thêm khu vực đầu tiên'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: DataTable(
        columns: const [
          DataColumn(
            label: Text('Mã', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          DataColumn(
            label: Text('Tên', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          DataColumn(
            label: Text('Mô tả', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          DataColumn(
            label: Text(
              'Thứ tự',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          DataColumn(
            label: Text(
              'Thao tác',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
        rows: zones
            .map(
              (zone) => DataRow(
                cells: [
                  DataCell(Text(zone.code)),
                  DataCell(Text(zone.label)),
                  DataCell(Text(zone.description)),
                  DataCell(Text('${zone.sortOrder}')),
                  DataCell(
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, size: 18),
                          tooltip: 'Sửa',
                          onPressed: () => _showZoneDialog(context, ref, zone),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete,
                            size: 18,
                            color: Colors.red,
                          ),
                          tooltip: 'Xoá',
                          onPressed: () => _confirmDelete(context, ref, zone),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
            .toList(),
      ),
    );
  }

  void _showZoneDialog(BuildContext context, WidgetRef ref, Zone? existing) {
    final codeCtrl = TextEditingController(text: existing?.code ?? '');
    final labelCtrl = TextEditingController(text: existing?.label ?? '');
    final descCtrl = TextEditingController(text: existing?.description ?? '');
    final sortCtrl = TextEditingController(
      text: (existing?.sortOrder ?? 0).toString(),
    );
    final isEdit = existing != null;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isEdit ? 'Sửa khu vực' : 'Thêm khu vực mới'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: codeCtrl,
                decoration: const InputDecoration(
                  labelText: 'Mã',
                  border: OutlineInputBorder(),
                ),
                enabled: !isEdit,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: labelCtrl,
                decoration: const InputDecoration(
                  labelText: 'Tên',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descCtrl,
                decoration: const InputDecoration(
                  labelText: 'Mô tả',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: sortCtrl,
                decoration: const InputDecoration(
                  labelText: 'Thứ tự',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Huỷ'),
          ),
          FilledButton(
            onPressed: () async {
              final code = codeCtrl.text.trim();
              final label = labelCtrl.text.trim();
              if (code.isEmpty || label.isEmpty) return;
              final sortOrder = int.tryParse(sortCtrl.text) ?? 0;
              final service = ref.read(zoneServiceProvider);
              if (isEdit) {
                await service.updateZone(existing.id, {
                  'label': label,
                  'description': descCtrl.text.trim(),
                  'sortOrder': sortOrder,
                });
              } else {
                await service.addZone(
                  Zone(
                    id: '',
                    code: code,
                    label: label,
                    description: descCtrl.text.trim(),
                    sortOrder: sortOrder,
                  ),
                );
              }
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: Text(isEdit ? 'Lưu' : 'Thêm'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, Zone zone) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xoá'),
        content: Text('Bạn có chắc muốn xoá "${zone.label}" (${zone.code})?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Huỷ'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              ref.read(zoneServiceProvider).deleteZone(zone.id);
              Navigator.pop(ctx);
            },
            child: const Text('Xoá'),
          ),
        ],
      ),
    );
  }
}
