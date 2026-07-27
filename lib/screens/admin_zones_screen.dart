import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class _ZoneData {
  final String code, label, description;
  final int productCount;
  const _ZoneData({required this.code, required this.label, required this.description, required this.productCount});
}

const _zones = [
  _ZoneData(code: 'A1', label: 'Nước giải khát có gas', description: 'Coca, Pepsi, Sting, 7Up, Sprite...', productCount: 8),
  _ZoneData(code: 'A2', label: 'Nước lọc, trà, tăng lực', description: 'Aquafina, C2, Red Bull, Monster...', productCount: 8),
  _ZoneData(code: 'B1', label: 'Mì, cháo, phở', description: 'Hảo Hảo, Omachi, Vifon...', productCount: 8),
  _ZoneData(code: 'B2', label: 'Bánh, kẹo, snack, sữa', description: 'Oreo, Poca, Lays, Milo...', productCount: 8),
  _ZoneData(code: 'C1', label: 'Đồ vệ sinh cá nhân', description: 'Clear, Sunsilk, Colgate...', productCount: 8),
  _ZoneData(code: 'C2', label: 'Gia dụng, tẩy rửa', description: 'Sunlight, Vim, Omo...', productCount: 8),
];

class AdminZonesScreen extends StatelessWidget {
  final bool embedded;
  const AdminZonesScreen({super.key, this.embedded = false});

  @override
  Widget build(BuildContext context) {
    final body = Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 1.6, crossAxisSpacing: 10, mainAxisSpacing: 10),
              itemCount: _zones.length,
              itemBuilder: (_, i) {
                final z = _zones[i];
                return Card(
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: _zoneColor(z.code).withValues(alpha: 0.3))),
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
                            Text('${z.productCount} SP', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(z.label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                        const SizedBox(height: 3),
                        Text(z.description, style: TextStyle(color: AppColors.textMuted, fontSize: 10), maxLines: 2, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
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
                Text('Tổng cộng 6 khu vực · 48 sản phẩm', style: TextStyle(color: AppColors.primary, fontSize: 12)),
              ],
            ),
          ),
        ),
      ],
    );

    if (embedded) return body;
    return Scaffold(appBar: AppBar(title: const Text('Khu vực kho')), body: body);
  }

  Color _zoneColor(String code) {
    if (code.startsWith('A')) return AppColors.primary;
    if (code.startsWith('B')) return AppColors.green;
    if (code.startsWith('C')) return AppColors.orange;
    return Colors.grey;
  }
}
