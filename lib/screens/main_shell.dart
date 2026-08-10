import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../providers/user_profile_provider.dart';
import '../providers/selected_tab_provider.dart';
import '../providers/warehouse_provider.dart';
import '../services/auth_service.dart';
import '../services/local_storage_service.dart';
import '../theme/app_theme.dart';
import 'dashboard_screen.dart';
import 'import_screen.dart';
import 'export_screen.dart';
import 'search_screen.dart';
import 'delivery_screen.dart';
import 'login_screen.dart';
import 'admin_inventory_screen.dart';
import 'admin_reports_screen.dart';
import 'admin_staff_screen.dart';
import 'admin_zones_screen.dart';
import 'analyst_dashboard_screen.dart';
import 'transaction_history_screen.dart';
import 'report_export_screen.dart';
import 'finance_screen.dart';
import 'web_shell.dart';

class MainShell extends ConsumerStatefulWidget {
  final String initialRole;
  const MainShell({super.key, required this.initialRole});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final role = _resolveRole(widget.initialRole);
      final isAdmin = role == AppRole.admin;
      ref.read(userProfileProvider.notifier).state = UserProfileState(
        name: isAdmin ? 'Admin' : 'User',
        email: isAdmin ? 'admin@whpro.com' : 'user@whpro.com',
        role: role,
        rawRole: widget.initialRole,
      );
      final savedTab = LocalStorageService().getTabIndex();
      ref.read(selectedTabProvider.notifier).state = savedTab;

      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        try {
          final db = FirebaseFirestore.instanceFor(
            app: Firebase.app(),
            databaseId: 'warehousepro-db',
          );
          final snapshot = await db
              .collection('users')
              .where('email', isEqualTo: user.email)
              .limit(1)
              .get();
          if (snapshot.docs.isNotEmpty && mounted) {
            final data = snapshot.docs.first.data();
            final appRole = data['role'] != null
                ? _mapRole(data['role'] as String)
                : (isAdmin ? AppRole.admin : AppRole.staff);
            ref.read(userProfileProvider.notifier).state = UserProfileState(
              name: data['name'] ?? '',
              email: data['email'] ?? '',
              role: appRole,
              rawRole: data['role'] ?? widget.initialRole,
              phone: data['phone'] ?? '',
              gender: data['gender'] ?? '',
            );
          }
        } catch (_) {}
      }
    });
  }

  AppRole _mapRole(String rawRole) {
    switch (rawRole) {
      case 'Quản lý':
      case 'Quản lý kho':
      case 'admin':
      case 'manager':
        return AppRole.admin;
      case 'Kế toán':
      case 'accountant':
        return AppRole.accountant;
      case 'Thủ kho':
      case 'staff':
      default:
        return AppRole.staff;
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(userProfileProvider);
    final role = profile?.role ?? _resolveRole(widget.initialRole);

    final tabs = switch (role) {
      AppRole.admin => _adminTabs,
      AppRole.accountant => _analystTabs,
      AppRole.staff => _staffTabs,
    };
    final selectedIndex = ref.watch(selectedTabProvider);
    final safeIndex = selectedIndex < tabs.length ? selectedIndex : 0;
    final warehouse = ref.watch(warehouseProvider);

    if (kIsWeb && (role == AppRole.accountant || role == AppRole.admin)) {
      final webTabs =
          role == AppRole.accountant ? _analystWebTabs : _adminWebTabs;
      return WebShell(
        tabs: webTabs,
        selectedIndex: safeIndex,
        onTabChanged: (i) {
          ref.read(selectedTabProvider.notifier).state = i;
          LocalStorageService().saveTabIndex(i);
        },
        roleLabel: role == AppRole.accountant ? 'KẾ TOÁN' : 'QUẢN LÝ',
        roleName: role == AppRole.accountant ? 'Kế toán' : 'Admin',
        rolePath: role == AppRole.accountant ? 'accountant' : 'admin',
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(tabs[safeIndex].label),
        actions: [
          if (warehouse.isSyncing)
            const Padding(
              padding: EdgeInsets.only(right: 8),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else if (warehouse.pendingSync > 0)
            GestureDetector(
              onTap: () => ref.read(warehouseProvider.notifier).syncData(),
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.sync_problem,
                      size: 16,
                      color: AppColors.orange,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${warehouse.pendingSync}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.orange,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            GestureDetector(
              onTap: () => ref.read(warehouseProvider.notifier).syncData(),
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.sync, size: 16, color: AppColors.green),
                    SizedBox(width: 4),
                    Text(
                      'Đã sync',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.green,
                        fontSize: 13,
                      ),
                    ),
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
                          _infoRow(
                            Icons.person,
                            'Họ và tên',
                            p?.name ?? 'Người dùng',
                          ),
                          const SizedBox(height: 8),
                          _infoRow(Icons.email, 'Gmail', p?.email ?? ''),
                          const SizedBox(height: 8),
                          _infoRow(Icons.phone, 'Số điện thoại', p?.phone ?? ''),
                          const SizedBox(height: 8),
                          _infoRow(Icons.wc, 'Giới tính', p?.gender ?? ''),
                          const SizedBox(height: 8),
                          _infoRow(Icons.badge, 'Vị trí', p?.rawRole ?? ''),
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
                  LocalStorageService().clearAll();
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
                    Text('Xem thông tin'),
                  ],
                ),
              ),
              if (role == AppRole.admin)
                const PopupMenuItem<String>(
                  value: 'migration',
                  child: Row(
                    children: [
                      Icon(Icons.sync_alt, size: 20),
                      SizedBox(width: 10),
                      Text('Migration stockByZone'),
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
        index: safeIndex,
        children: tabs.map((t) => t.screen).toList(),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: safeIndex,
        onDestinationSelected: (i) {
          if (i == 4) {
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('Chú ý'),
                content: const Text('Trang chỉ dành cho shipper!!!'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Thoát'),
                  ),
                  FilledButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ref.read(selectedTabProvider.notifier).state = i;
                      LocalStorageService().saveTabIndex(i);
                    },
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
            return;
          }
          ref.read(selectedTabProvider.notifier).state = i;
          LocalStorageService().saveTabIndex(i);
        },
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
    'Kho',
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
  _TabDef(
    DeliveryScreen(embedded: true),
    Icons.local_shipping_outlined,
    Icons.local_shipping,
    'Giao hàng',
  ),
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

const _analystTabs = [
  _TabDef(
    AnalystDashboardScreen(embedded: true),
    Icons.dashboard_outlined,
    Icons.dashboard,
    'Tổng quan',
  ),
  _TabDef(
    AdminInventoryScreen(embedded: true),
    Icons.inventory_2_outlined,
    Icons.inventory_2,
    'Tồn kho',
  ),
  _TabDef(
    FinanceScreen(embedded: true),
    Icons.account_balance_outlined,
    Icons.account_balance,
    'Chi phí',
  ),
  _TabDef(
    AdminReportsScreen(embedded: true),
    Icons.bar_chart_outlined,
    Icons.bar_chart,
    'Báo cáo',
  ),
  _TabDef(
    TransactionHistoryScreen(embedded: true),
    Icons.history_outlined,
    Icons.history,
    'Lịch sử',
  ),
  _TabDef(
    ReportExportScreen(embedded: true),
    Icons.file_download_outlined,
    Icons.file_download,
    'Xuất báo cáo',
  ),
];

const _analystWebTabs = [
  WebTab(
    screen: AnalystDashboardScreen(embedded: true),
    icon: Icons.dashboard_outlined,
    label: 'Tổng quan',
    path: '',
    title: 'Tổng quan tài chính',
    description: 'Tổng giá trị tồn kho, số phiếu nhập/xuất trong tháng, cảnh báo sắp hết.',
  ),
  WebTab(
    screen: AdminInventoryScreen(embedded: true),
    icon: Icons.inventory_2_outlined,
    label: 'Tồn kho',
    path: 'inventory',
    title: 'Tồn kho — Chế độ kế toán',
    description: 'Xem tồn kho theo sản phẩm và khu vực, chỉ đọc không chỉnh sửa.',
  ),
  WebTab(
    screen: FinanceScreen(embedded: true),
    icon: Icons.account_balance_outlined,
    label: 'Chi phí',
    path: 'finance',
    title: 'Chi phí & Giá trị kho',
    description: 'Tổng quan giá trị tồn kho theo giá nhập/bán, đã chi và đã thu hôm nay.',
  ),
  WebTab(
    screen: AdminReportsScreen(embedded: true),
    icon: Icons.bar_chart_outlined,
    label: 'Báo cáo',
    path: 'reports',
    title: 'Báo cáo xuất/nhập',
    description: 'Thống kê nhập/xuất theo tháng, giá trị theo khu vực.',
  ),
  WebTab(
    screen: TransactionHistoryScreen(embedded: true),
    icon: Icons.history_outlined,
    label: 'Lịch sử',
    path: 'history',
    title: 'Lịch sử giao dịch',
    description: 'Toàn bộ phiếu nhập/xuất, lọc theo khoảng ngày và loại phiếu.',
  ),
  WebTab(
    screen: ReportExportScreen(embedded: true),
    icon: Icons.file_download_outlined,
    label: 'Xuất báo cáo',
    path: 'export',
    title: 'Xuất báo cáo Excel',
    description: 'Chọn loại báo cáo và khoảng thời gian để xuất file .xlsx.',
  ),
];

const _adminWebTabs = [
  WebTab(
    screen: AdminInventoryScreen(embedded: true),
    icon: Icons.inventory_2_outlined,
    label: 'Tồn kho',
    path: 'inventory',
    title: 'Tồn kho',
    description: 'Quản lý tồn kho theo sản phẩm và khu vực.',
  ),
  WebTab(
    screen: AdminReportsScreen(embedded: true),
    icon: Icons.bar_chart_outlined,
    label: 'Báo cáo',
    path: 'reports',
    title: 'Báo cáo xuất/nhập',
    description: 'Thống kê nhập/xuất và tồn kho theo khu vực.',
  ),
  WebTab(
    screen: AdminStaffScreen(embedded: true),
    icon: Icons.badge_outlined,
    label: 'Nhân sự',
    path: 'staff',
    title: 'Quản lý nhân sự',
    description: 'Quản lý tài khoản và phân quyền nhân sự.',
  ),
  WebTab(
    screen: AdminZonesScreen(embedded: true),
    icon: Icons.map_outlined,
    label: 'Khu vực',
    path: 'zones',
    title: 'Quản lý khu vực',
    description: 'Quản lý các khu vực trong kho.',
  ),
];

AppRole _resolveRole(String rawRole) {
  switch (rawRole) {
    case 'Quản lý':
    case 'Quản lý kho':
    case 'admin':
    case 'manager':
      return AppRole.admin;
    case 'Kế toán':
    case 'accountant':
      return AppRole.accountant;
    case 'Thủ kho':
    case 'staff':
    default:
      return AppRole.staff;
  }
}

Widget _infoRow(IconData icon, String label, String value) {
  return Row(
    children: [
      Icon(icon, size: 20, color: AppColors.textMuted),
      const SizedBox(width: 10),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 11, color: AppColors.textMuted),
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
