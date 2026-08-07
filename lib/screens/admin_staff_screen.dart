import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../providers/users_provider.dart';
import '../providers/user_profile_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/web_table.dart';

class AdminStaffScreen extends ConsumerWidget {
  final bool embedded;
  final bool readOnly;
  const AdminStaffScreen({super.key, this.embedded = false, this.readOnly = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(usersProvider);
    final profile = ref.watch(userProfileProvider);
    final isAccountant = profile?.isAccountant ?? readOnly;

    final body = usersAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Lỗi: $e')),
      data: (users) => _StaffBody(users: users, isReadOnly: isAccountant),
    );

    if (embedded) return body;
    return Scaffold(appBar: AppBar(title: const Text('Nhân sự')), body: body);
  }
}

class _StaffBody extends StatefulWidget {
  final List<Map<String, dynamic>> users;
  final bool isReadOnly;
  const _StaffBody({required this.users, required this.isReadOnly});

  @override
  State<_StaffBody> createState() => _StaffBodyState();
}

class _StaffBodyState extends State<_StaffBody> {
  String _filterRole = 'Tất cả';
  bool _showInactive = false;
  String _search = '';

  FirebaseFirestore get _db => FirebaseFirestore.instanceFor(
    app: Firebase.app(),
    databaseId: 'warehousepro-db',
  );

  List<Map<String, dynamic>> get _filtered {
    var list = widget.users.toList();
    if (!_showInactive) {
      list = list.where((u) => u['isActive'] as bool? ?? true).toList();
    }
    if (_filterRole != 'Tất cả') {
      list = list.where((u) => u['role'] == _filterRole).toList();
    }
    final q = _search.trim().toLowerCase();
    if (q.isNotEmpty) {
      list = list.where((u) {
        final name = (u['name'] as String? ?? u['fullName'] as String? ?? '').toLowerCase();
        final email = (u['email'] as String? ?? '').toLowerCase();
        return name.contains(q) || email.contains(q);
      }).toList();
    }
    return list;
  }

  Future<void> _toggleActive(Map<String, dynamic> user) async {
    final uid = user['uid'] as String?;
    if (uid == null) return;
    final current = user['isActive'] as bool? ?? true;
    final action = current ? 'vô hiệu hóa' : 'kích hoạt';
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('$action nhân viên?'),
        content: Text('Bạn có chắc muốn $action "${user['name'] ?? 'N/A'}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(current ? 'Vô hiệu hóa' : 'Kích hoạt')),
        ],
      ),
    );
    if (confirm != true) return;
    await _db.collection('users').doc(uid).update({'isActive': !current});
    setState(() {});
  }

  Future<void> _editUser(Map<String, dynamic> user) async {
    final uid = user['uid'] as String?;
    if (uid == null) return;
    final nameCtrl = TextEditingController(text: user['name'] as String? ?? '');
    String role = user['role'] as String? ?? 'Thủ kho';

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Sửa thông tin'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Họ tên'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: role,
                decoration: const InputDecoration(labelText: 'Vai trò'),
                items: ['Thủ kho', 'Kế toán', 'Quản lý'].map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                onChanged: (v) => setDialogState(() => role = v!),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
            FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Lưu')),
          ],
        ),
      ),
    );
    if (result != true) return;
    final name = nameCtrl.text.trim();
    if (name.isEmpty) return;
    await _db.collection('users').doc(uid).update({'name': name, 'role': role});
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final filtered = _filtered;
        if (constraints.maxWidth > 800) return _web(filtered);
        return _mobile(filtered);
      },
    );
  }

  Widget _mobile(List<Map<String, dynamic>> filtered) {
    if (widget.users.isEmpty) {
      return Center(child: Text('Chưa có nhân sự nào', style: TextStyle(color: AppColors.textMuted)));
    }

    final roles = widget.users
        .map((u) => u['role'] as String? ?? '')
        .where((r) => r.isNotEmpty)
        .toSet().toList()..sort();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                const Text('Bộ lọc: ', style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
                ChoiceChip(
                  label: Text('Tất cả', style: TextStyle(fontSize: 12, color: _filterRole == 'Tất cả' ? Colors.white : AppColors.textPrimary)),
                  selected: _filterRole == 'Tất cả',
                  onSelected: (_) => setState(() => _filterRole = 'Tất cả'),
                  selectedColor: Colors.blueGrey,
                  backgroundColor: const Color(0xFFE8ECF4),
                  visualDensity: VisualDensity.compact,
                ),
                const SizedBox(width: 6),
                ...roles.map((r) => Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ChoiceChip(
                    label: Text(r, style: TextStyle(fontSize: 12, color: _filterRole == r ? Colors.white : AppColors.textPrimary)),
                    selected: _filterRole == r,
                    onSelected: (_) => setState(() => _filterRole = r),
                    selectedColor: _chipColor(r),
                    backgroundColor: const Color(0xFFE8ECF4),
                    visualDensity: VisualDensity.compact,
                  ),
                )),
                const SizedBox(width: 12),
                ChoiceChip(
                  label: Text('Đã nghỉ', style: TextStyle(fontSize: 12, color: _showInactive ? Colors.white : AppColors.textPrimary)),
                  selected: _showInactive,
                  onSelected: (_) => setState(() => _showInactive = !_showInactive),
                  selectedColor: AppColors.red,
                  backgroundColor: const Color(0xFFE8ECF4),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: filtered.length,
            itemBuilder: (_, i) {
              final u = filtered[i];
              final name = u['name'] as String? ?? u['fullName'] as String? ?? 'N/A';
              final email = u['email'] as String? ?? '';
              final role = u['role'] as String? ?? '';
              final isActive = u['isActive'] as bool? ?? true;

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: Opacity(
                  opacity: isActive ? 1.0 : 0.5,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _chipColor(role).withValues(alpha: 0.1),
                      child: Icon(Icons.person, color: _chipColor(role)),
                    ),
                    title: Row(
                      children: [
                        Expanded(child: Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14), overflow: TextOverflow.ellipsis)),
                        const SizedBox(width: 8),
                        _RoleBadge(role),
                        if (!isActive) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: AppColors.red.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                            child: const Text('Đã nghỉ', style: TextStyle(color: AppColors.red, fontSize: 9, fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ],
                    ),
                    subtitle: Text(email, style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    trailing: widget.isReadOnly
                        ? Container(
                            width: 8, height: 8,
                            decoration: BoxDecoration(color: isActive ? AppColors.green : AppColors.textMuted, shape: BoxShape.circle),
                          )
                        : PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert, size: 20),
                            onSelected: (v) async {
                              if (v == 'edit') await _editUser(u);
                              if (v == 'toggle') await _toggleActive(u);
                            },
                            itemBuilder: (_) => [
                              const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, size: 18), SizedBox(width: 8), Text('Sửa')])),
                              PopupMenuItem(
                                value: 'toggle',
                                child: Row(
                                  children: [
                                    Icon(isActive ? Icons.block : Icons.check_circle, size: 18, color: isActive ? AppColors.red : AppColors.green),
                                    const SizedBox(width: 8),
                                    Text(isActive ? 'Vô hiệu hóa' : 'Kích hoạt'),
                                  ],
                                ),
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
  }

  Widget _web(List<Map<String, dynamic>> filtered) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(
                width: 260,
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Tìm tên hoặc email...',
                    prefixIcon: Icon(Icons.search, size: 20),
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                  ),
                  onChanged: (v) => setState(() => _search = v),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _filterRole,
                    style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                    items: [
                      'Tất cả',
                      ...widget.users
                          .map((u) => u['role'] as String? ?? '')
                          .where((r) => r.isNotEmpty)
                          .toSet().toList()..sort(),
                    ].map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                    onChanged: (v) => setState(() => _filterRole = v!),
                  ),
                ),
              ),
              FilterChip(
                label: Text('Đã nghỉ', style: TextStyle(fontSize: 12, color: _showInactive ? Colors.white : AppColors.textPrimary)),
                selected: _showInactive,
                onSelected: (_) => setState(() => _showInactive = !_showInactive),
                selectedColor: AppColors.red,
                backgroundColor: const Color(0xFFE8ECF4),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            '${filtered.length} nhân sự',
            style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
          ),
          const SizedBox(height: 10),
          WebTable(
            minWidth: 900,
            headers: const ['Họ tên', 'Email', 'Vai trò', 'Trạng thái', 'Thao tác'],
            rows: [
              for (final u in filtered)
                [
                  Text(
                    u['name'] as String? ?? u['fullName'] as String? ?? 'N/A',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(u['email'] as String? ?? '', style: const TextStyle(color: AppColors.textSecondary)),
                  _RoleBadge(u['role'] as String? ?? ''),
                  _StaffStatusChip(active: u['isActive'] as bool? ?? true),
                  widget.isReadOnly
                      ? Container(
                          width: 8, height: 8,
                          decoration: BoxDecoration(color: (u['isActive'] as bool? ?? true) ? AppColors.green : AppColors.textMuted, shape: BoxShape.circle),
                        )
                      : PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert, size: 20),
                          onSelected: (v) async {
                            if (v == 'edit') await _editUser(u);
                            if (v == 'toggle') await _toggleActive(u);
                          },
                          itemBuilder: (_) => [
                            const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, size: 18), SizedBox(width: 8), Text('Sửa')])),
                            PopupMenuItem(
                              value: 'toggle',
                              child: Row(
                                children: [
                                  Icon((u['isActive'] as bool? ?? true) ? Icons.block : Icons.check_circle, size: 18, color: (u['isActive'] as bool? ?? true) ? AppColors.red : AppColors.green),
                                  const SizedBox(width: 8),
                                  Text((u['isActive'] as bool? ?? true) ? 'Vô hiệu hóa' : 'Kích hoạt'),
                                ],
                              ),
                            ),
                          ],
                        ),
                ],
            ],
          ),
        ],
      ),
    );
  }

  Color _chipColor(String role) {
    switch (role) {
      case 'Thủ kho': return AppColors.primary;
      case 'Kế toán': return AppColors.orange;
      case 'Quản lý': return Colors.purple;
      default: return Colors.blueGrey;
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
      default: c = Colors.blueGrey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: c.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
      child: Text(role, style: TextStyle(color: c, fontSize: 10, fontWeight: FontWeight.w600)),
    );
  }
}

class _StaffStatusChip extends StatelessWidget {
  final bool active;
  const _StaffStatusChip({required this.active});

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.green : AppColors.red;
    final label = active ? 'Hoạt động' : 'Đã nghỉ';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color)),
    );
  }
}
