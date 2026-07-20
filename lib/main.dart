import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/product_screen.dart';
import 'screens/warehouse_screen.dart';
import 'screens/inventory_screen.dart';

void main() {
  runApp(const WarehouseProDemo());
}

class WarehouseProDemo extends StatefulWidget {
  const WarehouseProDemo({super.key});

  @override
  State<WarehouseProDemo> createState() => _WarehouseProDemoState();
}

class _WarehouseProDemoState extends State<WarehouseProDemo> {
  PaletteType _currentPalette = PaletteType.blue;

  void _switchPalette(PaletteType type) {
    setState(() => _currentPalette = type);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WarehousePro',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.getTheme(_currentPalette),
      home: MainShell(
        currentPalette: _currentPalette,
        onSwitchPalette: _switchPalette,
      ),
    );
  }
}

class MainShell extends StatefulWidget {
  final PaletteType currentPalette;
  final ValueChanged<PaletteType> onSwitchPalette;

  const MainShell({
    super.key,
    required this.currentPalette,
    required this.onSwitchPalette,
  });

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;
  bool _loggedIn = false;

  final List<Widget> _screens = [];

  @override
  void initState() {
    super.initState();
    _screens.addAll([
      const DashboardScreen(),
      const ProductScreen(),
      const WarehouseScreen(),
      const InventoryScreen(),
    ]);
  }

  void _login() {
    setState(() => _loggedIn = true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (!_loggedIn) {
      return LoginScreen(onLogin: _login);
    }

    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        indicatorColor: theme.colorScheme.secondaryContainer,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Dashboard'),
          NavigationDestination(icon: Icon(Icons.inventory_2_outlined), selectedIcon: Icon(Icons.inventory_2), label: 'Sản phẩm'),
          NavigationDestination(icon: Icon(Icons.compare_arrows_outlined), selectedIcon: Icon(Icons.compare_arrows), label: 'Nhập/Xuất'),
          NavigationDestination(icon: Icon(Icons.assignment_outlined), selectedIcon: Icon(Icons.assignment), label: 'Kiểm kê'),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showPalettePicker(),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        icon: const Icon(Icons.palette),
        label: const Text('Đổi màu'),
      ),
    );
  }

  void _showPalettePicker() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Chọn bảng màu', style: Theme.of(ctx).textTheme.titleLarge),
            const SizedBox(height: 20),
            _PaletteOption(
              label: 'Xanh dương – Cam (Chuyên nghiệp)',
              colors: [const Color(0xFF1565C0), const Color(0xFFFF6F00)],
              isSelected: widget.currentPalette == PaletteType.blue,
              onTap: () { widget.onSwitchPalette(PaletteType.blue); Navigator.pop(ctx); },
            ),
            const SizedBox(height: 12),
            _PaletteOption(
              label: 'Xanh lá – Trắng (Kho vận)',
              colors: [const Color(0xFF2E7D32), const Color(0xFFFFA000)],
              isSelected: widget.currentPalette == PaletteType.green,
              onTap: () { widget.onSwitchPalette(PaletteType.green); Navigator.pop(ctx); },
            ),
            const SizedBox(height: 12),
            _PaletteOption(
              label: 'Xanh than – Mint (Cao cấp)',
              colors: [const Color(0xFF263238), const Color(0xFF00BFA5)],
              isSelected: widget.currentPalette == PaletteType.dark,
              onTap: () { widget.onSwitchPalette(PaletteType.dark); Navigator.pop(ctx); },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _PaletteOption extends StatelessWidget {
  final String label;
  final List<Color> colors;
  final bool isSelected;
  final VoidCallback onTap;

  const _PaletteOption({
    required this.label,
    required this.colors,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            ...colors.map((c) => Container(
              width: 28, height: 28,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(color: c, shape: BoxShape.circle),
            )),
            const SizedBox(width: 8),
            Expanded(child: Text(label, style: const TextStyle(fontSize: 15))),
            if (isSelected) Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary),
          ],
        ),
      ),
    );
  }
}
