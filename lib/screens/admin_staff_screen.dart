import 'package:flutter/material.dart';

class _Staff {
  final String id, name, email, phone, role;
  final bool fcmActive;
  final int transactions, imports, exports;
  const _Staff({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.fcmActive,
    required this.transactions,
    required this.imports,
    required this.exports,
  });
}

const _staffList = [
  _Staff(
    id: 'u-1',
    name: 'Nguyễn Văn Minh',
    email: 'minh@whpro.com',
    phone: '0901 234 567',
    role: 'Thủ kho',
    fcmActive: true,
    transactions: 156,
    imports: 89,
    exports: 67,
  ),
  _Staff(
    id: 'u-2',
    name: 'Trần Thị An',
    email: 'an@whpro.com',
    phone: '0902 345 678',
    role: 'Thủ kho',
    fcmActive: true,
    transactions: 132,
    imports: 71,
    exports: 61,
  ),
  _Staff(
    id: 'u-3',
    name: 'Lê Văn Hoàng',
    email: 'hoang@whpro.com',
    phone: '0903 456 789',
    role: 'Kế toán',
    fcmActive: false,
    transactions: 98,
    imports: 45,
    exports: 53,
  ),
  _Staff(
    id: 'u-4',
    name: 'Phạm Thị Lan',
    email: 'lan@whpro.com',
    phone: '0904 567 890',
    role: 'Quản lý',
    fcmActive: true,
    transactions: 45,
    imports: 20,
    exports: 25,
  ),
  _Staff(
    id: 'u-5',
    name: 'Hoàng Văn Tùng',
    email: 'tung@whpro.com',
    phone: '0905 678 901',
    role: 'Thủ kho',
    fcmActive: true,
    transactions: 201,
    imports: 112,
    exports: 89,
  ),
  _Staff(
    id: 'u-6',
    name: 'Ngô Thị Hoa',
    email: 'hoa@whpro.com',
    phone: '0906 789 012',
    role: 'Kế toán',
    fcmActive: false,
    transactions: 72,
    imports: 38,
    exports: 34,
  ),
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
              const Text(
                'Bộ lọc: ',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              ...['Tất cả', 'Thủ kho', 'Kế toán', 'Quản lý'].map(
                (r) => Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ChoiceChip(
                    label: Text(r, style: const TextStyle(fontSize: 12)),
                    selected: _filterRole == r,
                    onSelected: (_) => setState(() => _filterRole = r),
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ),
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
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => _showDetail(context, s),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: _roleColor(s.role).withAlpha(25),
                          child: Icon(Icons.person, color: _roleColor(s.role)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    s.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  _RoleBadge(s.role),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                s.email,
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${s.transactions} GD · ${s.imports} nhập · ${s.exports} xuất',
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (s.fcmActive)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.green.withAlpha(50),
                                  blurRadius: 4,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                          )
                        else
                          Icon(
                            Icons.circle,
                            size: 8,
                            color: Colors.grey.shade300,
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );

    if (widget.embedded) return body;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nhân sự'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (v) => setState(() => _filterRole = v),
            itemBuilder: (_) => ['Tất cả', 'Thủ kho', 'Kế toán', 'Quản lý']
                .map(
                  (r) => PopupMenuItem(
                    value: r,
                    child: Text(
                      r,
                      style: TextStyle(
                        fontWeight: _filterRole == r
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
      body: body,
    );
  }

  Color _roleColor(String role) {
    switch (role) {
      case 'Thủ kho':
        return Colors.blue;
      case 'Kế toán':
        return Colors.orange;
      case 'Quản lý':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  void _showDetail(BuildContext context, _Staff s) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: _roleColor(s.role).withAlpha(25),
                  child: Icon(
                    Icons.person,
                    size: 28,
                    color: _roleColor(s.role),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    _RoleBadge(s.role),
                  ],
                ),
              ],
            ),
            const Divider(height: 24),
            _DetailRow(Icons.email_outlined, s.email),
            _DetailRow(Icons.phone_outlined, s.phone),
            _DetailRow(Icons.checklist, '${s.transactions} giao dịch'),
            _DetailRow(Icons.arrow_downward, '${s.imports} phiếu nhập'),
            _DetailRow(Icons.arrow_upward, '${s.exports} phiếu xuất'),
            _DetailRow(
              Icons.circle,
              s.fcmActive ? 'Đang hoạt động' : 'Không hoạt động',
              color: s.fcmActive ? Colors.green : Colors.grey,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  final String role;
  const _RoleBadge(this.role);
  @override
  Widget build(BuildContext context) {
    Color c;
    switch (role) {
      case 'Thủ kho':
        c = Colors.blue;
        break;
      case 'Kế toán':
        c = Colors.orange;
        break;
      case 'Quản lý':
        c = Colors.purple;
        break;
      default:
        c = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: c.withAlpha(20),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        role,
        style: TextStyle(color: c, fontSize: 10, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color? color;
  const _DetailRow(this.icon, this.text, {this.color});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color ?? Colors.grey.shade500),
          const SizedBox(width: 10),
          Text(
            text,
            style: TextStyle(fontSize: 13, color: color ?? Colors.black87),
          ),
        ],
      ),
    );
  }
}
