import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/warehouse_provider.dart' show warehouseProvider;
import '../theme/app_theme.dart';

void showPendingSyncSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => const PendingSyncSheet(),
  );
}

class PendingSyncSheet extends ConsumerStatefulWidget {
  const PendingSyncSheet({super.key});

  @override
  ConsumerState<PendingSyncSheet> createState() => _PendingSyncSheetState();
}

class _PendingSyncSheetState extends ConsumerState<PendingSyncSheet> {
  late Future<List<Map<String, dynamic>>> _pendingFuture;

  @override
  void initState() {
    super.initState();
    _pendingFuture = ref.read(warehouseProvider.notifier).getPendingList();
  }

  void _reload() {
    setState(() {
      _pendingFuture = ref.read(warehouseProvider.notifier).getPendingList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final warehouse = ref.watch(warehouseProvider);
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
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
              padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
              child: Row(
                children: [
                  const Icon(Icons.sync_problem, color: AppColors.orange, size: 20),
                  const SizedBox(width: 8),
                  const Text('Phiếu chờ đồng bộ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.refresh, size: 20),
                    tooltip: 'Làm mới',
                    onPressed: _reload,
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _pendingFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final pending = snapshot.data ?? [];
                  if (pending.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.cloud_done_outlined, size: 48, color: AppColors.green),
                          const SizedBox(height: 8),
                          const Text('Không có phiếu chờ đồng bộ', style: TextStyle(color: AppColors.textMuted)),
                          const SizedBox(height: 8),
                          const Text('Tất cả dữ liệu đã được đồng bộ', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                        ],
                      ),
                    );
                  }
                  return ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: pending.length,
                    itemBuilder: (_, i) {
                      final entry = pending[i];
                      final isImport = entry['type'] == 'import';
                      final createdAt = entry['createdAt'] as String? ?? '';
                      final items = entry['items'];
                      final status = entry['status'] as String? ?? 'pending';
                      final isLocalOnly = entry['syncStatus'] == 'local_only';
                      return ListTile(
                        leading: CircleAvatar(
                          radius: 20,
                          backgroundColor: isImport ? AppColors.successLight : AppColors.errorLight,
                          child: Icon(
                            isImport ? Icons.download_outlined : Icons.upload_outlined,
                            color: isImport ? AppColors.green : AppColors.red,
                          ),
                        ),
                        title: Text(
                          isImport ? 'Phiếu nhập' : 'Phiếu xuất',
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${isImport ? (entry['supplier'] as String? ?? '') : (entry['customer'] as String? ?? '')} • $items sản phẩm',
                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                            if (createdAt.isNotEmpty)
                              Text(
                                _formatTime(createdAt),
                                style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                              ),
                          ],
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            _statusChip(isLocalOnly, status),
                            const SizedBox(height: 4),
                            Text(
                              isLocalOnly ? 'Chờ hoàn thành' : 'Chờ sync',
                              style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (warehouse.isSyncing) ...[
                    const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.orange)),
                    const SizedBox(width: 8),
                    const Text('Đang đồng bộ...', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                  ] else
                    const Text('Các phiếu này sẽ tự động đồng bộ khi có mạng', style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusChip(bool isLocalOnly, String status) {
    final Color bg;
    final Color fg;
    final String label;
    if (isLocalOnly) {
      bg = AppColors.warningLight;
      fg = AppColors.warningDark;
      label = 'Đang chờ';
    } else {
      bg = AppColors.primaryLight;
      fg = AppColors.primary;
      label = 'Pending';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: fg)),
    );
  }

  String _formatTime(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      final now = DateTime.now();
      final diff = now.difference(dt);
      if (diff.inMinutes < 1) return 'Vừa xong';
      if (diff.inHours < 1) return '${diff.inMinutes} phút trước';
      if (diff.inDays < 1) return '${diff.inHours} giờ trước';
      return '${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return '';
    }
  }
}