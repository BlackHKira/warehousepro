import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/warehouse_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/web_table.dart';

enum _RangeFilter { today, yesterday, week, all }
enum _TypeFilter { all, import, export }

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
  _TypeFilter _type = _TypeFilter.all;
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
      if (_type == _TypeFilter.import && e['type'] != 'import') return false;
      if (_type == _TypeFilter.export && e['type'] == 'import') return false;
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

    final body = LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 800) {
          return _webBody(filtered, totalImport, totalExport);
        }
        return _mobileBody(filtered, totalImport, totalExport, groups);
      },
    );

    if (widget.embedded) return body;
    return Scaffold(
      appBar: AppBar(title: const Text('Lịch sử giao dịch')),
      body: body,
    );
  }

  Widget _mobileBody(
    List<Map<String, dynamic>> filtered,
    int totalImport,
    int totalExport,
    List<_TxGroup> groups,
  ) {
    return Column(
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
  }

  Widget _webBody(
    List<Map<String, dynamic>> filtered,
    int totalImport,
    int totalExport,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _rangeChip(_RangeFilter.today, 'Hôm nay'),
              _rangeChip(_RangeFilter.yesterday, 'Hôm qua'),
              _rangeChip(_RangeFilter.week, '7 ngày'),
              _rangeChip(
                _RangeFilter.all,
                _customStart != null ? 'Tùy chọn' : 'Tất cả',
              ),
              IconButton(
                tooltip: 'Chọn khoảng ngày',
                icon: const Icon(Icons.date_range_outlined),
                onPressed: _pickRange,
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<_TypeFilter>(
                    value: _type,
                    style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                    items: const [
                      DropdownMenuItem(value: _TypeFilter.all, child: Text('Tất cả loại')),
                      DropdownMenuItem(value: _TypeFilter.import, child: Text('Nhập kho')),
                      DropdownMenuItem(value: _TypeFilter.export, child: Text('Xuất kho')),
                    ],
                    onChanged: (v) => setState(() => _type = v!),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
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
          const SizedBox(height: 10),
          Wrap(
            spacing: 14,
            runSpacing: 10,
            children: [
              _WebStatBox(label: 'Tổng nhập', value: '$totalImport', color: AppColors.green),
              _WebStatBox(label: 'Tổng xuất', value: '$totalExport', color: AppColors.red),
              _WebStatBox(label: 'Chênh lệch', value: '${totalImport - totalExport}', color: AppColors.primary),
            ],
          ),
          const SizedBox(height: 14),
          WebTable(
            minWidth: 900,
            headers: const ['Mã phiếu', 'Loại', 'Thời gian', 'Sản phẩm', 'SL', 'Bên liên quan'],
            rows: [
              for (final e in filtered)
                _txRow(e),
            ],
            cellAligns: const [null, null, null, null, TextAlign.right, null],
          ),
        ],
      ),
    );
  }

  List<Widget> _txRow(Map<String, dynamic> e) {
    final isImport = e['type'] == 'import';
    final color = isImport ? AppColors.green : AppColors.red;
    final prefix = isImport ? 'NK' : 'XK';
    final id = (e['firestoreId'] ?? e['id'] ?? '').toString();
    final code = id.length >= 4 ? '$prefix-${id.substring(0, 4).toUpperCase()}' : '$prefix-0000';
    final partner = (isImport ? e['supplier'] : e['customer']) as String? ?? '';
    final name = _txTitle(e);
    final items = (e['items'] as num?)?.toInt() ?? 0;
    return [
      Text(code, style: const TextStyle(fontWeight: FontWeight.w600)),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(99),
        ),
        child: Text(
          isImport ? 'Nhập' : 'Xuất',
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color),
        ),
      ),
      Text(
        _fullTime(e['createdAt'] as String?),
        style: const TextStyle(color: AppColors.textSecondary),
      ),
      Text(name),
      Text(
        '${isImport ? '+' : '-'}$items',
        style: TextStyle(fontWeight: FontWeight.w700, color: color),
      ),
      Text(partner, style: const TextStyle(color: AppColors.textSecondary)),
    ];
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
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: color),
            ),
          ),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary), overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

class _WebStatBox extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _WebStatBox({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 22,
              letterSpacing: -0.6,
              color: color,
            ),
          ),
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

String _fullTime(String? createdAt) {
  final dt = DateTime.tryParse(createdAt ?? '');
  if (dt == null) return '';
  return '${_fmtDay(dt)} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}
