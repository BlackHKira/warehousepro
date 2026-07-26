import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../login_screen.dart';
import 'zone_management_screen.dart';

class _TabDef {
  final Widget? screen;
  final IconData icon;
  final String label;
  const _TabDef(this.screen, this.icon, this.label);
}

class WebShell extends StatefulWidget {
  const WebShell({super.key});

  @override
  State<WebShell> createState() => _WebShellState();
}

class _WebShellState extends State<WebShell> {
  int _selectedIndex = 0;

  static const _tabs = [
    _TabDef(null, Icons.dashboard_outlined, 'Tổng quan'),
    _TabDef(null, Icons.inventory_2_outlined, 'Tồn kho'),
    _TabDef(null, Icons.outbox_outlined, 'Lệnh xuất'),
    _TabDef(null, Icons.badge_outlined, 'Nhân viên'),
    _TabDef(null, Icons.bar_chart_outlined, 'Báo cáo'),
    _TabDef(ZoneManagementScreen(), Icons.map_outlined, 'Khu vực kho'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WarehousePro Admin'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            tooltip: 'Quản lý',
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Đăng xuất',
            onPressed: () async {
              await AuthService().signOut();
              if (!context.mounted) return;
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (i) => setState(() => _selectedIndex = i),
            labelType: NavigationRailLabelType.all,
            destinations: _tabs
                .map(
                  (t) => NavigationRailDestination(
                    icon: Icon(t.icon),
                    selectedIcon: Icon(t.icon),
                    label: Text(t.label),
                  ),
                )
                .toList(),
          ),
          const VerticalDivider(width: 1),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    final tab = _tabs[_selectedIndex];
    if (tab.screen != null) return tab.screen!;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.construction, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'Đang phát triển...',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 18),
          ),
        ],
      ),
    );
  }
}
