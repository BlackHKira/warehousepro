import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../models/product.dart';
import '../providers/product_provider.dart';
import '../providers/budget_provider.dart';
import '../theme/app_theme.dart';

class FinanceScreen extends ConsumerWidget {
  final bool embedded;
  const FinanceScreen({super.key, this.embedded = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productsProvider);
    final body = productsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Lỗi: $e')),
      data: (products) => _FinanceBody(products: products),
    );

    if (embedded) return body;
    return Scaffold(appBar: AppBar(title: const Text('Chi phí & Giá trị kho')), body: body);
  }
}

class _FinanceBody extends ConsumerStatefulWidget {
  final List<Product> products;
  const _FinanceBody({required this.products});

  @override
  ConsumerState<_FinanceBody> createState() => _FinanceBodyState();
}

class _FinanceBodyState extends ConsumerState<_FinanceBody> {
  bool _loadingTxns = true;
  double _totalCostToday = 0;
  double _totalRevenueToday = 0;
  int _importCount = 0;
  int _exportCount = 0;
  List<Map<String, dynamic>> _todayImportTxns = [];
  List<Map<String, dynamic>> _todayExportTxns = [];

  @override
  void initState() {
    super.initState();
    _loadTodayTransactions();
  }

  Future<void> _loadTodayTransactions() async {
    try {
      final db = FirebaseFirestore.instanceFor(
        app: Firebase.app(),
        databaseId: 'warehousepro-db',
      );
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final snapshot = await db
          .collection('stock_transactions')
          .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('createdAt', isLessThan: Timestamp.fromDate(endOfDay))
          .get();

      double cost = 0;
      double revenue = 0;
      int imports = 0;
      int exports = 0;
      final importTxns = <Map<String, dynamic>>[];
      final exportTxns = <Map<String, dynamic>>[];

      for (final doc in snapshot.docs) {
        final data = doc.data();
        data['id'] = doc.id;
        final type = data['type'] as String?;
        final products = data['products'] as List<dynamic>? ?? [];

        if (type == 'import') {
          imports++;
          double txnTotal = 0;
          for (final item in products) {
            if (item is Map<String, dynamic>) {
              final barcode = item['barcode'] as String? ?? '';
              final quantity = (item['quantity'] as num?)?.toInt() ?? 0;
              final product = widget.products.where((p) => p.barcode == barcode).firstOrNull;
              if (product != null) txnTotal += quantity * product.unitPrice;
            }
          }
          cost += txnTotal;
          data['_txnTotal'] = txnTotal.toInt();
          importTxns.add(data);
        } else if (type == 'export') {
          exports++;
          double txnTotal = 0;
          for (final item in products) {
            if (item is Map<String, dynamic>) {
              final barcode = item['barcode'] as String? ?? '';
              final quantity = (item['quantity'] as num?)?.toInt() ?? 0;
              final product = widget.products.where((p) => p.barcode == barcode).firstOrNull;
              if (product != null) txnTotal += quantity * product.exportPrice;
            }
          }
          revenue += txnTotal;
          data['_txnTotal'] = txnTotal.toInt();
          exportTxns.add(data);
        }
      }

      if (mounted) {
        setState(() {
          _totalCostToday = cost;
          _totalRevenueToday = revenue;
          _importCount = imports;
          _exportCount = exports;
          _todayImportTxns = importTxns;
          _todayExportTxns = exportTxns;
          _loadingTxns = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loadingTxns = false);
    }
  }

  void _showTxnSheet(BuildContext context, String title, List<Map<String, dynamic>> txns, bool isImport) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (ctx, scrollCtrl) => Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    isImport ? Icons.arrow_downward : Icons.arrow_upward,
                    color: isImport ? AppColors.errorDark : AppColors.warningDark,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                  Text('${txns.length} phiếu', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                controller: scrollCtrl,
                itemCount: txns.length,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemBuilder: (ctx, i) => _TxnTile(txn: txns[i], isImport: isImport, products: widget.products),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final products = widget.products;

    final totalStockImport = products.fold<int>(0, (total, p) => total + p.stock * p.unitPrice);
    final totalStockExport = products.fold<int>(0, (total, p) => total + p.stock * p.exportPrice);
    final grossProfit = totalStockExport - totalStockImport;

    final sortedProducts = List<Product>.from(products)
      ..sort((a, b) => (b.stock * b.unitPrice).compareTo(a.stock * a.unitPrice));

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Chi phí & Giá trị kho', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text('Tổng quan giá trị tồn kho và giao dịch hôm nay', style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 16),

        // 4 summary cards
        LayoutBuilder(
          builder: (context, constraints) {
            final crossCount = constraints.maxWidth > 800 ? 4 : (constraints.maxWidth > 500 ? 2 : 2);
            final childAspect = constraints.maxWidth > 800 ? 1.8 : (constraints.maxWidth > 500 ? 1.6 : 1.5);
            return GridView.count(
              crossAxisCount: crossCount,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: childAspect,
              children: [
                _SummaryCard(
                  label: 'Tồn kho (giá nhập)',
                  value: _formatCurrency(totalStockImport),
                  icon: Icons.account_balance_wallet_outlined,
                  bgColor: AppColors.primaryLight,
                  textColor: AppColors.primary,
                ),
                _SummaryCard(
                  label: 'Tồn kho (giá bán)',
                  value: _formatCurrency(totalStockExport),
                  icon: Icons.storefront_outlined,
                  bgColor: AppColors.successLight,
                  textColor: AppColors.successDark,
                ),
                _SummaryCard(
                  label: 'Đã chi hôm nay',
                  value: _loadingTxns ? '...' : _formatCurrency(_totalCostToday.toInt()),
                  sub: _loadingTxns ? '' : '$_importCount phiếu nhập',
                  icon: Icons.trending_down_outlined,
                  bgColor: AppColors.errorLight,
                  textColor: AppColors.errorDark,
                  onTap: _todayImportTxns.isNotEmpty ? () => _showTxnSheet(context, 'Phiếu nhập hôm nay', _todayImportTxns, true) : null,
                ),
                _SummaryCard(
                  label: 'Đã thu hôm nay',
                  value: _loadingTxns ? '...' : _formatCurrency(_totalRevenueToday.toInt()),
                  sub: _loadingTxns ? '' : '$_exportCount phiếu xuất',
                  icon: Icons.trending_up_outlined,
                  bgColor: AppColors.warningLight,
                  textColor: AppColors.warningDark,
                  onTap: _todayExportTxns.isNotEmpty ? () => _showTxnSheet(context, 'Phiếu xuất hôm nay', _todayExportTxns, false) : null,
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 12),

        // Gross profit card
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: (grossProfit >= 0 ? AppColors.successDark : AppColors.error).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    grossProfit >= 0 ? Icons.show_chart : Icons.show_chart,
                    color: grossProfit >= 0 ? AppColors.successDark : AppColors.error,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Lãi gross trên tồn kho', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                      const SizedBox(height: 2),
                      Text(
                        _formatCurrency(grossProfit),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: grossProfit >= 0 ? AppColors.successDark : AppColors.error,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${((grossProfit / (totalStockImport > 0 ? totalStockImport : 1)) * 100).toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: grossProfit >= 0 ? AppColors.successDark : AppColors.error,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),

        // --- Ngân sách tháng ---
        _BudgetSection(ref: ref),
        const SizedBox(height: 20),

        // Detail table
        Row(
          children: [
            Text('Giá trị tồn kho theo sản phẩm', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            const Spacer(),
            Text('${sortedProducts.length} sản phẩm', style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
        const SizedBox(height: 8),
        Card(
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: AppColors.border)),
                ),
                child: const Row(
                  children: [
                    Expanded(flex: 3, child: Text('Sản phẩm', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary))),
                    Expanded(flex: 1, child: Text('Tồn', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary))),
                    Expanded(flex: 2, child: Text('Giá nhập', textAlign: TextAlign.right, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary))),
                    Expanded(flex: 2, child: Text('Giá bán', textAlign: TextAlign.right, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary))),
                    Expanded(flex: 2, child: Text('GT tồn (nhập)', textAlign: TextAlign.right, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary))),
                    Expanded(flex: 2, child: Text('GT tồn (bán)', textAlign: TextAlign.right, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary))),
                  ],
                ),
              ),
              // Rows
              ...sortedProducts.map((p) => _ProductRow(product: p)),
              // Total row
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: AppColors.border, width: 1.5)),
                  color: AppColors.background,
                ),
                child: Row(
                  children: [
                    const Expanded(flex: 3, child: Text('TỔNG CỘNG', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary))),
                    Expanded(flex: 1, child: Text(
                      formatStock(sortedProducts.fold<int>(0, (s, p) => s + p.stock), 24),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    )),
                    const Expanded(flex: 2, child: SizedBox()),
                    const Expanded(flex: 2, child: SizedBox()),
                    Expanded(flex: 2, child: Text(
                      _formatCurrency(totalStockImport),
                      textAlign: TextAlign.right,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    )),
                    Expanded(flex: 2, child: Text(
                      _formatCurrency(totalStockExport),
                      textAlign: TextAlign.right,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    )),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  static String _formatCurrency(int amount) {
    if (amount >= 1000000000) {
      return '${(amount / 1000000000).toStringAsFixed(1)} tỷ';
    }
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)} tr';
    }
    final formatted = amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
    return '$formattedđ';
  }
}

class _BudgetSection extends StatelessWidget {
  final WidgetRef ref;
  const _BudgetSection({required this.ref});

  @override
  Widget build(BuildContext context) {
    final walletAsync = ref.watch(walletProvider);
    final actualsAsync = ref.watch(actualCostProvider);
    final categoryAsync = ref.watch(categoryCostProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.account_balance_wallet_outlined, color: AppColors.primary, size: 18),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text('Ngân sách tháng', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            walletAsync.when(
              loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
              error: (e, _) => Text('Lỗi: $e', style: const TextStyle(fontSize: 12)),
              data: (wallet) {
                final initialDeposit = (wallet?['initialDeposit'] as num?)?.toInt() ?? 0;
                final note = wallet?['note'] as String? ?? '';

                return actualsAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                  error: (e, _) => Text('Lỗi: $e', style: const TextStyle(fontSize: 12)),
                  data: (actuals) {
                    final importCost = actuals['importCost'] ?? 0;
                    final exportRevenue = actuals['exportRevenue'] ?? 0;
                    final balance = initialDeposit + exportRevenue - importCost;

                    return Column(
                      children: [
                        // Balance
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: (balance >= 0 ? AppColors.successDark : AppColors.error).withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              const Text('Số dư hiện tại', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                              const SizedBox(height: 4),
                              Text(
                                _formatCurrency(balance),
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: balance >= 0 ? AppColors.successDark : AppColors.error,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Deposit + Import/Export row
                        Row(
                          children: [
                            Expanded(
                              child: _BudgetMiniTile(
                                icon: Icons.account_balance_wallet_outlined,
                                label: 'Tiền chủ kho',
                                value: _formatCurrency(initialDeposit),
                                color: AppColors.primary,
                                onTap: () => _showEditWalletSheet(context, initialDeposit, note),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _BudgetMiniTile(
                                icon: Icons.arrow_downward,
                                label: 'Đã chi tháng này',
                                value: _formatCurrency(importCost),
                                color: AppColors.error,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _BudgetMiniTile(
                                icon: Icons.arrow_upward,
                                label: 'Đã thu tháng này',
                                value: _formatCurrency(exportRevenue),
                                color: AppColors.successDark,
                              ),
                            ),
                          ],
                        ),

                        // Category breakdown
                        categoryAsync.when(
                          loading: () => const SizedBox(),
                          error: (_, __) => const SizedBox(),
                          data: (categoryCosts) {
                            if (categoryCosts.isEmpty) return const SizedBox();
                            return Column(
                              children: [
                                const SizedBox(height: 12),
                                ...categoryCosts.entries.map((e) => Padding(
                                  padding: const EdgeInsets.only(bottom: 6),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: AppColors.primary.withValues(alpha: 0.6),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(child: Text(e.key, style: const TextStyle(fontSize: 12))),
                                      Text(
                                        _formatCurrency(e.value),
                                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                )),
                              ],
                            );
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showEditWalletSheet(BuildContext context, int currentDeposit, String currentNote) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _EditWalletSheet(currentDeposit: currentDeposit, currentNote: currentNote),
    );
  }

  static String _formatCurrency(int amount) {
    if (amount >= 1000000000) return '${(amount / 1000000000).toStringAsFixed(1)} tỷ';
    if (amount >= 1000000) return '${(amount / 1000000).toStringAsFixed(1)} tr';
    final formatted = amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
    return '$formattedđ';
  }
}

class _BudgetMiniTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final VoidCallback? onTap;

  const _BudgetMiniTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tile = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 10, color: color.withValues(alpha: 0.7)), textAlign: TextAlign.center),
          const SizedBox(height: 2),
          Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color), textAlign: TextAlign.center),
        ],
      ),
    );

    if (onTap != null) return GestureDetector(onTap: onTap, child: tile);
    return tile;
  }
}

class _EditWalletSheet extends StatefulWidget {
  final int currentDeposit;
  final String currentNote;
  const _EditWalletSheet({required this.currentDeposit, required this.currentNote});

  @override
  State<_EditWalletSheet> createState() => _EditWalletSheetState();
}

class _EditWalletSheetState extends State<_EditWalletSheet> {
  late final TextEditingController _amountCtrl;
  late final TextEditingController _noteCtrl;

  @override
  void initState() {
    super.initState();
    _amountCtrl = TextEditingController(
      text: widget.currentDeposit > 0 ? widget.currentDeposit.toString() : '',
    );
    _noteCtrl = TextEditingController(text: widget.currentNote);
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Tiền chủ kho đưa', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            const Text('Nhập số tiền chủ kho giao cho kế toán', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            const SizedBox(height: 16),
            TextField(
              controller: _amountCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Số tiền (VND)',
                prefixIcon: Icon(Icons.account_balance_wallet_outlined, size: 18),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _noteCtrl,
              decoration: const InputDecoration(
                labelText: 'Ghi chú',
                prefixIcon: Icon(Icons.note_outlined, size: 18),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                onPressed: () async {
                  await saveWallet(
                    initialDeposit: int.tryParse(_amountCtrl.text) ?? 0,
                    note: _noteCtrl.text,
                  );
                  if (context.mounted) Navigator.pop(context);
                },
                child: const Text('Lưu'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final String? sub;
  final IconData icon;
  final Color bgColor;
  final Color textColor;
  final VoidCallback? onTap;

  const _SummaryCard({
    required this.label,
    required this.value,
    this.sub,
    required this.icon,
    required this.bgColor,
    required this.textColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final card = Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: textColor, size: 18),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(label, style: TextStyle(fontSize: 12, color: AppColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
                if (onTap != null)
                  Icon(Icons.chevron_right, color: AppColors.textMuted, size: 18),
              ],
            ),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
            ),
            if (sub != null && sub!.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(sub!, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
            ],
          ],
        ),
      ),
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: card);
    }
    return card;
  }
}

class _ProductRow extends StatelessWidget {
  final Product product;
  const _ProductRow({required this.product});

  @override
  Widget build(BuildContext context) {
    final valueImport = product.stock * product.unitPrice;
    final valueExport = product.stock * product.exportPrice;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(product.sku, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              formatStock(product.stock, product.unitPerCase, product.unit),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              _formatUnitPrice(product.unitPrice),
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              _formatUnitPrice(product.exportPrice),
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              _FinanceBodyState._formatCurrency(valueImport),
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              _FinanceBodyState._formatCurrency(valueExport),
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.successDark),
            ),
          ),
        ],
      ),
    );
  }

  static String _formatUnitPrice(int price) {
    if (price == 0) return '-';
    final formatted = price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
    return '$formattedđ';
  }
}

class _TxnTile extends StatelessWidget {
  final Map<String, dynamic> txn;
  final bool isImport;
  final List<Product> products;
  const _TxnTile({required this.txn, required this.isImport, required this.products});

  String _formatCurrency(int amount) {
    if (amount >= 1000000000) return '${(amount / 1000000000).toStringAsFixed(1)} tỷ';
    if (amount >= 1000000) return '${(amount / 1000000).toStringAsFixed(1)} tr';
    final formatted = amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
    return '$formattedđ';
  }

  @override
  Widget build(BuildContext context) {
    final partner = isImport ? (txn['supplier'] ?? '') : (txn['customer'] ?? '');
    final txnProducts = txn['products'] as List<dynamic>? ?? [];
    final txnTotal = (txn['_txnTotal'] as num?)?.toInt() ?? 0;
    final createdAtRaw = txn['createdAt'];
    String createdAt;
    if (createdAtRaw is Timestamp) {
      createdAt = createdAtRaw.toDate().toString().substring(0, 16);
    } else {
      createdAt = createdAtRaw?.toString() ?? '';
    }

    return Card(
      margin: const EdgeInsets.only(top: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: (isImport ? AppColors.errorLight : AppColors.warningLight),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    isImport ? Icons.arrow_downward : Icons.arrow_upward,
                    color: isImport ? AppColors.errorDark : AppColors.warningDark,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        partner.isNotEmpty ? partner : (isImport ? 'Nhập kho' : 'Xuất kho'),
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      if (createdAt.isNotEmpty)
                        Text(
                          createdAt.length > 16 ? createdAt.substring(0, 16) : createdAt,
                          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                        ),
                    ],
                  ),
                ),
                Text(
                  _formatCurrency(txnTotal),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isImport ? AppColors.errorDark : AppColors.warningDark,
                  ),
                ),
              ],
            ),
            if (txnProducts.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: txnProducts.map((item) {
                    if (item is! Map<String, dynamic>) return const SizedBox();
                    final name = item['name'] as String? ?? '';
                    final barcode = item['barcode'] as String? ?? '';
                    final qty = (item['quantity'] as num?)?.toInt() ?? 0;
                    final product = products.where((p) => p.barcode == barcode).firstOrNull;
                    final unitPrice = isImport ? (product?.unitPrice ?? 0) : (product?.exportPrice ?? 0);
                    final itemTotal = qty * unitPrice;
                    final cases = product != null && product.unitPerCase > 0 ? qty ~/ product.unitPerCase : qty;
                    final remain = product != null && product.unitPerCase > 0 ? qty % product.unitPerCase : 0;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              name.isNotEmpty ? name : barcode,
                              style: const TextStyle(fontSize: 12),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            remain > 0 ? '$cases thùng + $remain' : '$cases thùng',
                            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _formatCurrency(itemTotal),
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
