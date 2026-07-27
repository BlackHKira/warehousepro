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
      // A1 — Nước ngọt có gas
      {'name': 'Coca Cola 355ml', 'barcode': '8934567890001', 'sku': 'A1-001', 'category': 'Nước giải khát', 'zone': 'A1', 'location': 'A1-01', 'unit': 'Thùng', 'stock': 84, 'serverStock': 84, 'unitPrice': 168000, 'exportPrice': 192000, 'minStock': 10},
      {'name': 'Pepsi 355ml', 'barcode': '8934567890002', 'sku': 'A1-002', 'category': 'Nước giải khát', 'zone': 'A1', 'location': 'A1-01', 'unit': 'Thùng', 'stock': 62, 'serverStock': 62, 'unitPrice': 168000, 'exportPrice': 192000, 'minStock': 10},
      {'name': 'Sting đỏ 330ml', 'barcode': '8934567890003', 'sku': 'A1-003', 'category': 'Nước giải khát', 'zone': 'A1', 'location': 'A1-02', 'unit': 'Thùng', 'stock': 41, 'serverStock': 41, 'unitPrice': 156000, 'exportPrice': 180000, 'minStock': 10},
      {'name': 'Number 1 355ml', 'barcode': '8934567890004', 'sku': 'A1-004', 'category': 'Nước giải khát', 'zone': 'A1', 'location': 'A1-02', 'unit': 'Thùng', 'stock': 55, 'serverStock': 55, 'unitPrice': 144000, 'exportPrice': 168000, 'minStock': 10},
      {'name': '7Up 355ml', 'barcode': '8934567890005', 'sku': 'A1-005', 'category': 'Nước giải khát', 'zone': 'A1', 'location': 'A1-03', 'unit': 'Thùng', 'stock': 33, 'serverStock': 33, 'unitPrice': 156000, 'exportPrice': 180000, 'minStock': 10},
      {'name': 'Sprite 355ml', 'barcode': '8934567890006', 'sku': 'A1-006', 'category': 'Nước giải khát', 'zone': 'A1', 'location': 'A1-03', 'unit': 'Thùng', 'stock': 28, 'serverStock': 28, 'unitPrice': 156000, 'exportPrice': 180000, 'minStock': 10},
      {'name': 'Fanta cam 355ml', 'barcode': '8934567890007', 'sku': 'A1-007', 'category': 'Nước giải khát', 'zone': 'A1', 'location': 'A1-04', 'unit': 'Thùng', 'stock': 19, 'serverStock': 19, 'unitPrice': 156000, 'exportPrice': 180000, 'minStock': 10},
      {'name': 'Mirinda Cream Soda 330ml', 'barcode': '8934567890008', 'sku': 'A1-008', 'category': 'Nước giải khát', 'zone': 'A1', 'location': 'A1-04', 'unit': 'Thùng', 'stock': 22, 'serverStock': 22, 'unitPrice': 144000, 'exportPrice': 168000, 'minStock': 10},
      // A2 — Nước lọc, trà, nước tăng lực
      {'name': 'Aquafina 500ml', 'barcode': '8934567890009', 'sku': 'A2-001', 'category': 'Nước giải khát', 'zone': 'A2', 'location': 'A2-01', 'unit': 'Thùng', 'stock': 96, 'serverStock': 96, 'unitPrice': 120000, 'exportPrice': 144000, 'minStock': 10},
      {'name': 'Trà xanh C2 500ml', 'barcode': '8934567890010', 'sku': 'A2-002', 'category': 'Nước giải khát', 'zone': 'A2', 'location': 'A2-01', 'unit': 'Thùng', 'stock': 72, 'serverStock': 72, 'unitPrice': 108000, 'exportPrice': 132000, 'minStock': 10},
      {'name': 'Trà O Long Tea 500ml', 'barcode': '8934567890011', 'sku': 'A2-003', 'category': 'Nước giải khát', 'zone': 'A2', 'location': 'A2-02', 'unit': 'Thùng', 'stock': 48, 'serverStock': 48, 'unitPrice': 108000, 'exportPrice': 132000, 'minStock': 10},
      {'name': 'Nước ép cam Twister 350ml', 'barcode': '8934567890012', 'sku': 'A2-004', 'category': 'Nước giải khát', 'zone': 'A2', 'location': 'A2-02', 'unit': 'Thùng', 'stock': 35, 'serverStock': 35, 'unitPrice': 132000, 'exportPrice': 156000, 'minStock': 10},
      {'name': 'Lavie 500ml', 'barcode': '8934567890013', 'sku': 'A2-005', 'category': 'Nước giải khát', 'zone': 'A2', 'location': 'A2-03', 'unit': 'Thùng', 'stock': 50, 'serverStock': 50, 'unitPrice': 96000, 'exportPrice': 120000, 'minStock': 10},
      {'name': 'Dasani 500ml', 'barcode': '8934567890014', 'sku': 'A2-006', 'category': 'Nước giải khát', 'zone': 'A2', 'location': 'A2-03', 'unit': 'Thùng', 'stock': 27, 'serverStock': 27, 'unitPrice': 96000, 'exportPrice': 120000, 'minStock': 10},
      {'name': 'Red Bull 250ml', 'barcode': '8934567890015', 'sku': 'A2-007', 'category': 'Nước giải khát', 'zone': 'A2', 'location': 'A2-04', 'unit': 'Thùng', 'stock': 63, 'serverStock': 63, 'unitPrice': 216000, 'exportPrice': 240000, 'minStock': 10},
      {'name': 'Monster 355ml', 'barcode': '8934567890016', 'sku': 'A2-008', 'category': 'Nước giải khát', 'zone': 'A2', 'location': 'A2-04', 'unit': 'Thùng', 'stock': 13, 'serverStock': 13, 'unitPrice': 240000, 'exportPrice': 264000, 'minStock': 10},
      // B1 — Mì, cháo, phở
      {'name': 'Mì tôm Hảo Hảo 75g', 'barcode': '8934567890017', 'sku': 'B1-001', 'category': 'Thực phẩm', 'zone': 'B1', 'location': 'B1-01', 'unit': 'Thùng', 'stock': 120, 'serverStock': 120, 'unitPrice': 96000, 'exportPrice': 120000, 'minStock': 15},
      {'name': 'Mì tôm Omachi 75g', 'barcode': '8934567890018', 'sku': 'B1-002', 'category': 'Thực phẩm', 'zone': 'B1', 'location': 'B1-01', 'unit': 'Thùng', 'stock': 85, 'serverStock': 85, 'unitPrice': 120000, 'exportPrice': 144000, 'minStock': 15},
      {'name': 'Mì ly Miliket 65g', 'barcode': '8934567890019', 'sku': 'B1-003', 'category': 'Thực phẩm', 'zone': 'B1', 'location': 'B1-02', 'unit': 'Thùng', 'stock': 60, 'serverStock': 60, 'unitPrice': 72000, 'exportPrice': 96000, 'minStock': 15},
      {'name': 'Cháo gà Vifon 60g', 'barcode': '8934567890020', 'sku': 'B1-004', 'category': 'Thực phẩm', 'zone': 'B1', 'location': 'B1-02', 'unit': 'Thùng', 'stock': 44, 'serverStock': 44, 'unitPrice': 84000, 'exportPrice': 108000, 'minStock': 15},
      {'name': 'Phở bò Vifon 65g', 'barcode': '8934567890021', 'sku': 'B1-005', 'category': 'Thực phẩm', 'zone': 'B1', 'location': 'B1-03', 'unit': 'Thùng', 'stock': 38, 'serverStock': 38, 'unitPrice': 96000, 'exportPrice': 120000, 'minStock': 15},
      {'name': 'Mì Cung Đình 75g', 'barcode': '8934567890022', 'sku': 'B1-006', 'category': 'Thực phẩm', 'zone': 'B1', 'location': 'B1-03', 'unit': 'Thùng', 'stock': 52, 'serverStock': 52, 'unitPrice': 108000, 'exportPrice': 132000, 'minStock': 15},
      {'name': 'Mì tôm Kokomi 80g', 'barcode': '8934567890023', 'sku': 'B1-007', 'category': 'Thực phẩm', 'zone': 'B1', 'location': 'B1-04', 'unit': 'Thùng', 'stock': 71, 'serverStock': 71, 'unitPrice': 96000, 'exportPrice': 120000, 'minStock': 15},
      {'name': 'Bún gạo QBB 70g', 'barcode': '8934567890024', 'sku': 'B1-008', 'category': 'Thực phẩm', 'zone': 'B1', 'location': 'B1-04', 'unit': 'Thùng', 'stock': 29, 'serverStock': 29, 'unitPrice': 84000, 'exportPrice': 108000, 'minStock': 15},
      // B2 — Bánh, kẹo, snack, sữa
      {'name': 'Bánh Oreo 97g', 'barcode': '8934567890025', 'sku': 'B2-001', 'category': 'Thực phẩm', 'zone': 'B2', 'location': 'B2-01', 'unit': 'Thùng', 'stock': 67, 'serverStock': 67, 'unitPrice': 144000, 'exportPrice': 168000, 'minStock': 10},
      {'name': 'Bánh Cosy 120g', 'barcode': '8934567890026', 'sku': 'B2-002', 'category': 'Thực phẩm', 'zone': 'B2', 'location': 'B2-01', 'unit': 'Thùng', 'stock': 43, 'serverStock': 43, 'unitPrice': 120000, 'exportPrice': 144000, 'minStock': 10},
      {'name': 'Khoai tây chiên Poca 90g', 'barcode': '8934567890027', 'sku': 'B2-003', 'category': 'Thực phẩm', 'zone': 'B2', 'location': 'B2-02', 'unit': 'Thùng', 'stock': 58, 'serverStock': 58, 'unitPrice': 168000, 'exportPrice': 192000, 'minStock': 10},
      {'name': 'Kẹo mút Chupa Chups', 'barcode': '8934567890028', 'sku': 'B2-004', 'category': 'Thực phẩm', 'zone': 'B2', 'location': 'B2-02', 'unit': 'Thùng', 'stock': 90, 'serverStock': 90, 'unitPrice': 108000, 'exportPrice': 132000, 'minStock': 10},
      {'name': 'Bánh gạo One One 80g', 'barcode': '8934567890029', 'sku': 'B2-005', 'category': 'Thực phẩm', 'zone': 'B2', 'location': 'B2-03', 'unit': 'Thùng', 'stock': 37, 'serverStock': 37, 'unitPrice': 96000, 'exportPrice': 120000, 'minStock': 10},
      {'name': 'Snack Lays 70g', 'barcode': '8934567890030', 'sku': 'B2-006', 'category': 'Thực phẩm', 'zone': 'B2', 'location': 'B2-03', 'unit': 'Thùng', 'stock': 46, 'serverStock': 46, 'unitPrice': 144000, 'exportPrice': 168000, 'minStock': 10},
      {'name': 'Sữa đậu nành Fami 200ml', 'barcode': '8934567890031', 'sku': 'B2-007', 'category': 'Thực phẩm', 'zone': 'B2', 'location': 'B2-04', 'unit': 'Thùng', 'stock': 75, 'serverStock': 75, 'unitPrice': 120000, 'exportPrice': 144000, 'minStock': 10},
      {'name': 'Sữa Milo hộp 180ml', 'barcode': '8934567890032', 'sku': 'B2-008', 'category': 'Thực phẩm', 'zone': 'B2', 'location': 'B2-04', 'unit': 'Thùng', 'stock': 81, 'serverStock': 81, 'unitPrice': 180000, 'exportPrice': 204000, 'minStock': 10},
      // C1 — Đồ vệ sinh cá nhân
      {'name': 'Dầu gội Clear 200ml', 'barcode': '8934567890033', 'sku': 'C1-001', 'category': 'Vệ sinh', 'zone': 'C1', 'location': 'C1-01', 'unit': 'Thùng', 'stock': 40, 'serverStock': 40, 'unitPrice': 168000, 'exportPrice': 192000, 'minStock': 8},
      {'name': 'Dầu gội Sunsilk 180ml', 'barcode': '8934567890034', 'sku': 'C1-002', 'category': 'Vệ sinh', 'zone': 'C1', 'location': 'C1-01', 'unit': 'Thùng', 'stock': 35, 'serverStock': 35, 'unitPrice': 144000, 'exportPrice': 168000, 'minStock': 8},
      {'name': 'Sữa tắm Lifebuoy 250ml', 'barcode': '8934567890035', 'sku': 'C1-003', 'category': 'Vệ sinh', 'zone': 'C1', 'location': 'C1-02', 'unit': 'Thùng', 'stock': 28, 'serverStock': 28, 'unitPrice': 156000, 'exportPrice': 180000, 'minStock': 8},
      {'name': 'Xà phòng Lifebuoy 90g', 'barcode': '8934567890036', 'sku': 'C1-004', 'category': 'Vệ sinh', 'zone': 'C1', 'location': 'C1-02', 'unit': 'Thùng', 'stock': 55, 'serverStock': 55, 'unitPrice': 72000, 'exportPrice': 96000, 'minStock': 8},
      {'name': 'Kem đánh răng Colgate 120g', 'barcode': '8934567890037', 'sku': 'C1-005', 'category': 'Vệ sinh', 'zone': 'C1', 'location': 'C1-03', 'unit': 'Thùng', 'stock': 48, 'serverStock': 48, 'unitPrice': 144000, 'exportPrice': 168000, 'minStock': 8},
      {'name': 'Lăn khử mùi Rexona 40ml', 'barcode': '8934567890038', 'sku': 'C1-006', 'category': 'Vệ sinh', 'zone': 'C1', 'location': 'C1-03', 'unit': 'Thùng', 'stock': 32, 'serverStock': 32, 'unitPrice': 192000, 'exportPrice': 216000, 'minStock': 8},
      {'name': 'Nước súc miệng Listerine 250ml', 'barcode': '8934567890039', 'sku': 'C1-007', 'category': 'Vệ sinh', 'zone': 'C1', 'location': 'C1-04', 'unit': 'Thùng', 'stock': 20, 'serverStock': 20, 'unitPrice': 168000, 'exportPrice': 192000, 'minStock': 8},
      {'name': 'Khăn giấy ướt Bobby 100 tờ', 'barcode': '8934567890040', 'sku': 'C1-008', 'category': 'Vệ sinh', 'zone': 'C1', 'location': 'C1-04', 'unit': 'Thùng', 'stock': 15, 'serverStock': 15, 'unitPrice': 120000, 'exportPrice': 144000, 'minStock': 8},
      // C2 — Gia dụng, tẩy rửa
      {'name': 'Nước rửa chén Sunlight 750ml', 'barcode': '8934567890041', 'sku': 'C2-001', 'category': 'Gia dụng', 'zone': 'C2', 'location': 'C2-01', 'unit': 'Thùng', 'stock': 64, 'serverStock': 64, 'unitPrice': 108000, 'exportPrice': 132000, 'minStock': 10},
      {'name': 'Nước lau sàn Vim 500ml', 'barcode': '8934567890042', 'sku': 'C2-002', 'category': 'Gia dụng', 'zone': 'C2', 'location': 'C2-01', 'unit': 'Thùng', 'stock': 42, 'serverStock': 42, 'unitPrice': 84000, 'exportPrice': 108000, 'minStock': 10},
      {'name': 'Bột giặt Omo 1kg', 'barcode': '8934567890043', 'sku': 'C2-003', 'category': 'Gia dụng', 'zone': 'C2', 'location': 'C2-02', 'unit': 'Thùng', 'stock': 38, 'serverStock': 38, 'unitPrice': 120000, 'exportPrice': 144000, 'minStock': 10},
      {'name': 'Nước xả Comfort 500ml', 'barcode': '8934567890044', 'sku': 'C2-004', 'category': 'Gia dụng', 'zone': 'C2', 'location': 'C2-02', 'unit': 'Thùng', 'stock': 51, 'serverStock': 51, 'unitPrice': 96000, 'exportPrice': 120000, 'minStock': 10},
      {'name': 'Thuốc tẩy Javel 500ml', 'barcode': '8934567890045', 'sku': 'C2-005', 'category': 'Gia dụng', 'zone': 'C2', 'location': 'C2-03', 'unit': 'Thùng', 'stock': 25, 'serverStock': 25, 'unitPrice': 60000, 'exportPrice': 84000, 'minStock': 10},
      {'name': 'Túi rác 50x60 30c', 'barcode': '8934567890046', 'sku': 'C2-006', 'category': 'Gia dụng', 'zone': 'C2', 'location': 'C2-03', 'unit': 'Thùng', 'stock': 70, 'serverStock': 70, 'unitPrice': 48000, 'exportPrice': 72000, 'minStock': 10},
      {'name': 'Khăn giấy Pulppy 10c', 'barcode': '8934567890047', 'sku': 'C2-007', 'category': 'Gia dụng', 'zone': 'C2', 'location': 'C2-04', 'unit': 'Thùng', 'stock': 33, 'serverStock': 33, 'unitPrice': 72000, 'exportPrice': 96000, 'minStock': 10},
      {'name': 'Bọc nilon 30cm', 'barcode': '8934567890048', 'sku': 'C2-008', 'category': 'Gia dụng', 'zone': 'C2', 'location': 'C2-04', 'unit': 'Thùng', 'stock': 18, 'serverStock': 18, 'unitPrice': 36000, 'exportPrice': 60000, 'minStock': 10},
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
