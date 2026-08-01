import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/warehouse_provider.dart';
import '../theme/app_theme.dart';

enum _RangeFilter { today, yesterday, week, all }

class TransactionHistoryScreen extends ConsumerStatefulWidget {
  final bool embedded;
  const TransactionHistoryScreen({super.key, this.embedded = false});

  @override
  ConsumerState<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState
    extends ConsumerState<TransactionHistoryScreen> {
  _RangeFilter _filter = _RangeFilter.week;
  DateTime? _customStart;
  DateTime? _customEnd;

  (DateTime?, DateTime?) get _range {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    switch (_filter) {
      case _RangeFilter.today:
        return (today, today.add(const Duration(days: 1)));
      case _RangeFilter.yesterday:
        final y = today.subtract(const Duration(days: 1));
        return (y, today);
      case _RangeFilter.week:
        return (today.subtract(const Duration(days: 6)), today.add(const Duration(days: 1)));
      case _RangeFilter.all:
        return (_customStart, _customEnd?.add(const Duration(days: 1)));
    }
  }

  String get _rangeLabel {
    switch (_filter) {
      case _RangeFilter.today:
        return 'Hôm nay';
      case _RangeFilter.yesterday:
        return 'Hôm qua';
      case _RangeFilter.week:
        return '7 ngày qua';
      case _RangeFilter.all:
        if (_customStart == null) return 'Tất cả';
        return '${_fmtDay(_customStart!)} → ${_fmtDay(_customEnd ?? _customStart!)}';
    }
  }

  Future<void> _pickRange() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: today,
      initialDateRange: _customStart != null
          ? DateTimeRange(
              start: _customStart!,
              end: _customEnd ?? _customStart!,
            )
          : DateTimeRange(start: today.subtract(const Duration(days: 6)), end: today),
    );
    if (range == null || !mounted) return;
    setState(() {
      _filter = _RangeFilter.all;
      _customStart = range.start;
      _customEnd = range.end;
    });
  }

  @override
  Widget build(BuildContext context) {
    final warehouse = ref.watch(warehouseProvider);
    final all = <Map<String, dynamic>>[
      ...warehouse.recentImports,
      ...warehouse.recentExports,
    ];

    final (start, endExclusive) = _range;
    final filtered = all.where((e) {
      final createdAt = DateTime.tryParse(e['createdAt'] as String? ?? '');
      if (createdAt == null) return false;
      if (start != null && createdAt.isBefore(start)) return false;
      if (endExclusive != null && !createdAt.isBefore(endExclusive)) return false;
      return true;
    }).toList()
      ..sort((a, b) => (b['createdAt'] as String? ?? '')
          .compareTo(a['createdAt'] as String? ?? ''));

    final totalImport = filtered
        .where((e) => e['type'] == 'import')
        .fold(0, (s, e) => s + ((e['items'] as num?)?.toInt() ?? 0));
    final totalExport = filtered
        .where((e) => e['type'] != 'import')
        .fold(0, (s, e) => s + ((e['items'] as num?)?.toInt() ?? 0));

    final groups = _groupByDay(filtered);

    final body = Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _rangeChip(_RangeFilter.today, 'Hôm nay'),
                      const SizedBox(width: 6),
                      _rangeChip(_RangeFilter.yesterday, 'Hôm qua'),
                      const SizedBox(width: 6),
                      _rangeChip(_RangeFilter.week, '7 ngày'),
                      const SizedBox(width: 6),
                      _rangeChip(_RangeFilter.all, _customStart != null ? 'Tùy chọn' : 'Tất cả'),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 4),
              IconButton(
                tooltip: 'Chọn khoảng ngày',
                icon: const Icon(Icons.date_range_outlined),
                onPressed: _pickRange,
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Text(
                'Phạm vi: $_rangeLabel',
                style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
              const Spacer(),
              Text(
                '${filtered.length} giao dịch',
                style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: _MiniStat(
                  label: 'Tổng nhập',
                  value: '$totalImport',
                  color: AppColors.green,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MiniStat(
                  label: 'Tổng xuất',
                  value: '$totalExport',
                  color: AppColors.red,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MiniStat(
                  label: 'Chênh lệch',
                  value: '${totalImport - totalExport}',
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: filtered.isEmpty
              ? const _TxEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 24),
                  itemCount: groups.length,
                  itemBuilder: (_, i) {
                    final group = groups[i];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _DayHeader(
                          label: _dayLabel(group.day),
                          importCount: group.importCount,
                          exportCount: group.exportCount,
                        ),
                        ...group.entries.map(
                          (e) => _TxTile(
                            type: e['type'] as String? ?? '',
                            name: _txTitle(e),
                            items: (e['items'] as num?)?.toInt() ?? 0,
                            id: (e['firestoreId'] ?? e['id'] ?? '').toString(),
                            createdAt: e['createdAt'] as String?,
                          ),
                        ),
                      ],
                    );
                  },
                ),
        ),
      ],
    );

    if (widget.embedded) return body;
    return Scaffold(
      appBar: AppBar(title: const Text('Lịch sử giao dịch')),
      body: body,
    );
  }

  Widget _rangeChip(_RangeFilter value, String label) {
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: _filter == value ? Colors.white : AppColors.textPrimary,
        ),
      ),
      selected: _filter == value,
      onSelected: (_) => setState(() => _filter = value),
      selectedColor: AppColors.primary,
      backgroundColor: const Color(0xFFE8ECF4),
      visualDensity: VisualDensity.compact,
    );
  }
}

class _TxGroup {
  final DateTime day;
  final List<Map<String, dynamic>> entries;
  _TxGroup(this.day, this.entries);

  int get importCount =>
      entries.where((e) => e['type'] == 'import').length;
  int get exportCount => entries.length - importCount;
}

List<_TxGroup> _groupByDay(List<Map<String, dynamic>> entries) {
  final map = <String, List<Map<String, dynamic>>>{};
  for (final e in entries) {
    final createdAt = DateTime.tryParse(e['createdAt'] as String? ?? '');
    if (createdAt == null) continue;
    final key = '${createdAt.year}-${createdAt.month}-${createdAt.day}';
    map.putIfAbsent(key, () => []).add(e);
  }
  final keys = map.keys.toList()..sort((a, b) => b.compareTo(a));
  return keys.map((k) {
    final first = DateTime.tryParse(map[k]!.first['createdAt'] as String? ?? '')!;
    return _TxGroup(first, map[k]!);
  }).toList();
}

class _DayHeader extends StatelessWidget {
  final String label;
  final int importCount;
  final int exportCount;
  const _DayHeader({
    required this.label,
    required this.importCount,
    required this.exportCount,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
          const Spacer(),
          Text(
            'NK $importCount • XK $exportCount',
            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

class _TxTile extends StatelessWidget {
  final String type;
  final String name;
  final int items;
  final String id;
  final String? createdAt;
  const _TxTile({
    required this.type,
    required this.name,
    required this.items,
    required this.id,
    required this.createdAt,
  });

  @override
  Widget build(BuildContext context) {
    final isImport = type == 'import';
    final color = isImport ? AppColors.green : AppColors.red;
    final prefix = isImport ? 'NK' : 'XK';
    final code = id.length >= 4 ? '$prefix-${id.substring(0, 4).toUpperCase()}' : '$prefix-0000';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      child: ListTile(
        dense: true,
        leading: Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
        subtitle: Text(
          '${isImport ? 'Nhập' : 'Xuất'} $items — $code',
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        trailing: Text(
          _timeOnly(createdAt),
          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _MiniStat({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: color),
          ),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class _TxEmptyState extends StatelessWidget {
  const _TxEmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.receipt_long_outlined, size: 64, color: AppColors.textMuted),
          const SizedBox(height: 12),
          const Text('Không có giao dịch trong khoảng thời gian này'),
          const SizedBox(height: 4),
          Text(
            'Thử chọn khoảng ngày khác',
            style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

String _txTitle(Map<String, dynamic> entry) {
  final products = entry['products'] as List<dynamic>? ?? [];
  if (products.isNotEmpty) {
    final name = products.first is Map
        ? products.first['name'] as String?
        : null;
    if (name != null && name.isNotEmpty) return name;
  }
  if (entry['type'] == 'import') {
    return entry['supplier'] as String? ?? 'Nhập kho';
  }
  return entry['customer'] as String? ?? 'Xuất kho';
}

String _dayLabel(DateTime day) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  if (day == today) return 'Hôm nay';
  if (day == today.subtract(const Duration(days: 1))) return 'Hôm qua';
  return _fmtDay(day);
}

String _fmtDay(DateTime d) {
  return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}

String _timeOnly(String? createdAt) {
  final dt = DateTime.tryParse(createdAt ?? '');
  if (dt == null) return '';
  return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}
