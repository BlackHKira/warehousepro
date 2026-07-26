import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/user_profile_provider.dart';
import '../services/auth_service.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final isAdmin = widget.initialRole != 'Thủ kho';
      ref.read(userProfileProvider.notifier).state = UserProfileState(
        name: isAdmin ? 'Admin' : 'User',
        email: isAdmin ? 'admin@whpro.com' : 'user@whpro.com',
        role: isAdmin ? AppRole.admin : AppRole.staff,
        rawRole: widget.initialRole,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(userProfileProvider);
    final isAdmin = profile?.isAdmin ?? (widget.initialRole != 'Thủ kho');

    final tabs = isAdmin ? _adminTabs : _staffTabs;
    final selectedIndex = _selectedIndex < tabs.length ? _selectedIndex : 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(tabs[selectedIndex].label),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.person_outline),
            onSelected: (value) async {
              switch (value) {
                case 'info':
                  final profile = ref.read(userProfileProvider);
                  if (!context.mounted) return;
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Thông tin tài khoản'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _infoRow(
                            Icons.person,
                            'Họ tên',
                            profile?.name ?? 'Người dùng',
                          ),
                          const SizedBox(height: 8),
                          _infoRow(Icons.email, 'Email', profile?.email ?? ''),
                          const SizedBox(height: 8),
                          _infoRow(
                            Icons.badge,
                            'Vai trò',
                            profile?.rawRole ?? '',
                          ),
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
                case 'settings':
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Đang phát triển'),
                      behavior: SnackBarBehavior.floating,
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
              const PopupMenuItem<String>(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings_outlined, size: 20),
                    SizedBox(width: 10),
                    Text('Cài đặt'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 20, color: Colors.red),
                    SizedBox(width: 10),
                    Text('Đăng xuất', style: TextStyle(color: Colors.red)),
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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFFe9873c),
        unselectedItemColor: Colors.grey,
        items: tabs
            .map(
              (t) => BottomNavigationBarItem(
                icon: Icon(t.icon),
                activeIcon: Icon(t.activeIcon),
                label: t.label,
              ),
            )
            .toList(),
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
  _TabDef(
    DashboardScreen(embedded: true),
    Icons.dashboard_outlined,
    Icons.dashboard,
    'Home',
  ),
  _TabDef(
    ImportScreen(embedded: true),
    Icons.add_box_outlined,
    Icons.add_box,
    'Nhập',
  ),
  _TabDef(
    ExportScreen(embedded: true),
    Icons.outbox_outlined,
    Icons.outbox,
    'Xuất',
  ),
  _TabDef(SearchScreen(embedded: true), Icons.search, Icons.search, 'Tra cứu'),
];

const _adminTabs = [
  _TabDef(
    AdminInventoryScreen(embedded: true),
    Icons.inventory_2_outlined,
    Icons.inventory_2,
    'Tồn kho',
  ),
  _TabDef(
    AdminReportsScreen(embedded: true),
    Icons.bar_chart_outlined,
    Icons.bar_chart,
    'Báo cáo',
  ),
  _TabDef(
    AdminStaffScreen(embedded: true),
    Icons.badge_outlined,
    Icons.badge,
    'Nhân sự',
  ),
  _TabDef(
    AdminZonesScreen(embedded: true),
    Icons.map_outlined,
    Icons.map,
    'Khu vực',
  ),
];

Widget _infoRow(IconData icon, String label, String value) {
  return Row(
    children: [
      Icon(icon, size: 20, color: Colors.grey.shade600),
      const SizedBox(width: 10),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
        ],
      ),
    ],
  );
}
