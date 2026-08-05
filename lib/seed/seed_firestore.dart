import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class SeedFirestore {
  final FirebaseFirestore db = FirebaseFirestore.instanceFor(
    app: Firebase.app(),
    databaseId: 'warehousepro-db',
  );

  Future<void> seedProducts() async {
    final products = [
      // A1 — Nước ngọt có gas (24 lon/thùng)
      {'name': 'Coca Cola 355ml', 'barcode': '8934567890001', 'sku': 'A1-001', 'category': 'Nước ngọt', 'zone': 'A1', 'unit': 'Lon', 'stock': 2016, 'serverStock': 2016, 'unitPrice': 7000, 'exportPrice': 8000, 'minStock': 240, 'unitPerCase': 24},
      {'name': 'Pepsi 355ml', 'barcode': '8934567890002', 'sku': 'A1-002', 'category': 'Nước ngọt', 'zone': 'A1', 'unit': 'Lon', 'stock': 1488, 'serverStock': 1488, 'unitPrice': 7000, 'exportPrice': 8000, 'minStock': 240, 'unitPerCase': 24},
      {'name': 'Sting đỏ 330ml', 'barcode': '8934567890003', 'sku': 'A1-003', 'category': 'Nước ngọt', 'zone': 'A1', 'unit': 'Lon', 'stock': 984, 'serverStock': 984, 'unitPrice': 6500, 'exportPrice': 7500, 'minStock': 240, 'unitPerCase': 24},
      {'name': 'Number 1 355ml', 'barcode': '8934567890004', 'sku': 'A1-004', 'category': 'Nước ngọt', 'zone': 'A1', 'unit': 'Lon', 'stock': 1320, 'serverStock': 1320, 'unitPrice': 6000, 'exportPrice': 7000, 'minStock': 240, 'unitPerCase': 24},
      {'name': '7Up 355ml', 'barcode': '8934567890005', 'sku': 'A1-005', 'category': 'Nước ngọt', 'zone': 'A1', 'unit': 'Lon', 'stock': 792, 'serverStock': 792, 'unitPrice': 6500, 'exportPrice': 7500, 'minStock': 240, 'unitPerCase': 24},
      {'name': 'Sprite 355ml', 'barcode': '8934567890006', 'sku': 'A1-006', 'category': 'Nước ngọt', 'zone': 'A1', 'unit': 'Lon', 'stock': 672, 'serverStock': 672, 'unitPrice': 6500, 'exportPrice': 7500, 'minStock': 240, 'unitPerCase': 24},
      {'name': 'Fanta cam 355ml', 'barcode': '8934567890007', 'sku': 'A1-007', 'category': 'Nước ngọt', 'zone': 'A1', 'unit': 'Lon', 'stock': 456, 'serverStock': 456, 'unitPrice': 6500, 'exportPrice': 7500, 'minStock': 240, 'unitPerCase': 24},
      {'name': 'Mirinda Cream Soda 330ml', 'barcode': '8934567890008', 'sku': 'A1-008', 'category': 'Nước ngọt', 'zone': 'A1', 'unit': 'Lon', 'stock': 528, 'serverStock': 528, 'unitPrice': 6000, 'exportPrice': 7000, 'minStock': 240, 'unitPerCase': 24},

      // B1 — Nước tăng lực (24 lon/thùng)
      {'name': 'Red Bull 250ml', 'barcode': '8934567890015', 'sku': 'B1-001', 'category': 'Nước tăng lực', 'zone': 'B1', 'unit': 'Lon', 'stock': 1512, 'serverStock': 1512, 'unitPrice': 9000, 'exportPrice': 10000, 'minStock': 240, 'unitPerCase': 24},
      {'name': 'Monster 355ml', 'barcode': '8934567890016', 'sku': 'B1-002', 'category': 'Nước tăng lực', 'zone': 'B1', 'unit': 'Lon', 'stock': 312, 'serverStock': 312, 'unitPrice': 10000, 'exportPrice': 11000, 'minStock': 240, 'unitPerCase': 24},
      {'name': 'Sting Vàng 250ml', 'barcode': '8934567890031', 'sku': 'B2-001', 'category': 'Nước tăng lực', 'zone': 'B2', 'unit': 'Lon', 'stock': 800, 'serverStock': 800, 'unitPrice': 7000, 'exportPrice': 8000, 'minStock': 240, 'unitPerCase': 24},
      {'name': 'Cobra Strike 250ml', 'barcode': '8934567890032', 'sku': 'B2-002', 'category': 'Nước tăng lực', 'zone': 'B2', 'unit': 'Lon', 'stock': 600, 'serverStock': 600, 'unitPrice': 10000, 'exportPrice': 12000, 'minStock': 240, 'unitPerCase': 24},
      {'name': 'Warrior 250ml (hộp thiếc)', 'barcode': '8934567890033', 'sku': 'B2-003', 'category': 'Nước tăng lực', 'zone': 'B2', 'unit': 'Lon', 'stock': 720, 'serverStock': 720, 'unitPrice': 8000, 'exportPrice': 9000, 'minStock': 240, 'unitPerCase': 24},

      // C1 — Nước lọc (24 chai/thùng)
      {'name': 'Aquafina 500ml', 'barcode': '8934567890009', 'sku': 'C1-001', 'category': 'Nước lọc', 'zone': 'C1', 'unit': 'Chai', 'stock': 2304, 'serverStock': 2304, 'unitPrice': 5000, 'exportPrice': 6000, 'minStock': 240, 'unitPerCase': 24},
      {'name': 'Lavie 500ml', 'barcode': '8934567890013', 'sku': 'C1-002', 'category': 'Nước lọc', 'zone': 'C1', 'unit': 'Chai', 'stock': 1200, 'serverStock': 1200, 'unitPrice': 4000, 'exportPrice': 5000, 'minStock': 240, 'unitPerCase': 24},
      {'name': 'Dasani 500ml', 'barcode': '8934567890014', 'sku': 'C1-003', 'category': 'Nước lọc', 'zone': 'C1', 'unit': 'Chai', 'stock': 648, 'serverStock': 648, 'unitPrice': 4000, 'exportPrice': 5000, 'minStock': 240, 'unitPerCase': 24},
      {'name': 'Imsong 500ml', 'barcode': '8934567890034', 'sku': 'C1-004', 'category': 'Nước lọc', 'zone': 'C1', 'unit': 'Chai', 'stock': 1200, 'serverStock': 1200, 'unitPrice': 3500, 'exportPrice': 4500, 'minStock': 240, 'unitPerCase': 24},
      {'name': 'Vihawa 500ml', 'barcode': '8934567890035', 'sku': 'C1-005', 'category': 'Nước lọc', 'zone': 'C1', 'unit': 'Chai', 'stock': 800, 'serverStock': 800, 'unitPrice': 4000, 'exportPrice': 5000, 'minStock': 240, 'unitPerCase': 24},
      {'name': 'Buddha 500ml', 'barcode': '8934567890036', 'sku': 'C1-006', 'category': 'Nước lọc', 'zone': 'C1', 'unit': 'Chai', 'stock': 600, 'serverStock': 600, 'unitPrice': 6000, 'exportPrice': 7000, 'minStock': 240, 'unitPerCase': 24},

      // C2 — Trà (24 chai/thùng)
      {'name': 'Trà xanh C2 500ml', 'barcode': '8934567890010', 'sku': 'C2-001', 'category': 'Trà', 'zone': 'C2', 'unit': 'Chai', 'stock': 1728, 'serverStock': 1728, 'unitPrice': 4500, 'exportPrice': 5500, 'minStock': 240, 'unitPerCase': 24},
      {'name': 'Trà ô long T-Plus 500ml', 'barcode': '8934567890049', 'sku': 'C2-002', 'category': 'Trà', 'zone': 'C2', 'unit': 'Chai', 'stock': 0, 'serverStock': 0, 'unitPrice': 4500, 'exportPrice': 5500, 'minStock': 240, 'unitPerCase': 24},
      {'name': 'Trà xanh Không độ 500ml', 'barcode': '8934567890037', 'sku': 'C2-003', 'category': 'Trà', 'zone': 'C2', 'unit': 'Chai', 'stock': 900, 'serverStock': 900, 'unitPrice': 6000, 'exportPrice': 7000, 'minStock': 240, 'unitPerCase': 24},
      {'name': 'Trà sen Tây Hồ 500ml', 'barcode': '8934567890038', 'sku': 'C2-004', 'category': 'Trà', 'zone': 'C2', 'unit': 'Chai', 'stock': 500, 'serverStock': 500, 'unitPrice': 8000, 'exportPrice': 10000, 'minStock': 240, 'unitPerCase': 24},
      {'name': 'Trà nhài Ilsbean 500ml', 'barcode': '8934567890039', 'sku': 'C2-005', 'category': 'Trà', 'zone': 'C2', 'unit': 'Chai', 'stock': 400, 'serverStock': 400, 'unitPrice': 7000, 'exportPrice': 9000, 'minStock': 240, 'unitPerCase': 24},
    ];

    for (var p in products) {
      await db.collection('products').add({
        ...p,
        'note': '',
        'imageUrl': '',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> seedUsers() async {
    final users = [
      {
        'id': 'U001',
        'email': 'admin@warehousepro.com',
        'fullName': 'Nguyễn Thanh Quân',
        'role': 'admin',
        'isActive': true,
      },
      {
        'id': 'U002',
        'email': 'kho01@warehousepro.com',
        'fullName': 'Nguyễn Văn Nam',
        'role': 'staff',
        'isActive': true,
      },
    ];

    for (var user in users) {
      await db.collection('users').doc(user['id'] as String).set({
        ...user,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> seedAll() async {
    await seedUsers();
    await seedProducts();
    debugPrint('========== FIRESTORE SEEDED ==========');
  }
}
