import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/zone_provider.dart' show zonesProvider;
import '../providers/product_provider.dart';
import '../services/zone_service.dart' show ZoneService;
import '../theme/app_theme.dart';

class BulkScanScreen extends ConsumerStatefulWidget {
  final bool embedded;
  const BulkScanScreen({super.key, this.embedded = false});

  @override
  ConsumerState<BulkScanScreen> createState() => _BulkScanScreenState();
}

class _BulkScanScreenState extends ConsumerState<BulkScanScreen> {
  String _selectedZone = 'A1';
  bool _isScanning = false;
  int _scannedCount = 0;
  final _results = <_ScanResult>[];

  void _startScan() {
    setState(() => _isScanning = true);
  }

  void _simulateScan() {
    final products = ref.read(productsProvider).valueOrNull ?? [];
    final zoneProducts = products.where((p) => p.zone == _selectedZone).toList();
    final results = <_ScanResult>[];

    for (final p in zoneProducts) {
      final actual = p.stock + (DateTime.now().millisecond % 5) - 2;
      final rnd = DateTime.now().millisecond % 7;
      final status = rnd == 6 ? 'error' : (actual == p.stock ? 'match' : (actual < p.stock ? 'shortage' : 'surplus'));
      results.add(_ScanResult(product: p.name, barcode: p.barcode, book: p.stock, actual: actual < 0 ? 0 : actual, status: status, unitPerCase: p.unitPerCase, unit: p.unit));
    }

    if (results.isEmpty) {
      results.add(_ScanResult(product: '(Chưa có SP trong khu vực $_selectedZone)', barcode: '-', book: 0, actual: 0, status: 'match', unitPerCase: 1, unit: 'sản phẩm'));
    }

    setState(() {
      _results.clear();
      _results.addAll(results);
      _scannedCount = results.length;
      _isScanning = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final zones = ref.watch(zonesProvider).valueOrNull ?? ZoneService.defaultZones;

    final body = Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Khu vực kho', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: zones.map((z) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(z.label, style: TextStyle(fontSize: 13, color: _selectedZone == z.code ? Colors.white : AppColors.textPrimary)),
                        selected: _selectedZone == z.code,
                        onSelected: (_) => setState(() => _selectedZone = z.code),
                        selectedColor: AppColors.primary,
                        backgroundColor: const Color(0xFFE8ECF4),
                      ),
                    )).toList(),
                  ),
                ),
              ],
            ),
          ),
          if (_isScanning)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  Container(
                    width: double.infinity, height: 180,
                    decoration: BoxDecoration(color: Colors.grey.shade900, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.green, width: 2)),
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.qr_code_scanner, color: Colors.white, size: 72),
                          SizedBox(height: 12),
                          Text('Đang quét liên tục...', style: TextStyle(color: Colors.white70, fontSize: 16)),
                          Text('≥ 5 mã/giây', style: TextStyle(color: Colors.greenAccent, fontSize: 13)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_circle, color: Colors.greenAccent, size: 16),
                      const SizedBox(width: 6),
                      Text('Đã quét: $_scannedCount sản phẩm', style: const TextStyle(color: Colors.white70)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity, height: 44,
                    child: OutlinedButton.icon(
                      onPressed: _simulateScan,
                      icon: const Icon(Icons.stop),
                      label: const Text('Dừng quét & xem kết quả'),
                      style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: const BorderSide(color: Colors.white54), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                    ),
                  ),
                ],
              ),
            ),
          if (!_isScanning)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _startScan,
                  icon: const Icon(Icons.qr_code_scanner),
                  label: const Text('Bắt đầu quét liên tục'),
                  style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                ),
              ),
            ),
          if (_results.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Text('Kết quả kiểm kê', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                  const Spacer(),
                  Text('${_results.length} sản phẩm', style: TextStyle(color: AppColors.textSecondary)),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: _results.map((r) {
                  Color statusColor;
                  IconData statusIcon;
                  String statusLabel;
                  switch (r.status) {
                    case 'match':
                      statusColor = AppColors.green;
                      statusIcon = Icons.check_circle;
                      statusLabel = 'Khớp';
                      break;
                    case 'shortage':
                      statusColor = AppColors.red;
                      statusIcon = Icons.arrow_downward;
                      statusLabel = 'Thiếu ${r.book - r.actual}';
                      break;
                    case 'surplus':
                      statusColor = AppColors.orange;
                      statusIcon = Icons.arrow_upward;
                      statusLabel = 'Thừa ${r.actual - r.book}';
                      break;
                    case 'error':
                      statusColor = AppColors.red;
                      statusIcon = Icons.error_outline;
                      statusLabel = 'Lỗi';
                      break;
                    default:
                      statusColor = AppColors.orange;
                      statusIcon = Icons.help;
                      statusLabel = 'Mất tích';
                  }
                  Color cardBg;
                  Color cardText;
                  switch (r.status) {
                    case 'match':
                      cardBg = AppColors.successLight;
                      cardText = AppColors.successDark;
                      break;
                    case 'shortage':
                      cardBg = AppColors.errorLight;
                      cardText = AppColors.errorDark;
                      break;
                    case 'surplus':
                      cardBg = AppColors.warningLight;
                      cardText = AppColors.warningDark;
                      break;
                    default:
                      cardBg = statusColor.withValues(alpha: 0.1);
                      cardText = statusColor;
                  }
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(backgroundColor: cardBg, child: Icon(statusIcon, color: cardText, size: 22)),
                      title: Text(r.product, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
                      subtitle: Text('Sổ: ${formatStock(r.book, r.unitPerCase, r.unit)} → Thực tế: ${formatStock(r.actual, r.unitPerCase, r.unit)}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(8)),
                        child: Text(statusLabel, style: TextStyle(color: cardText, fontSize: 11, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
          if (_results.isEmpty && !_isScanning)
            const Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.qr_code_scanner, size: 64, color: AppColors.textMuted),
                    SizedBox(height: 12),
                    Text('Bấm "Bắt đầu quét" để kiểm kê', style: TextStyle(color: AppColors.textMuted)),
                  ],
                ),
              ),
            ),
          ],
        );
      if (widget.embedded) return body;
      return Scaffold(
        appBar: AppBar(title: const Text('Kiểm kê')),
        body: body,
      );
  }
}

class _ScanResult {
  final String product, barcode, unit;
  final int book, actual, unitPerCase;
  final String status;
  _ScanResult({required this.product, required this.barcode, required this.book, required this.actual, required this.status, required this.unitPerCase, required this.unit});
}
