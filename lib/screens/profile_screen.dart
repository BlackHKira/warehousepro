import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/theme_provider.dart';
import '../providers/user_profile_provider.dart';
import '../services/auth_service.dart';
import '../services/device_info_service.dart';
import '../services/local_storage_service.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  Map<String, String> _deviceInfo = {};
  bool _loadingDevice = true;

  @override
  void initState() {
    super.initState();
    _loadDeviceInfo();
  }

  Future<void> _loadDeviceInfo() async {
    final info = await DeviceInfoService.getDeviceInfo();
    if (!mounted) return;
    setState(() {
      _deviceInfo = info;
      _loadingDevice = false;
    });
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc muốn đăng xuất khỏi tài khoản này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Huỷ'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    LocalStorageService().clearAll();
    await AuthService().signOut();
    if (!mounted) return;
    ref.read(userProfileProvider.notifier).state = null;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(userProfileProvider);
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Cài đặt & Tài khoản')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _header(profile?.name ?? 'Người dùng', profile?.email ?? '',
              profile?.rawRole ?? ''),
          const SizedBox(height: 16),
          _sectionCard(
            context,
            'Thông tin cá nhân',
            children: [
              _infoRow(context, Icons.person_outline, 'Họ và tên',
                  profile?.name ?? 'Người dùng'),
              _divider(scheme),
              _infoRow(context, Icons.email_outlined, 'Email',
                  profile?.email ?? ''),
              _divider(scheme),
              _infoRow(context, Icons.phone_outlined, 'Số điện thoại',
                  profile?.phone ?? 'Chưa cập nhật'),
              _divider(scheme),
              _infoRow(context, Icons.wc_outlined, 'Giới tính',
                  profile?.gender ?? 'Chưa cập nhật'),
              _divider(scheme),
              _infoRow(context, Icons.badge_outlined, 'Vai trò',
                  profile?.rawRole ?? ''),
            ],
          ),
          const SizedBox(height: 16),
          _sectionCard(
            context,
            'Giao diện',
            children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                secondary: const Icon(Icons.dark_mode_outlined),
                title: const Text(
                  'Chế độ tối',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                subtitle: Text(
                  isDark ? 'Đang bật' : 'Đang tắt',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.primaryLight : AppColors.textMuted,
                  ),
                ),
                value: isDark,
                onChanged: (value) {
                  ref.read(themeModeProvider.notifier).state =
                      value ? ThemeMode.dark : ThemeMode.light;
                  LocalStorageService().saveDarkMode(value);
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          _sectionCard(
            context,
            'Thông tin thiết bị',
            children: _loadingDevice
                ? [
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    ),
                  ]
                : [
                    _infoRow(context, Icons.devices_other, 'Nền tảng',
                        _deviceInfo['platform'] ?? 'Unknown'),
                    if (_deviceInfo['os'] != null) ...[
                      _divider(scheme),
                      _infoRow(context, Icons.language, 'Hệ điều hành',
                          _deviceInfo['os'] ?? ''),
                    ],
                    if (_deviceInfo['osVersion'] != null) ...[
                      _divider(scheme),
                      _infoRow(context, Icons.info_outline, 'Phiên bản OS',
                          _deviceInfo['osVersion'] ?? ''),
                    ],
                    if (_deviceInfo['model'] != null) ...[
                      _divider(scheme),
                      _infoRow(context, Icons.smartphone_outlined, 'Thiết bị',
                          _deviceInfo['model'] ?? ''),
                    ],
                    if (_deviceInfo['brand'] != null) ...[
                      _divider(scheme),
                      _infoRow(context, Icons.branding_watermark, 'Hãng',
                          _deviceInfo['brand'] ?? ''),
                    ],
                    if (_deviceInfo['sdkInt'] != null) ...[
                      _divider(scheme),
                      _infoRow(context, Icons.memory, 'API level',
                          _deviceInfo['sdkInt'] ?? ''),
                    ],
                    if (_deviceInfo['browser'] != null) ...[
                      _divider(scheme),
                      _infoRow(context, Icons.public, 'Trình duyệt',
                          _deviceInfo['browser'] ?? ''),
                    ],
                  ],
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: _logout,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.red,
              side: const BorderSide(color: AppColors.red),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.logout, size: 20),
            label: const Text(
              'Đăng xuất',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _header(String name, String email, String role) {
    final scheme = Theme.of(context).colorScheme;
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'U';
    return Row(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: scheme.primaryContainer,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Center(
            child: Text(
              initial,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: scheme.onPrimaryContainer,
                fontSize: 26,
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                email,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textMuted,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                role,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _sectionCard(
    BuildContext context,
    String title, {
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }

  Widget _infoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.textMuted),
        const SizedBox(width: 12),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 14, color: AppColors.textMuted),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  value,
                  textAlign: TextAlign.right,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _divider(ColorScheme scheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Divider(height: 1, color: scheme.outlineVariant),
    );
  }
}
