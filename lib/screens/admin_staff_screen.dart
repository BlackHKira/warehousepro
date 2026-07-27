import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class _Staff {
  final String id, name, email, phone, role;
  final bool fcmActive;
  final int transactions, imports, exports;
  const _Staff({required this.id, required this.name, required this.email, required this.phone, required this.role, required this.fcmActive, required this.transactions, required this.imports, required this.exports});
}

const _staffList = [
  _Staff(id: 'u-1', name: 'Nguyễn Văn Minh', email: 'minh@whpro.com', phone: '0901 234 567', role: 'Thủ kho', fcmActive: true, transactions: 156, imports: 89, exports: 67),
  _Staff(id: 'u-2', name: 'Trần Thị An', email: 'an@whpro.com', phone: '0902 345 678', role: 'Thủ kho', fcmActive: true, transactions: 132, imports: 71, exports: 61),
  _Staff(id: 'u-3', name: 'Lê Văn Hoàng', email: 'hoang@whpro.com', phone: '0903 456 789', role: 'Kế toán', fcmActive: false, transactions: 98, imports: 45, exports: 53),
  _Staff(id: 'u-4', name: 'Phạm Thị Lan', email: 'lan@whpro.com', phone: '0904 567 890', role: 'Quản lý', fcmActive: true, transactions: 45, imports: 20, exports: 25),
  _Staff(id: 'u-5', name: 'Hoàng Văn Tùng', email: 'tung@whpro.com', phone: '0905 678 901', role: 'Thủ kho', fcmActive: true, transactions: 201, imports: 112, exports: 89),
  _Staff(id: 'u-6', name: 'Ngô Thị Hoa', email: 'hoa@whpro.com', phone: '0906 789 012', role: 'Kế toán', fcmActive: false, transactions: 72, imports: 38, exports: 34),
];

class AdminStaffScreen extends StatefulWidget {
  final bool embedded;
  const AdminStaffScreen({super.key, this.embedded = false});
  @override
  State<AdminStaffScreen> createState() => _AdminStaffScreenState();
}

class _AdminStaffScreenState extends State<AdminStaffScreen> {
  String _filterRole = 'Tất cả';

  List<_Staff> get _filtered {
    if (_filterRole == 'Tất cả') return _staffList;
    return _staffList.where((s) => s.role == _filterRole).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

    final body = Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              const Text('Bộ lọc: ', style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
              ...['Tất cả', 'Thủ kho', 'Kế toán', 'Quản lý'].map((r) => Padding(
                padding: const EdgeInsets.only(right: 6),
                child: ChoiceChip(
                  label: Text(r, style: const TextStyle(fontSize: 12)),
                  selected: _filterRole == r,
                  onSelected: (_) => setState(() => _filterRole = r),
                  visualDensity: VisualDensity.compact,
                ),
              )),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: filtered.length,
            itemBuilder: (_, i) {
              final s = filtered[i];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: ListTile(
                  leading: CircleAvatar(backgroundColor: _roleColor(s.role).withValues(alpha: 0.1), child: Icon(Icons.person, color: _roleColor(s.role))),
                  title: Row(
                    children: [
                      Text(s.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      const SizedBox(width: 8),
                      _RoleBadge(s.role),
                    ],
                  ),
                  subtitle: Text('${s.email} · ${s.transactions} GD', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  trailing: s.fcmActive
                      ? Container(width: 8, height: 8, decoration: BoxDecoration(color: AppColors.green, shape: BoxShape.circle))
                      : Icon(Icons.circle, size: 8, color: AppColors.textMuted),
                ),
              );
            },
          ),
        ),
      ],
    );

    if (widget.embedded) return body;
    return Scaffold(appBar: AppBar(title: const Text('Nhân sự')), body: body);
  }

  Color _roleColor(String role) {
    switch (role) {
      case 'Thủ kho': return AppColors.primary;
      case 'Kế toán': return AppColors.orange;
      case 'Quản lý': return Colors.purple;
      default: return Colors.grey;
    }
  }
}

class _RoleBadge extends StatelessWidget {
  final String role;
  const _RoleBadge(this.role);
  @override
  Widget build(BuildContext context) {
    Color c;
    switch (role) {
      case 'Thủ kho': c = AppColors.primary; break;
      case 'Kế toán': c = AppColors.orange; break;
      case 'Quản lý': c = Colors.purple; break;
      default: c = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: c.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
      child: Text(role, style: TextStyle(color: c, fontSize: 10, fontWeight: FontWeight.w600)),
    );
  }
}
