import '../models/product.dart';

final sampleProducts = [
  // A1 — Nước ngọt có gas (24 lon/thùng)
  Product(name: 'Coca Cola 355ml', barcode: '8934567890001', sku: 'A1-001', category: 'Nước ngọt', zone: 'A1', unit: 'Lon', stock: 2016, minStock: 240, unitPerCase: 24, id: 'A1-001'),
  Product(name: 'Pepsi 355ml', barcode: '8934567890002', sku: 'A1-002', category: 'Nước ngọt', zone: 'A1', unit: 'Lon', stock: 1488, minStock: 240, unitPerCase: 24, id: 'A1-002'),
  Product(name: 'Sting đỏ 330ml', barcode: '8934567890003', sku: 'A1-003', category: 'Nước ngọt', zone: 'A1', unit: 'Lon', stock: 984, minStock: 240, unitPerCase: 24, id: 'A1-003'),
  Product(name: 'Number 1 355ml', barcode: '8934567890004', sku: 'A1-004', category: 'Nước ngọt', zone: 'A1', unit: 'Lon', stock: 1320, minStock: 240, unitPerCase: 24, id: 'A1-004'),
  Product(name: '7Up 355ml', barcode: '8934567890005', sku: 'A1-005', category: 'Nước ngọt', zone: 'A1', unit: 'Lon', stock: 792, minStock: 240, unitPerCase: 24, id: 'A1-005'),
  Product(name: 'Sprite 355ml', barcode: '8934567890006', sku: 'A1-006', category: 'Nước ngọt', zone: 'A1', unit: 'Lon', stock: 672, minStock: 240, unitPerCase: 24, id: 'A1-006'),
  Product(name: 'Fanta cam 355ml', barcode: '8934567890007', sku: 'A1-007', category: 'Nước ngọt', zone: 'A1', unit: 'Lon', stock: 456, minStock: 240, unitPerCase: 24, id: 'A1-007'),
  Product(name: 'Mirinda Cream Soda 330ml', barcode: '8934567890008', sku: 'A1-008', category: 'Nước ngọt', zone: 'A1', unit: 'Lon', stock: 528, minStock: 240, unitPerCase: 24, id: 'A1-008'),

  // B1 — Nước tăng lực (24 lon/thùng)
  Product(name: 'Red Bull 250ml', barcode: '8934567890015', sku: 'B1-001', category: 'Nước tăng lực', zone: 'B1', unit: 'Lon', stock: 1512, minStock: 240, unitPerCase: 24, id: 'B1-001'),
  Product(name: 'Monster 355ml', barcode: '8934567890016', sku: 'B1-002', category: 'Nước tăng lực', zone: 'B1', unit: 'Lon', stock: 312, minStock: 240, unitPerCase: 24, id: 'B1-002'),

  // B2 — Nước tăng lực (24 lon/thùng)
  Product(name: 'Sting Vàng 250ml', barcode: '8934567890031', sku: 'B2-001', category: 'Nước tăng lực', zone: 'B2', unit: 'Lon', stock: 800, minStock: 240, unitPerCase: 24, id: 'B2-001'),
  Product(name: 'Cobra Strike 250ml', barcode: '8934567890032', sku: 'B2-002', category: 'Nước tăng lực', zone: 'B2', unit: 'Lon', stock: 600, minStock: 240, unitPerCase: 24, id: 'B2-002'),
  Product(name: 'Warrior 250ml (hộp thiếc)', barcode: '8934567890033', sku: 'B2-003', category: 'Nước tăng lực', zone: 'B2', unit: 'Lon', stock: 720, minStock: 240, unitPerCase: 24, id: 'B2-003'),

  // C1 — Nước lọc (24 chai/thùng)
  Product(name: 'Aquafina 500ml', barcode: '8934567890009', sku: 'C1-001', category: 'Nước lọc', zone: 'C1', unit: 'Chai', stock: 2304, minStock: 240, unitPerCase: 24, id: 'C1-001'),
  Product(name: 'Lavie 500ml', barcode: '8934567890013', sku: 'C1-002', category: 'Nước lọc', zone: 'C1', unit: 'Chai', stock: 1200, minStock: 240, unitPerCase: 24, id: 'C1-002'),
  Product(name: 'Dasani 500ml', barcode: '8934567890014', sku: 'C1-003', category: 'Nước lọc', zone: 'C1', unit: 'Chai', stock: 648, minStock: 240, unitPerCase: 24, id: 'C1-003'),
  Product(name: 'Imsong 500ml', barcode: '8934567890034', sku: 'C1-004', category: 'Nước lọc', zone: 'C1', unit: 'Chai', stock: 1200, minStock: 240, unitPerCase: 24, id: 'C1-004'),
  Product(name: 'Vihawa 500ml', barcode: '8934567890035', sku: 'C1-005', category: 'Nước lọc', zone: 'C1', unit: 'Chai', stock: 800, minStock: 240, unitPerCase: 24, id: 'C1-005'),
  Product(name: 'Buddha 500ml', barcode: '8934567890036', sku: 'C1-006', category: 'Nước lọc', zone: 'C1', unit: 'Chai', stock: 600, minStock: 240, unitPerCase: 24, id: 'C1-006'),

  // C2 — Trà (24 chai/thùng)
  Product(name: 'Trà xanh C2 500ml', barcode: '8934567890010', sku: 'C2-001', category: 'Trà', zone: 'C2', unit: 'Chai', stock: 1728, minStock: 240, unitPerCase: 24, id: 'C2-001'),
  Product(name: 'Trà ô long T-Plus 500ml', barcode: '8934567890049', sku: 'C2-002', category: 'Trà', zone: 'C2', unit: 'Chai', stock: 0, minStock: 240, unitPerCase: 24, id: 'C2-002'),
  Product(name: 'Trà xanh Không độ 500ml', barcode: '8934567890037', sku: 'C2-003', category: 'Trà', zone: 'C2', unit: 'Chai', stock: 900, minStock: 240, unitPerCase: 24, id: 'C2-003'),
  Product(name: 'Trà sen Tây Hồ 500ml', barcode: '8934567890038', sku: 'C2-004', category: 'Trà', zone: 'C2', unit: 'Chai', stock: 500, minStock: 240, unitPerCase: 24, id: 'C2-004'),
  Product(name: 'Trà nhài Ilsbean 500ml', barcode: '8934567890039', sku: 'C2-005', category: 'Trà', zone: 'C2', unit: 'Chai', stock: 400, minStock: 240, unitPerCase: 24, id: 'C2-005'),
];
