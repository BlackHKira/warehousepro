import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../providers/user_profile_provider.dart';
import '../providers/warehouse_provider.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import 'dashboard_screen.dart';
import 'import_screen.dart';
import 'export_screen.dart';
import 'search_screen.dart';
import 'login_screen.dart';
import 'admin_inventory_screen.dart';
import 'admin_reports_screen.dart';
import 'admin_staff_screen.dart';
import 'admin_zones_screen.dart';

class MainShell extends ConsumerStatefulWidget {
  final String initialRole;
  const MainShell({super.key, required this.initialRole});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await _loadProfile();
    });
  }

  Future<void> _loadProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    String name = '';
    String email = user?.email ?? '';
    String role = widget.initialRole;

    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instanceFor(
          app: Firebase.app(),
          databaseId: 'warehousepro-db',
        ).collection('users').doc(user.uid).get();

        if (doc.exists) {
          final data = doc.data()!;
          name = data['name'] as String? ?? '';
          email = data['email'] as String? ?? email;
          final firestoreRole = data['role'] as String? ?? '';
          if (firestoreRole == 'Quản lý' || firestoreRole == 'Kế toán') role = firestoreRole;
        }
      } catch (_) {}
    }

    if (name.isEmpty) {
      name = role == 'Thủ kho' ? 'User' : role == 'Kế toán' ? 'Kế toán' : 'Admin';
    }
    if (email.isEmpty) {
      email = role == 'Thủ kho' ? 'user@whpro.com' : role == 'Kế toán' ? 'ke toan@whpro.com' : 'admin@whpro.com';
    }

    AppRole mappedRole;
    switch (role) {
      case 'Kế toán':
        mappedRole = AppRole.accountant;
      case 'Quản lý':
        mappedRole = AppRole.admin;
      default:
        mappedRole = AppRole.staff;
    }

    if (!mounted) return;
    ref.read(userProfileProvider.notifier).state = UserProfileState(
      name: name,
      email: email,
      role: mappedRole,
      rawRole: role,
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(userProfileProvider);
    final isAdmin = profile?.isAdmin ?? (widget.initialRole == 'Quản lý');
    final isAccountant = profile?.isAccountant ?? (widget.initialRole == 'Kế toán');

    final tabs = isAdmin ? _adminTabs : isAccountant ? _accountantTabs : _staffTabs;
    final selectedIndex = _selectedIndex < tabs.length ? _selectedIndex : 0;
    final warehouse = ref.watch(warehouseProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(tabs[selectedIndex].label),
        actions: [
          if (warehouse.isSyncing)
            const Padding(
              padding: EdgeInsets.only(right: 8),
              child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
            )
          else if (warehouse.pendingSync > 0)
            GestureDetector(
              onTap: () => ref.read(warehouseProvider.notifier).syncData(),
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: AppColors.orange.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.sync_problem, size: 16, color: AppColors.orange),
                    const SizedBox(width: 4),
                    Text('${warehouse.pendingSync}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.orange, fontSize: 13)),
                  ],
                ),
              ),
            )
          else
            GestureDetector(
              onTap: () => ref.read(warehouseProvider.notifier).syncData(),
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: AppColors.green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.sync, size: 16, color: AppColors.green),
                    SizedBox(width: 4),
                    Text('Đã sync', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.green, fontSize: 13)),
                  ],
                ),
              ),
            ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.person_outline),
            onSelected: (value) async {
              switch (value) {
                case 'info':
                  final p = ref.read(userProfileProvider);
                  if (!context.mounted) return;
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Thông tin tài khoản'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _infoRow(Icons.person, 'Họ tên', p?.name ?? 'Người dùng'),
                          const SizedBox(height: 8),
                          _infoRow(Icons.email, 'Email', p?.email ?? ''),
                          const SizedBox(height: 8),
                          _infoRow(Icons.badge, 'Vai trò', p?.rawRole ?? ''),
                        ],
                      ),
                      actions: [
                        FilledButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Đóng'),
                        ),
                      ],
                    ),
                  );
                case 'logout':
                  await AuthService().signOut();
                  if (!context.mounted) return;
                  ref.read(userProfileProvider.notifier).state = null;
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem<String>(
                value: 'info',
                child: Row(
                  children: [
                    Icon(Icons.person_outline, size: 20),
                    SizedBox(width: 10),
                    Text('Thông tin'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 20, color: AppColors.red),
                    SizedBox(width: 10),
                    Text('Đăng xuất', style: TextStyle(color: AppColors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: IndexedStack(
        index: selectedIndex,
        children: tabs.map((t) => t.screen).toList(),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.08),
              blurRadius: 20,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: NavigationBar(
            selectedIndex: selectedIndex,
            onDestinationSelected: (i) => setState(() => _selectedIndex = i),
            backgroundColor: Colors.transparent,
            elevation: 0,
            height: 70,
            indicatorColor: AppColors.primaryLight,
            labelTextStyle: WidgetStateProperty.resolveWith((states) {
              final isSelected = states.contains(WidgetState.selected);
              return TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? AppColors.primary : AppColors.textMuted,
              );
            }),
            destinations: tabs
                .map(
                  (t) => NavigationDestination(
                    icon: Icon(t.icon),
                    selectedIcon: Icon(t.activeIcon),
                    label: t.label,
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }
}

class _TabDef {
  final Widget screen;
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _TabDef(this.screen, this.icon, this.activeIcon, this.label);
}

const _staffTabs = [
  _TabDef(DashboardScreen(embedded: true), Icons.dashboard_outlined, Icons.dashboard, 'Kho'),
  _TabDef(ImportScreen(embedded: true), Icons.add_box_outlined, Icons.add_box, 'Nhập'),
  _TabDef(ExportScreen(embedded: true), Icons.outbox_outlined, Icons.outbox, 'Xuất'),
  _TabDef(SearchScreen(embedded: true), Icons.search, Icons.search, 'Tra cứu'),
];

const _accountantTabs = [
  _TabDef(AdminInventoryScreen(embedded: true), Icons.inventory_2_outlined, Icons.inventory_2, 'Tồn kho'),
  _TabDef(AdminReportsScreen(embedded: true), Icons.bar_chart_outlined, Icons.bar_chart, 'Báo cáo'),
];

const _adminTabs = [
  _TabDef(AdminInventoryScreen(embedded: true), Icons.inventory_2_outlined, Icons.inventory_2, 'Tồn kho'),
  _TabDef(AdminReportsScreen(embedded: true), Icons.bar_chart_outlined, Icons.bar_chart, 'Báo cáo'),
  _TabDef(AdminStaffScreen(embedded: true), Icons.badge_outlined, Icons.badge, 'Nhân sự'),
  _TabDef(AdminZonesScreen(embedded: true), Icons.map_outlined, Icons.map, 'Khu vực'),
];

Widget _infoRow(IconData icon, String label, String value) {
  return Row(
    children: [
      Icon(icon, size: 20, color: AppColors.textMuted),
      const SizedBox(width: 10),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        ],
      ),
    ],
  );
}
