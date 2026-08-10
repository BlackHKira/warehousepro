import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/warehouse_provider.dart';
import '../providers/user_profile_provider.dart';
import '../services/auth_service.dart';
import '../services/local_storage_service.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';

class WebTab {
  final Widget screen;
  final IconData icon;
  final String label;
  final String path;
  final String title;
  final String description;
  const WebTab({
    required this.screen,
    required this.icon,
    required this.label,
    required this.path,
    required this.title,
    required this.description,
  });
}

class WebShell extends ConsumerStatefulWidget {
  final List<WebTab> tabs;
  final int selectedIndex;
  final ValueChanged<int> onTabChanged;
  final String roleLabel;
  final String roleName;
  final String rolePath;
  const WebShell({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onTabChanged,
    required this.roleLabel,
    required this.roleName,
    required this.rolePath,
  });

  @override
  ConsumerState<WebShell> createState() => _WebShellState();
}

class _WebShellState extends ConsumerState<WebShell> {
  Future<void> _logout() async {
    LocalStorageService().clearAll();
    await AuthService().signOut();
    if (!mounted) return;
    ref.read(userProfileProvider.notifier).state = null;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final safeIndex = widget.selectedIndex < widget.tabs.length
        ? widget.selectedIndex
        : 0;
    final active = widget.tabs[safeIndex];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _sidebar(safeIndex),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _workHeader(active),
                Expanded(
                  child: IndexedStack(
                    index: safeIndex,
                    children: widget.tabs.map((t) => t.screen).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sidebar(int safeIndex) {
    return Container(
      width: 200,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      decoration: const BoxDecoration(
        color: Color(0xFFFCFDFF),
        border: Border(right: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 9),
            child: Row(
              children: const [
                Icon(Icons.warehouse_outlined, size: 20, color: AppColors.primary),
                SizedBox(width: 6),
                Text(
                  'Warehouse',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                ),
                Text(
                  'Pro',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(9, 18, 9, 6),
            child: Text(
              widget.roleLabel,
              style: const TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                color: AppColors.textMuted,
                letterSpacing: 0.6,
              ),
            ),
          ),
          ...widget.tabs.asMap().entries.map(
                (e) => _navButton(e.key, safeIndex),
              ),
          const Spacer(),
          _syncTile(),
          const Divider(height: 20),
          _userTile(),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _logout,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.red,
              side: const BorderSide(color: AppColors.border),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(9),
              ),
              padding: const EdgeInsets.symmetric(vertical: 10),
            ),
            icon: const Icon(Icons.logout, size: 18),
            label: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
  }

  Widget _navButton(int index, int selected) {
    final t = widget.tabs[index];
    final isActive = index == selected;
    return Material(
      color: isActive ? AppColors.primaryLight : Colors.transparent,
      borderRadius: BorderRadius.circular(9),
      child: InkWell(
        borderRadius: BorderRadius.circular(9),
        onTap: () => widget.onTabChanged(index),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
          child: Row(
            children: [
              Icon(
                t.icon,
                size: 20,
                color: isActive ? AppColors.primary : AppColors.textSecondary,
              ),
              const SizedBox(width: 9),
              Text(
                t.label,
                style: TextStyle(
                  fontSize: 13.5,
                  color: isActive ? AppColors.primary : AppColors.textSecondary,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _syncTile() {
    final warehouse = ref.watch(warehouseProvider);
    if (warehouse.isSyncing) {
      return _tileRow(
        icon: const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        text: 'Đang đồng bộ',
        color: AppColors.orange,
      );
    }
    if (warehouse.pendingSync > 0) {
      return InkWell(
        onTap: () => ref.read(warehouseProvider.notifier).syncData(),
        borderRadius: BorderRadius.circular(9),
        child: _tileRow(
          icon: const Icon(Icons.sync_problem, size: 18),
          text: '${warehouse.pendingSync} phiếu chờ sync',
          color: AppColors.orange,
        ),
      );
    }
    return _tileRow(
      icon: const Icon(Icons.cloud_done_outlined, size: 18),
      text: 'Đã đồng bộ',
      color: AppColors.green,
    );
  }

  Widget _tileRow({
    required Widget icon,
    required String text,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8),
      child: Row(
        children: [
          icon,
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: color),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _userTile() {
    final profile = ref.watch(userProfileProvider);
    final name = profile?.name ?? 'Người dùng';
    final email = profile?.email ?? '';
    final role = profile?.rawRole ?? widget.roleName;
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Center(
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : 'U',
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
                fontSize: 14,
              ),
            ),
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                email.isEmpty ? role : email,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textMuted,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _workHeader(WebTab active) {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 16, 22, 14),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                widget.roleName,
                style: const TextStyle(
                  fontSize: 12.5,
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.chevron_right, size: 14, color: AppColors.textMuted),
              const SizedBox(width: 6),
              Text(
                active.label,
                style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            active.title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            active.description,
            style: const TextStyle(fontSize: 13.5, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}
