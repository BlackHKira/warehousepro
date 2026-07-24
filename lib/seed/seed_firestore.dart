import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SeedFirestore {
  final FirebaseFirestore db = FirebaseFirestore.instanceFor(
    app: Firebase.app(),
    databaseId: 'warehousepro-db',
  );

  ///========================
  /// USERS
  ///========================
  Future<void> seedUsers() async {
    final users = [
      {
        "id": "U001",
        "email": "admin@warehousepro.com",
        "password": "123456",
        "fullName": "Nguyễn Thanh Quân",
        "phone": "0901234567",
        "role": "manager",
        "isActive": true,
      },
      {
        "id": "U002",
        "email": "kho01@warehousepro.com",
        "password": "123456",
        "fullName": "Nguyễn Văn Nam",
        "phone": "0912345678",
        "role": "warehouse_staff",
        "isActive": true,
      },
      {
        "id": "U003",
        "email": "kho02@warehousepro.com",
        "password": "123456",
        "fullName": "Trần Văn Bình",
        "phone": "0988888888",
        "role": "warehouse_staff",
        "isActive": true,
      }
    ];

    for (var user in users) {
      await db.collection("users").doc(user["id"] as String).set({
        ...user,
        "createdAt": FieldValue.serverTimestamp(),
      });
    }
  }

  ///========================
  /// PRODUCTS
  ///========================
  Future<void> seedProducts() async {
    final products = [
      {
        "id": "SP001",
        "barcode": "893504950001",
        "name": "Coca-Cola lon 330ml",
        "category": "Nước ngọt",
        "unit": "Lon",
        "stock": 1200,
        "warehouseLocation": "A1-01",
        "isActive": true
      },
      {
        "id": "SP002",
        "barcode": "893504950002",
        "name": "Pepsi lon 330ml",
        "category": "Nước ngọt",
        "unit": "Lon",
        "stock": 950,
        "warehouseLocation": "A1-02",
        "isActive": true
      },
      {
        "id": "SP003",
        "barcode": "893504950003",
        "name": "Fanta Cam lon 330ml",
        "category": "Nước ngọt",
        "unit": "Lon",
        "stock": 800,
        "warehouseLocation": "A1-03",
        "isActive": true
      },
      {
        "id": "SP004",
        "barcode": "893504950004",
        "name": "Sprite lon 330ml",
        "category": "Nước ngọt",
        "unit": "Lon",
        "stock": 780,
        "warehouseLocation": "A1-04",
        "isActive": true
      },
      {
        "id": "SP005",
        "barcode": "893504950005",
        "name": "7UP lon 330ml",
        "category": "Nước ngọt",
        "unit": "Lon",
        "stock": 620,
        "warehouseLocation": "A1-05",
        "isActive": true
      },
      {
        "id": "SP006",
        "barcode": "893504950006",
        "name": "Sting Đỏ lon 330ml",
        "category": "Nước tăng lực",
        "unit": "Lon",
        "stock": 900,
        "warehouseLocation": "A2-01",
        "isActive": true
      },
      {
        "id": "SP007",
        "barcode": "893504950007",
        "name": "Red Bull lon 250ml",
        "category": "Nước tăng lực",
        "unit": "Lon",
        "stock": 700,
        "warehouseLocation": "A2-02",
        "isActive": true
      },
      {
        "id": "SP008",
        "barcode": "893504950008",
        "name": "Warrior lon 330ml",
        "category": "Nước tăng lực",
        "unit": "Lon",
        "stock": 550,
        "warehouseLocation": "A2-03",
        "isActive": true
      },
      {
        "id": "SP009",
        "barcode": "893504950009",
        "name": "Aquafina 500ml",
        "category": "Nước suối",
        "unit": "Chai",
        "stock": 1500,
        "warehouseLocation": "B1-01",
        "isActive": true
      },
      {
        "id": "SP010",
        "barcode": "893504950010",
        "name": "C2 Trà Chanh",
        "category": "Trà",
        "unit": "Chai",
        "stock": 980,
        "warehouseLocation": "B1-02",
        "isActive": true
      },
    ];

    for (var p in products) {
      await db.collection("products").doc(p["id"] as String).set({
        ...p,
        "updatedAt": FieldValue.serverTimestamp(),
      });
    }
  }

  ///========================
  /// EXPORT ORDERS
  ///========================
  Future<void> seedExportOrders() async {
    await db.collection("export_orders").doc("EX0001").set({
      "orderId": "EX0001",
      "customerName": "Đại lý Hồng Quân",
      "createdBy": "U001",
      "status": "pending",
      "totalItems": 2,
      "note": "Giao trước 16h",
      "createdAt": FieldValue.serverTimestamp(),
      "completedAt": null,
    });
  }

  ///========================
  /// IMPORT ORDERS
  ///========================
  Future<void> seedImportOrders() async {
    await db.collection("import_orders").doc("IM0001").set({
      "orderId": "IM0001",
      "supplierName": "Coca-Cola Việt Nam",
      "createdBy": "U002",
      "status": "completed",
      "totalItems": 1,
      "createdAt": FieldValue.serverTimestamp(),
      "completedAt": FieldValue.serverTimestamp(),
    });
  }

  ///========================
  /// STOCK TRANSACTIONS
  ///========================
  Future<void> seedStockTransactions() async {
    await db.collection("stock_transactions").doc("TX0001").set({
      "id": "TX0001",
      "type": "import",
      "voucherId": "IM0001",
      "productId": "SP001",
      "productBarcode": "893504950001",
      "productName": "Coca-Cola lon 330ml",
      "quantity": 500,
      "performedBy": "U002",
      "reference": "Nhập từ Coca-Cola VN",
      "syncStatus": "synced",
      "createdAt": FieldValue.serverTimestamp(),
    });
  }

  ///========================
  /// STOCK COUNTS
  ///========================
  Future<void> seedStockCounts() async {
    await db.collection("stock_counts").doc("SC0001").set({
      "id": "SC0001",
      "location": "A1",
      "performedBy": "U002",
      "status": "submitted",
      "performedAt": FieldValue.serverTimestamp(),
    });
  }

  ///========================
  /// SEED ALL
  ///========================
  Future<void> seedAll() async {
    await seedUsers();
    await seedProducts();
    await seedExportOrders();
    await seedImportOrders();
    await seedStockTransactions();
    await seedStockCounts();

    print("========== FIRESTORE SEEDED ==========");
  }
}