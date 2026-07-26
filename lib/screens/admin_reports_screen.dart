import 'package:flutter/material.dart';

class _ReportEntry {
  final String name;
  final int nhap, xuat;
  final int tonDau, tonCuoi;
  const _ReportEntry({
    required this.name,
    required this.nhap,
    required this.xuat,
    required this.tonDau,
    required this.tonCuoi,
  });
}

const _reportData = [
  _ReportEntry(
    name: 'Bộ phát Wi-Fi AX3000',
    nhap: 40,
    xuat: 25,
    tonDau: 113,
    tonCuoi: 128,
  ),
  _ReportEntry(
    name: 'Cáp mạng Cat6 20m',
    nhap: 0,
    xuat: 12,
    tonDau: 54,
    tonCuoi: 42,
  ),
  _ReportEntry(
    name: 'Camera IP trong nhà 2MP',
    nhap: 10,
    xuat: 8,
    tonDau: 14,
    tonCuoi: 16,
  ),
  _ReportEntry(
    name: 'Ổ cứng SSD 1TB NVMe',
    nhap: 0,
    xuat: 4,
    tonDau: 13,
    tonCuoi: 9,
  ),
  _ReportEntry(
    name: 'Bộ lưu điện UPS 650VA',
    nhap: 5,
    xuat: 3,
    tonDau: 29,
    tonCuoi: 31,
  ),
  _ReportEntry(
    name: 'Tai nghe Bluetooth Pro',
    nhap: 25,
    xuat: 0,
    tonDau: 49,
    tonCuoi: 74,
  ),
  _ReportEntry(
    name: 'Switch 8 port Gigabit',
    nhap: 0,
    xuat: 0,
    tonDau: 22,
    tonCuoi: 22,
  ),
  _ReportEntry(
    name: 'Bàn phím cơ văn phòng',
    nhap: 0,
    xuat: 2,
    tonDau: 7,
    tonCuoi: 5,
  ),
];

class AdminReportsScreen extends StatelessWidget {
  final bool embedded;
  const AdminReportsScreen({super.key, this.embedded = false});

  @override
  Widget build(BuildContext context) {
    final totalNhap = _reportData.fold(0, (s, e) => s + e.nhap);
    final totalXuat = _reportData.fold(0, (s, e) => s + e.xuat);
    final totalTon = _reportData.fold(0, (s, e) => s + e.tonCuoi);
    final totalValue = _reportData.fold(0, (s, e) => s + e.tonCuoi * 100000);

    final body = ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Stats cards
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.inventory_2,
                label: 'Tồn cuối',
                value: '$totalTon',
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatCard(
                icon: Icons.arrow_downward,
                label: 'Nhập',
                value: '$totalNhap',
                color: Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.arrow_upward,
                label: 'Xuất',
                value: '$totalXuat',
                color: Colors.red,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatCard(
                icon: Icons.attach_money,
                label: 'Giá trị tồn',
                value: '${(totalValue / 1000000).toStringAsFixed(0)} tr',
                color: Colors.orange,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Date range
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(Icons.date_range, size: 18, color: Colors.blue.shade700),
              const SizedBox(width: 10),
              Text(
                '01/07/2026 — 24/07/2026',
                style: TextStyle(
                  color: Colors.blue.shade800,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Icon(Icons.refresh, size: 16, color: Colors.blue.shade400),
            ],
          ),
        ),
        const SizedBox(height: 16),

        Text(
          'Chi tiết Nhập-Xuất-Tồn',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),

        // Data table
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Table(
              columnWidths: const {
                0: FlexColumnWidth(2.5),
                1: FlexColumnWidth(1),
                2: FlexColumnWidth(1),
                3: FlexColumnWidth(1),
                4: FlexColumnWidth(1),
              },
              children: [
                TableRow(
                  decoration: BoxDecoration(color: Colors.grey.shade50),
                  children: ['Sản phẩm', 'Nhập', 'Xuất', 'Tồn Đ', 'Tồn C']
                      .map(
                        (h) => Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 6,
                          ),
                          child: Text(
                            h,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
                ..._reportData.map(
                  (e) => TableRow(
                    children: [
                      _Cell(e.name, isBold: true),
                      _Cell(
                        e.nhap > 0 ? '+${e.nhap}' : '0',
                        color: e.nhap > 0 ? Colors.green : null,
                      ),
                      _Cell(
                        e.xuat > 0 ? '-${e.xuat}' : '0',
                        color: e.xuat > 0 ? Colors.red : null,
                      ),
                      _Cell('${e.tonDau}'),
                      _Cell('${e.tonCuoi}', isBold: true),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );

    if (embedded) return body;

    return Scaffold(
      appBar: AppBar(title: const Text('Báo cáo XNT')),
      body: body,
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color color;
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withAlpha(25),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: color,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  final String text;
  final bool isBold;
  final Color? color;
  const _Cell(this.text, {this.isBold = false, this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
          color: color ?? Colors.black87,
        ),
      ),
    );
  }
}
