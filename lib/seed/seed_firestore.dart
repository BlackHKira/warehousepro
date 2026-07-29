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
      {'name': 'Coca Cola 355ml', 'barcode': '8934567890001', 'sku': 'A1-001', 'category': 'Nước giải khát', 'zone': 'A1', 'location': 'A1-01', 'unit': 'Cái', 'stock': 2016, 'serverStock': 2016, 'unitPrice': 7000, 'exportPrice': 8000, 'minStock': 240, 'unitPerCase': 24},
      {'name': 'Pepsi 355ml', 'barcode': '8934567890002', 'sku': 'A1-002', 'category': 'Nước giải khát', 'zone': 'A1', 'location': 'A1-01', 'unit': 'Cái', 'stock': 1488, 'serverStock': 1488, 'unitPrice': 7000, 'exportPrice': 8000, 'minStock': 240, 'unitPerCase': 24},
      {'name': 'Sting đỏ 330ml', 'barcode': '8934567890003', 'sku': 'A1-003', 'category': 'Nước giải khát', 'zone': 'A1', 'location': 'A1-02', 'unit': 'Cái', 'stock': 984, 'serverStock': 984, 'unitPrice': 6500, 'exportPrice': 7500, 'minStock': 240, 'unitPerCase': 24},
      {'name': 'Number 1 355ml', 'barcode': '8934567890004', 'sku': 'A1-004', 'category': 'Nước giải khát', 'zone': 'A1', 'location': 'A1-02', 'unit': 'Cái', 'stock': 1320, 'serverStock': 1320, 'unitPrice': 6000, 'exportPrice': 7000, 'minStock': 240, 'unitPerCase': 24},
      {'name': '7Up 355ml', 'barcode': '8934567890005', 'sku': 'A1-005', 'category': 'Nước giải khát', 'zone': 'A1', 'location': 'A1-03', 'unit': 'Cái', 'stock': 792, 'serverStock': 792, 'unitPrice': 6500, 'exportPrice': 7500, 'minStock': 240, 'unitPerCase': 24},
      {'name': 'Sprite 355ml', 'barcode': '8934567890006', 'sku': 'A1-006', 'category': 'Nước giải khát', 'zone': 'A1', 'location': 'A1-03', 'unit': 'Cái', 'stock': 672, 'serverStock': 672, 'unitPrice': 6500, 'exportPrice': 7500, 'minStock': 240, 'unitPerCase': 24},
      {'name': 'Fanta cam 355ml', 'barcode': '8934567890007', 'sku': 'A1-007', 'category': 'Nước giải khát', 'zone': 'A1', 'location': 'A1-04', 'unit': 'Cái', 'stock': 456, 'serverStock': 456, 'unitPrice': 6500, 'exportPrice': 7500, 'minStock': 240, 'unitPerCase': 24},
      {'name': 'Mirinda Cream Soda 330ml', 'barcode': '8934567890008', 'sku': 'A1-008', 'category': 'Nước giải khát', 'zone': 'A1', 'location': 'A1-04', 'unit': 'Cái', 'stock': 528, 'serverStock': 528, 'unitPrice': 6000, 'exportPrice': 7000, 'minStock': 240, 'unitPerCase': 24},
      // A2 — Nước lọc, trà, nước tăng lực (24 chai/thùng)
      {'name': 'Aquafina 500ml', 'barcode': '8934567890009', 'sku': 'A2-001', 'category': 'Nước giải khát', 'zone': 'A2', 'location': 'A2-01', 'unit': 'Cái', 'stock': 2304, 'serverStock': 2304, 'unitPrice': 5000, 'exportPrice': 6000, 'minStock': 240, 'unitPerCase': 24},
      {'name': 'Trà xanh C2 500ml', 'barcode': '8934567890010', 'sku': 'A2-002', 'category': 'Nước giải khát', 'zone': 'A2', 'location': 'A2-01', 'unit': 'Cái', 'stock': 1728, 'serverStock': 1728, 'unitPrice': 4500, 'exportPrice': 5500, 'minStock': 240, 'unitPerCase': 24},
      {'name': 'Trà O Long Tea 500ml', 'barcode': '8934567890011', 'sku': 'A2-003', 'category': 'Nước giải khát', 'zone': 'A2', 'location': 'A2-02', 'unit': 'Cái', 'stock': 1152, 'serverStock': 1152, 'unitPrice': 4500, 'exportPrice': 5500, 'minStock': 240, 'unitPerCase': 24},
      {'name': 'Nước ép cam Twister 350ml', 'barcode': '8934567890012', 'sku': 'A2-004', 'category': 'Nước giải khát', 'zone': 'A2', 'location': 'A2-02', 'unit': 'Cái', 'stock': 840, 'serverStock': 840, 'unitPrice': 5500, 'exportPrice': 6500, 'minStock': 240, 'unitPerCase': 24},
      {'name': 'Lavie 500ml', 'barcode': '8934567890013', 'sku': 'A2-005', 'category': 'Nước giải khát', 'zone': 'A2', 'location': 'A2-03', 'unit': 'Cái', 'stock': 1200, 'serverStock': 1200, 'unitPrice': 4000, 'exportPrice': 5000, 'minStock': 240, 'unitPerCase': 24},
      {'name': 'Dasani 500ml', 'barcode': '8934567890014', 'sku': 'A2-006', 'category': 'Nước giải khát', 'zone': 'A2', 'location': 'A2-03', 'unit': 'Cái', 'stock': 648, 'serverStock': 648, 'unitPrice': 4000, 'exportPrice': 5000, 'minStock': 240, 'unitPerCase': 24},
      {'name': 'Red Bull 250ml', 'barcode': '8934567890015', 'sku': 'A2-007', 'category': 'Nước giải khát', 'zone': 'A2', 'location': 'A2-04', 'unit': 'Cái', 'stock': 1512, 'serverStock': 1512, 'unitPrice': 9000, 'exportPrice': 10000, 'minStock': 240, 'unitPerCase': 24},
      {'name': 'Monster 355ml', 'barcode': '8934567890016', 'sku': 'A2-008', 'category': 'Nước giải khát', 'zone': 'A2', 'location': 'A2-04', 'unit': 'Cái', 'stock': 312, 'serverStock': 312, 'unitPrice': 10000, 'exportPrice': 11000, 'minStock': 240, 'unitPerCase': 24},
      // B1 — Mì, cháo, phở (30 gói/thùng)
      {'name': 'Mì tôm Hảo Hảo 75g', 'barcode': '8934567890017', 'sku': 'B1-001', 'category': 'Thực phẩm', 'zone': 'B1', 'location': 'B1-01', 'unit': 'Cái', 'stock': 3600, 'serverStock': 3600, 'unitPrice': 3200, 'exportPrice': 4000, 'minStock': 450, 'unitPerCase': 30},
      {'name': 'Mì tôm Omachi 75g', 'barcode': '8934567890018', 'sku': 'B1-002', 'category': 'Thực phẩm', 'zone': 'B1', 'location': 'B1-01', 'unit': 'Cái', 'stock': 2550, 'serverStock': 2550, 'unitPrice': 4000, 'exportPrice': 4800, 'minStock': 450, 'unitPerCase': 30},
      {'name': 'Mì ly Miliket 65g', 'barcode': '8934567890019', 'sku': 'B1-003', 'category': 'Thực phẩm', 'zone': 'B1', 'location': 'B1-02', 'unit': 'Cái', 'stock': 1800, 'serverStock': 1800, 'unitPrice': 2400, 'exportPrice': 3200, 'minStock': 450, 'unitPerCase': 30},
      {'name': 'Cháo gà Vifon 60g', 'barcode': '8934567890020', 'sku': 'B1-004', 'category': 'Thực phẩm', 'zone': 'B1', 'location': 'B1-02', 'unit': 'Cái', 'stock': 1320, 'serverStock': 1320, 'unitPrice': 2800, 'exportPrice': 3600, 'minStock': 450, 'unitPerCase': 30},
      {'name': 'Phở bò Vifon 65g', 'barcode': '8934567890021', 'sku': 'B1-005', 'category': 'Thực phẩm', 'zone': 'B1', 'location': 'B1-03', 'unit': 'Cái', 'stock': 1140, 'serverStock': 1140, 'unitPrice': 3200, 'exportPrice': 4000, 'minStock': 450, 'unitPerCase': 30},
      {'name': 'Mì Cung Đình 75g', 'barcode': '8934567890022', 'sku': 'B1-006', 'category': 'Thực phẩm', 'zone': 'B1', 'location': 'B1-03', 'unit': 'Cái', 'stock': 1560, 'serverStock': 1560, 'unitPrice': 3600, 'exportPrice': 4400, 'minStock': 450, 'unitPerCase': 30},
      {'name': 'Mì tôm Kokomi 80g', 'barcode': '8934567890023', 'sku': 'B1-007', 'category': 'Thực phẩm', 'zone': 'B1', 'location': 'B1-04', 'unit': 'Cái', 'stock': 2130, 'serverStock': 2130, 'unitPrice': 3200, 'exportPrice': 4000, 'minStock': 450, 'unitPerCase': 30},
      {'name': 'Bún gạo QBB 70g', 'barcode': '8934567890024', 'sku': 'B1-008', 'category': 'Thực phẩm', 'zone': 'B1', 'location': 'B1-04', 'unit': 'Cái', 'stock': 870, 'serverStock': 870, 'unitPrice': 2800, 'exportPrice': 3600, 'minStock': 450, 'unitPerCase': 30},
      // B2 — Bánh, kẹo, snack, sữa (12-24/thùng)
      {'name': 'Bánh Oreo 97g', 'barcode': '8934567890025', 'sku': 'B2-001', 'category': 'Thực phẩm', 'zone': 'B2', 'location': 'B2-01', 'unit': 'Cái', 'stock': 804, 'serverStock': 804, 'unitPrice': 12000, 'exportPrice': 14000, 'minStock': 120, 'unitPerCase': 12},
      {'name': 'Bánh Cosy 120g', 'barcode': '8934567890026', 'sku': 'B2-002', 'category': 'Thực phẩm', 'zone': 'B2', 'location': 'B2-01', 'unit': 'Cái', 'stock': 516, 'serverStock': 516, 'unitPrice': 10000, 'exportPrice': 12000, 'minStock': 120, 'unitPerCase': 12},
      {'name': 'Khoai tây chiên Poca 90g', 'barcode': '8934567890027', 'sku': 'B2-003', 'category': 'Thực phẩm', 'zone': 'B2', 'location': 'B2-02', 'unit': 'Cái', 'stock': 696, 'serverStock': 696, 'unitPrice': 14000, 'exportPrice': 16000, 'minStock': 120, 'unitPerCase': 12},
      {'name': 'Kẹo mút Chupa Chups', 'barcode': '8934567890028', 'sku': 'B2-004', 'category': 'Thực phẩm', 'zone': 'B2', 'location': 'B2-02', 'unit': 'Cái', 'stock': 2160, 'serverStock': 2160, 'unitPrice': 4500, 'exportPrice': 5500, 'minStock': 240, 'unitPerCase': 24},
      {'name': 'Bánh gạo One One 80g', 'barcode': '8934567890029', 'sku': 'B2-005', 'category': 'Thực phẩm', 'zone': 'B2', 'location': 'B2-03', 'unit': 'Cái', 'stock': 444, 'serverStock': 444, 'unitPrice': 8000, 'exportPrice': 10000, 'minStock': 120, 'unitPerCase': 12},
      {'name': 'Snack Lays 70g', 'barcode': '8934567890030', 'sku': 'B2-006', 'category': 'Thực phẩm', 'zone': 'B2', 'location': 'B2-03', 'unit': 'Cái', 'stock': 552, 'serverStock': 552, 'unitPrice': 12000, 'exportPrice': 14000, 'minStock': 120, 'unitPerCase': 12},
      {'name': 'Sữa đậu nành Fami 200ml', 'barcode': '8934567890031', 'sku': 'B2-007', 'category': 'Thực phẩm', 'zone': 'B2', 'location': 'B2-04', 'unit': 'Cái', 'stock': 1800, 'serverStock': 1800, 'unitPrice': 5000, 'exportPrice': 6000, 'minStock': 240, 'unitPerCase': 24},
      {'name': 'Sữa Milo hộp 180ml', 'barcode': '8934567890032', 'sku': 'B2-008', 'category': 'Thực phẩm', 'zone': 'B2', 'location': 'B2-04', 'unit': 'Cái', 'stock': 1944, 'serverStock': 1944, 'unitPrice': 7500, 'exportPrice': 8500, 'minStock': 240, 'unitPerCase': 24},
      // C1 — Đồ vệ sinh cá nhân (12 chai/thùng, kem đánh răng 24/thùng)
      {'name': 'Dầu gội Clear 200ml', 'barcode': '8934567890033', 'sku': 'C1-001', 'category': 'Vệ sinh', 'zone': 'C1', 'location': 'C1-01', 'unit': 'Cái', 'stock': 480, 'serverStock': 480, 'unitPrice': 14000, 'exportPrice': 16000, 'minStock': 96, 'unitPerCase': 12},
      {'name': 'Dầu gội Sunsilk 180ml', 'barcode': '8934567890034', 'sku': 'C1-002', 'category': 'Vệ sinh', 'zone': 'C1', 'location': 'C1-01', 'unit': 'Cái', 'stock': 420, 'serverStock': 420, 'unitPrice': 12000, 'exportPrice': 14000, 'minStock': 96, 'unitPerCase': 12},
      {'name': 'Sữa tắm Lifebuoy 250ml', 'barcode': '8934567890035', 'sku': 'C1-003', 'category': 'Vệ sinh', 'zone': 'C1', 'location': 'C1-02', 'unit': 'Cái', 'stock': 336, 'serverStock': 336, 'unitPrice': 13000, 'exportPrice': 15000, 'minStock': 96, 'unitPerCase': 12},
      {'name': 'Xà phòng Lifebuoy 90g', 'barcode': '8934567890036', 'sku': 'C1-004', 'category': 'Vệ sinh', 'zone': 'C1', 'location': 'C1-02', 'unit': 'Cái', 'stock': 660, 'serverStock': 660, 'unitPrice': 6000, 'exportPrice': 8000, 'minStock': 96, 'unitPerCase': 12},
      {'name': 'Kem đánh răng Colgate 120g', 'barcode': '8934567890037', 'sku': 'C1-005', 'category': 'Vệ sinh', 'zone': 'C1', 'location': 'C1-03', 'unit': 'Cái', 'stock': 1152, 'serverStock': 1152, 'unitPrice': 6000, 'exportPrice': 7000, 'minStock': 192, 'unitPerCase': 24},
      {'name': 'Lăn khử mùi Rexona 40ml', 'barcode': '8934567890038', 'sku': 'C1-006', 'category': 'Vệ sinh', 'zone': 'C1', 'location': 'C1-03', 'unit': 'Cái', 'stock': 384, 'serverStock': 384, 'unitPrice': 16000, 'exportPrice': 18000, 'minStock': 96, 'unitPerCase': 12},
      {'name': 'Nước súc miệng Listerine 250ml', 'barcode': '8934567890039', 'sku': 'C1-007', 'category': 'Vệ sinh', 'zone': 'C1', 'location': 'C1-04', 'unit': 'Cái', 'stock': 240, 'serverStock': 240, 'unitPrice': 14000, 'exportPrice': 16000, 'minStock': 96, 'unitPerCase': 12},
      {'name': 'Khăn giấy ướt Bobby 100 tờ', 'barcode': '8934567890040', 'sku': 'C1-008', 'category': 'Vệ sinh', 'zone': 'C1', 'location': 'C1-04', 'unit': 'Cái', 'stock': 180, 'serverStock': 180, 'unitPrice': 10000, 'exportPrice': 12000, 'minStock': 96, 'unitPerCase': 12},
      // C2 — Gia dụng, tẩy rửa (12 chai/thùng)
      {'name': 'Nước rửa chén Sunlight 750ml', 'barcode': '8934567890041', 'sku': 'C2-001', 'category': 'Gia dụng', 'zone': 'C2', 'location': 'C2-01', 'unit': 'Cái', 'stock': 768, 'serverStock': 768, 'unitPrice': 9000, 'exportPrice': 11000, 'minStock': 120, 'unitPerCase': 12},
      {'name': 'Nước lau sàn Vim 500ml', 'barcode': '8934567890042', 'sku': 'C2-002', 'category': 'Gia dụng', 'zone': 'C2', 'location': 'C2-01', 'unit': 'Cái', 'stock': 504, 'serverStock': 504, 'unitPrice': 7000, 'exportPrice': 9000, 'minStock': 120, 'unitPerCase': 12},
      {'name': 'Bột giặt Omo 1kg', 'barcode': '8934567890043', 'sku': 'C2-003', 'category': 'Gia dụng', 'zone': 'C2', 'location': 'C2-02', 'unit': 'Cái', 'stock': 456, 'serverStock': 456, 'unitPrice': 10000, 'exportPrice': 12000, 'minStock': 120, 'unitPerCase': 12},
      {'name': 'Nước xả Comfort 500ml', 'barcode': '8934567890044', 'sku': 'C2-004', 'category': 'Gia dụng', 'zone': 'C2', 'location': 'C2-02', 'unit': 'Cái', 'stock': 612, 'serverStock': 612, 'unitPrice': 8000, 'exportPrice': 10000, 'minStock': 120, 'unitPerCase': 12},
      {'name': 'Thuốc tẩy Javel 500ml', 'barcode': '8934567890045', 'sku': 'C2-005', 'category': 'Gia dụng', 'zone': 'C2', 'location': 'C2-03', 'unit': 'Cái', 'stock': 300, 'serverStock': 300, 'unitPrice': 5000, 'exportPrice': 7000, 'minStock': 120, 'unitPerCase': 12},
      {'name': 'Túi rác 50x60 30c', 'barcode': '8934567890046', 'sku': 'C2-006', 'category': 'Gia dụng', 'zone': 'C2', 'location': 'C2-03', 'unit': 'Cái', 'stock': 840, 'serverStock': 840, 'unitPrice': 4000, 'exportPrice': 6000, 'minStock': 120, 'unitPerCase': 12},
      {'name': 'Khăn giấy Pulppy 10c', 'barcode': '8934567890047', 'sku': 'C2-007', 'category': 'Gia dụng', 'zone': 'C2', 'location': 'C2-04', 'unit': 'Cái', 'stock': 396, 'serverStock': 396, 'unitPrice': 6000, 'exportPrice': 8000, 'minStock': 120, 'unitPerCase': 12},
      {'name': 'Bọc nilon 30cm', 'barcode': '8934567890048', 'sku': 'C2-008', 'category': 'Gia dụng', 'zone': 'C2', 'location': 'C2-04', 'unit': 'Cái', 'stock': 216, 'serverStock': 216, 'unitPrice': 3000, 'exportPrice': 5000, 'minStock': 120, 'unitPerCase': 12},
    ];

    for (var p in products) {
      await db.collection('products').add({
        ...p,
        'note': '',
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
