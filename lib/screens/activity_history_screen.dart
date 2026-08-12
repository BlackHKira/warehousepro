import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../theme/app_theme.dart';

class ActivityHistoryScreen extends ConsumerWidget {
  const ActivityHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = FirebaseFirestore.instanceFor(
      app: Firebase.app(),
      databaseId: 'warehousepro-db',
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Lịch sử hoạt động')),
      body: StreamBuilder<QuerySnapshot>(
        stream: db.collection('stock_transactions')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text('Không thể tải dữ liệu từ máy chủ', style: TextStyle(color: AppColors.textMuted, fontSize: 15)),
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.receipt_long_outlined, size: 64, color: AppColors.textMuted),
                  const SizedBox(height: 12),
                  Text('Chưa có hoạt động nào', style: TextStyle(color: AppColors.textMuted, fontSize: 15)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              return _ActivityTile(
                type: data['type'] as String? ?? '',
                productName: _firstProductName(data),
                docId: doc.id,
                items: (data['items'] as num?)?.toInt() ?? 0,
                createdAt: data['createdAt'],
                createdBy: data['createdBy'] as String? ?? '',
                deliveredBy: data['deliveredBy'] as String? ?? '',
              );
            },
          );
        },
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  final String type;
  final String productName;
  final String docId;
  final int items;
  final dynamic createdAt;
  final String createdBy;
  final String deliveredBy;

  const _ActivityTile({
    required this.type,
    required this.productName,
    required this.docId,
    required this.items,
    required this.createdAt,
    this.createdBy = '',
    this.deliveredBy = '',
  });

  @override
  Widget build(BuildContext context) {
    final isImport = type == 'import';
    final dotColor = isImport ? AppColors.green : AppColors.red;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(productName, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14, color: AppColors.textPrimary)),
                  const SizedBox(height: 2),
                  Text(_subtitle(), style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(_formatTimestamp(createdAt), style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
          ],
        ),
      ),
    );
  }

  String _subtitle() {
    final isImport = type == 'import';
    final prefix = isImport ? 'NK' : 'XK';
    final label = isImport ? 'Nhập' : 'Xuất';
    final code = _transactionCodeFromId(docId, prefix);
    final byLabel = createdBy.isNotEmpty ? ' — $createdBy' : '';
    final deliverLabel = deliveredBy.isNotEmpty ? ' — Giao: $deliveredBy' : '';
    return '$label $items — $code$byLabel$deliverLabel';
  }
}

String _firstProductName(Map<String, dynamic> data) {
  final products = data['products'] as List<dynamic>? ?? [];
  if (products.isNotEmpty) {
    final name = products[0]['name'] as String?;
    if (name != null && name.isNotEmpty) return name;
  }
  if (data['type'] == 'import') {
    return data['supplier'] as String? ?? 'Nhập kho';
  }
  return data['customer'] as String? ?? 'Xuất kho';
}

String _transactionCodeFromId(String? docId, String prefix) {
  if (docId != null && docId.length >= 4) {
    return '$prefix-${docId.substring(0, 4).toUpperCase()}';
  }
  return '$prefix-0000';
}

String _formatTimestamp(dynamic ts) {
  if (ts is Timestamp) {
    final dt = ts.toDate();
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
  return '';
}
