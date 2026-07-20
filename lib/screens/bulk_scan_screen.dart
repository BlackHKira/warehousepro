import 'package:flutter/material.dart';

class BulkScanScreen extends StatefulWidget {
  const BulkScanScreen({super.key});

  @override
  State<BulkScanScreen> createState() => _BulkScanScreenState();
}

class _BulkScanScreenState extends State<BulkScanScreen> {
  String _selectedZone = 'A1';
  bool _isScanning = false;
  int _scannedCount = 0;

  final _results = <_ScanResult>[];

  final _zones = ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'];

  void _startScan() {
    setState(() => _isScanning = true);
  }

  void _simulateScan() {
    final mockItems = [
      _ScanResult(product: 'Coca Cola 355ml', barcode: '8934567890123', book: 24, actual: 24, status: 'match'),
      _ScanResult(product: 'Pepsi 355ml', barcode: '8934567890456', book: 18, actual: 18, status: 'match'),
      _ScanResult(product: 'Sting đỏ 330ml', barcode: '8934567890789', book: 12, actual: 10, status: 'shortage'),
      _ScanResult(product: 'Aquafina 500ml', barcode: '8934567890111', book: 30, actual: 31, status: 'surplus'),
      _ScanResult(product: 'Number 1', barcode: '8934567890222', book: 8, actual: 8, status: 'match'),
      _ScanResult(product: 'Trà xanh C2', barcode: '8934567890333', book: 15, actual: 0, status: 'missing'),
    ];
    setState(() {
      _results.clear();
      _results.addAll(mockItems);
      _scannedCount = mockItems.length;
      _isScanning = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kiểm kê theo vị trí')),
      body: Column(
        children: [
          // Zone selector
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
                    children: _zones.map((z) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text('Khu $z'),
                        selected: _selectedZone == z,
                        onSelected: (_) => setState(() => _selectedZone = z),
                      ),
                    )).toList(),
                  ),
                ),
              ],
            ),
          ),

          // Continuous scan mode indicator
          if (_isScanning)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity, height: 180,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade900,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.shade700, width: 2),
                    ),
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
                      Icon(Icons.check_circle, color: Colors.greenAccent, size: 16),
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
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white54),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Start scan button
          if (!_isScanning)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _startScan,
                  icon: const Icon(Icons.qr_code_scanner),
                  label: const Text('Bắt đầu quét liên tục'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ),

          // Results
          if (_results.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Text('Kết quả kiểm kê', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                  const Spacer(),
                  Text('${_results.length} sản phẩm', style: TextStyle(color: Colors.grey.shade600)),
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
                      statusColor = Colors.green;
                      statusIcon = Icons.check_circle;
                      statusLabel = 'Khớp';
                      break;
                    case 'shortage':
                      statusColor = Colors.red;
                      statusIcon = Icons.arrow_downward;
                      statusLabel = 'Thiếu ${r.book - r.actual}';
                      break;
                    case 'surplus':
                      statusColor = Colors.lightGreen;
                      statusIcon = Icons.arrow_upward;
                      statusLabel = 'Dư ${r.actual - r.book}';
                      break;
                    case 'missing':
                      statusColor = Colors.orange;
                      statusIcon = Icons.help;
                      statusLabel = 'Mất tích';
                      break;
                    default:
                      statusColor = Colors.grey;
                      statusIcon = Icons.help;
                      statusLabel = '';
                  }

                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(backgroundColor: statusColor.withAlpha(25), child: Icon(statusIcon, color: statusColor, size: 22)),
                      title: Text(r.product, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
                      subtitle: Text('Sổ: ${r.book} → Thực tế: ${r.actual}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: statusColor.withAlpha(25), borderRadius: BorderRadius.circular(8)),
                        child: Text(statusLabel, style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.w600)),
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
                    Icon(Icons.qr_code_scanner, size: 64, color: Colors.grey),
                    SizedBox(height: 12),
                    Text('Bấm "Bắt đầu quét" để kiểm kê', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ScanResult {
  final String product, barcode;
  final int book, actual;
  final String status; // match, shortage, surplus, missing
  _ScanResult({required this.product, required this.barcode, required this.book, required this.actual, required this.status});
}
