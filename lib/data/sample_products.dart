import '../models/product.dart';

final sampleProducts = [
  // A1 — Nước ngọt có gas (24 lon/thùng)
  Product(name: 'Coca Cola 355ml', barcode: '8934567890001', sku: 'A1-001', category: 'Nước giải khát', zone: 'A1', location: 'A1-01', unit: 'Cái', stock: 2016, minStock: 240, unitPerCase: 24, id: 'A1-001'),
  Product(name: 'Pepsi 355ml', barcode: '8934567890002', sku: 'A1-002', category: 'Nước giải khát', zone: 'A1', location: 'A1-01', unit: 'Cái', stock: 1488, minStock: 240, unitPerCase: 24, id: 'A1-002'),
  Product(name: 'Sting đỏ 330ml', barcode: '8934567890003', sku: 'A1-003', category: 'Nước giải khát', zone: 'A1', location: 'A1-02', unit: 'Cái', stock: 984, minStock: 240, unitPerCase: 24, id: 'A1-003'),
  Product(name: 'Number 1 355ml', barcode: '8934567890004', sku: 'A1-004', category: 'Nước giải khát', zone: 'A1', location: 'A1-02', unit: 'Cái', stock: 1320, minStock: 240, unitPerCase: 24, id: 'A1-004'),
  Product(name: '7Up 355ml', barcode: '8934567890005', sku: 'A1-005', category: 'Nước giải khát', zone: 'A1', location: 'A1-03', unit: 'Cái', stock: 792, minStock: 240, unitPerCase: 24, id: 'A1-005'),
  Product(name: 'Sprite 355ml', barcode: '8934567890006', sku: 'A1-006', category: 'Nước giải khát', zone: 'A1', location: 'A1-03', unit: 'Cái', stock: 672, minStock: 240, unitPerCase: 24, id: 'A1-006'),
  Product(name: 'Fanta cam 355ml', barcode: '8934567890007', sku: 'A1-007', category: 'Nước giải khát', zone: 'A1', location: 'A1-04', unit: 'Cái', stock: 456, minStock: 240, unitPerCase: 24, id: 'A1-007'),
  Product(name: 'Mirinda Cream Soda 330ml', barcode: '8934567890008', sku: 'A1-008', category: 'Nước giải khát', zone: 'A1', location: 'A1-04', unit: 'Cái', stock: 528, minStock: 240, unitPerCase: 24, id: 'A1-008'),

  // A2 — Nước lọc, trà, nước tăng lực (24 chai/thùng)
  Product(name: 'Aquafina 500ml', barcode: '8934567890009', sku: 'A2-001', category: 'Nước giải khát', zone: 'A2', location: 'A2-01', unit: 'Cái', stock: 2304, minStock: 240, unitPerCase: 24, id: 'A2-001'),
  Product(name: 'Trà xanh C2 500ml', barcode: '8934567890010', sku: 'A2-002', category: 'Nước giải khát', zone: 'A2', location: 'A2-01', unit: 'Cái', stock: 1728, minStock: 240, unitPerCase: 24, id: 'A2-002'),
  Product(name: 'Trà O Long Tea 500ml', barcode: '8934567890011', sku: 'A2-003', category: 'Nước giải khát', zone: 'A2', location: 'A2-02', unit: 'Cái', stock: 1152, minStock: 240, unitPerCase: 24, id: 'A2-003'),
  Product(name: 'Nước ép cam Twister 350ml', barcode: '8934567890012', sku: 'A2-004', category: 'Nước giải khát', zone: 'A2', location: 'A2-02', unit: 'Cái', stock: 840, minStock: 240, unitPerCase: 24, id: 'A2-004'),
  Product(name: 'Lavie 500ml', barcode: '8934567890013', sku: 'A2-005', category: 'Nước giải khát', zone: 'A2', location: 'A2-03', unit: 'Cái', stock: 1200, minStock: 240, unitPerCase: 24, id: 'A2-005'),
  Product(name: 'Dasani 500ml', barcode: '8934567890014', sku: 'A2-006', category: 'Nước giải khát', zone: 'A2', location: 'A2-03', unit: 'Cái', stock: 648, minStock: 240, unitPerCase: 24, id: 'A2-006'),
  Product(name: 'Red Bull 250ml', barcode: '8934567890015', sku: 'A2-007', category: 'Nước giải khát', zone: 'A2', location: 'A2-04', unit: 'Cái', stock: 1512, minStock: 240, unitPerCase: 24, id: 'A2-007'),
  Product(name: 'Monster 355ml', barcode: '8934567890016', sku: 'A2-008', category: 'Nước giải khát', zone: 'A2', location: 'A2-04', unit: 'Cái', stock: 312, minStock: 240, unitPerCase: 24, id: 'A2-008'),

  // B1 — Mì, cháo, phở (30 gói/thùng)
  Product(name: 'Mì tôm Hảo Hảo 75g', barcode: '8934567890017', sku: 'B1-001', category: 'Thực phẩm', zone: 'B1', location: 'B1-01', unit: 'Cái', stock: 3600, minStock: 450, unitPerCase: 30, id: 'B1-001'),
  Product(name: 'Mì tôm Omachi 75g', barcode: '8934567890018', sku: 'B1-002', category: 'Thực phẩm', zone: 'B1', location: 'B1-01', unit: 'Cái', stock: 2550, minStock: 450, unitPerCase: 30, id: 'B1-002'),
  Product(name: 'Mì ly Miliket 65g', barcode: '8934567890019', sku: 'B1-003', category: 'Thực phẩm', zone: 'B1', location: 'B1-02', unit: 'Cái', stock: 1800, minStock: 450, unitPerCase: 30, id: 'B1-003'),
  Product(name: 'Cháo gà Vifon 60g', barcode: '8934567890020', sku: 'B1-004', category: 'Thực phẩm', zone: 'B1', location: 'B1-02', unit: 'Cái', stock: 1320, minStock: 450, unitPerCase: 30, id: 'B1-004'),
  Product(name: 'Phở bò Vifon 65g', barcode: '8934567890021', sku: 'B1-005', category: 'Thực phẩm', zone: 'B1', location: 'B1-03', unit: 'Cái', stock: 1140, minStock: 450, unitPerCase: 30, id: 'B1-005'),
  Product(name: 'Mì Cung Đình 75g', barcode: '8934567890022', sku: 'B1-006', category: 'Thực phẩm', zone: 'B1', location: 'B1-03', unit: 'Cái', stock: 1560, minStock: 450, unitPerCase: 30, id: 'B1-006'),
  Product(name: 'Mì tôm Kokomi 80g', barcode: '8934567890023', sku: 'B1-007', category: 'Thực phẩm', zone: 'B1', location: 'B1-04', unit: 'Cái', stock: 2130, minStock: 450, unitPerCase: 30, id: 'B1-007'),
  Product(name: 'Bún gạo QBB 70g', barcode: '8934567890024', sku: 'B1-008', category: 'Thực phẩm', zone: 'B1', location: 'B1-04', unit: 'Cái', stock: 870, minStock: 450, unitPerCase: 30, id: 'B1-008'),

  // B2 — Bánh, kẹo, snack, sữa (12-24/thùng)
  Product(name: 'Bánh Oreo 97g', barcode: '8934567890025', sku: 'B2-001', category: 'Thực phẩm', zone: 'B2', location: 'B2-01', unit: 'Cái', stock: 804, minStock: 120, unitPerCase: 12, id: 'B2-001'),
  Product(name: 'Bánh Cosy 120g', barcode: '8934567890026', sku: 'B2-002', category: 'Thực phẩm', zone: 'B2', location: 'B2-01', unit: 'Cái', stock: 516, minStock: 120, unitPerCase: 12, id: 'B2-002'),
  Product(name: 'Khoai tây chiên Poca 90g', barcode: '8934567890027', sku: 'B2-003', category: 'Thực phẩm', zone: 'B2', location: 'B2-02', unit: 'Cái', stock: 696, minStock: 120, unitPerCase: 12, id: 'B2-003'),
  Product(name: 'Kẹo mút Chupa Chups', barcode: '8934567890028', sku: 'B2-004', category: 'Thực phẩm', zone: 'B2', location: 'B2-02', unit: 'Cái', stock: 2160, minStock: 240, unitPerCase: 24, id: 'B2-004'),
  Product(name: 'Bánh gạo One One 80g', barcode: '8934567890029', sku: 'B2-005', category: 'Thực phẩm', zone: 'B2', location: 'B2-03', unit: 'Cái', stock: 444, minStock: 120, unitPerCase: 12, id: 'B2-005'),
  Product(name: 'Snack Lays 70g', barcode: '8934567890030', sku: 'B2-006', category: 'Thực phẩm', zone: 'B2', location: 'B2-03', unit: 'Cái', stock: 552, minStock: 120, unitPerCase: 12, id: 'B2-006'),
  Product(name: 'Sữa đậu nành Fami 200ml', barcode: '8934567890031', sku: 'B2-007', category: 'Thực phẩm', zone: 'B2', location: 'B2-04', unit: 'Cái', stock: 1800, minStock: 240, unitPerCase: 24, id: 'B2-007'),
  Product(name: 'Sữa Milo hộp 180ml', barcode: '8934567890032', sku: 'B2-008', category: 'Thực phẩm', zone: 'B2', location: 'B2-04', unit: 'Cái', stock: 1944, minStock: 240, unitPerCase: 24, id: 'B2-008'),

  // C1 — Đồ vệ sinh cá nhân (12 chai/thùng)
  Product(name: 'Dầu gội Clear 200ml', barcode: '8934567890033', sku: 'C1-001', category: 'Vệ sinh', zone: 'C1', location: 'C1-01', unit: 'Cái', stock: 480, minStock: 96, unitPerCase: 12, id: 'C1-001'),
  Product(name: 'Dầu gội Sunsilk 180ml', barcode: '8934567890034', sku: 'C1-002', category: 'Vệ sinh', zone: 'C1', location: 'C1-01', unit: 'Cái', stock: 420, minStock: 96, unitPerCase: 12, id: 'C1-002'),
  Product(name: 'Sữa tắm Lifebuoy 250ml', barcode: '8934567890035', sku: 'C1-003', category: 'Vệ sinh', zone: 'C1', location: 'C1-02', unit: 'Cái', stock: 336, minStock: 96, unitPerCase: 12, id: 'C1-003'),
  Product(name: 'Xà phòng Lifebuoy 90g', barcode: '8934567890036', sku: 'C1-004', category: 'Vệ sinh', zone: 'C1', location: 'C1-02', unit: 'Cái', stock: 660, minStock: 96, unitPerCase: 12, id: 'C1-004'),
  Product(name: 'Kem đánh răng Colgate 120g', barcode: '8934567890037', sku: 'C1-005', category: 'Vệ sinh', zone: 'C1', location: 'C1-03', unit: 'Cái', stock: 1152, minStock: 192, unitPerCase: 24, id: 'C1-005'),
  Product(name: 'Lăn khử mùi Rexona 40ml', barcode: '8934567890038', sku: 'C1-006', category: 'Vệ sinh', zone: 'C1', location: 'C1-03', unit: 'Cái', stock: 384, minStock: 96, unitPerCase: 12, id: 'C1-006'),
  Product(name: 'Nước súc miệng Listerine 250ml', barcode: '8934567890039', sku: 'C1-007', category: 'Vệ sinh', zone: 'C1', location: 'C1-04', unit: 'Cái', stock: 240, minStock: 96, unitPerCase: 12, id: 'C1-007'),
  Product(name: 'Khăn giấy ướt Bobby 100 tờ', barcode: '8934567890040', sku: 'C1-008', category: 'Vệ sinh', zone: 'C1', location: 'C1-04', unit: 'Cái', stock: 180, minStock: 96, unitPerCase: 12, id: 'C1-008'),

  // C2 — Gia dụng, tẩy rửa (12 chai/thùng)
  Product(name: 'Nước rửa chén Sunlight 750ml', barcode: '8934567890041', sku: 'C2-001', category: 'Gia dụng', zone: 'C2', location: 'C2-01', unit: 'Cái', stock: 768, minStock: 120, unitPerCase: 12, id: 'C2-001'),
  Product(name: 'Nước lau sàn Vim 500ml', barcode: '8934567890042', sku: 'C2-002', category: 'Gia dụng', zone: 'C2', location: 'C2-01', unit: 'Cái', stock: 504, minStock: 120, unitPerCase: 12, id: 'C2-002'),
  Product(name: 'Bột giặt Omo 1kg', barcode: '8934567890043', sku: 'C2-003', category: 'Gia dụng', zone: 'C2', location: 'C2-02', unit: 'Cái', stock: 456, minStock: 120, unitPerCase: 12, id: 'C2-003'),
  Product(name: 'Nước xả Comfort 500ml', barcode: '8934567890044', sku: 'C2-004', category: 'Gia dụng', zone: 'C2', location: 'C2-02', unit: 'Cái', stock: 612, minStock: 120, unitPerCase: 12, id: 'C2-004'),
  Product(name: 'Thuốc tẩy Javel 500ml', barcode: '8934567890045', sku: 'C2-005', category: 'Gia dụng', zone: 'C2', location: 'C2-03', unit: 'Cái', stock: 300, minStock: 120, unitPerCase: 12, id: 'C2-005'),
  Product(name: 'Túi rác 50x60 30c', barcode: '8934567890046', sku: 'C2-006', category: 'Gia dụng', zone: 'C2', location: 'C2-03', unit: 'Cái', stock: 840, minStock: 120, unitPerCase: 12, id: 'C2-006'),
  Product(name: 'Khăn giấy Pulppy 10c', barcode: '8934567890047', sku: 'C2-007', category: 'Gia dụng', zone: 'C2', location: 'C2-04', unit: 'Cái', stock: 396, minStock: 120, unitPerCase: 12, id: 'C2-007'),
  Product(name: 'Bọc nilon 30cm', barcode: '8934567890048', sku: 'C2-008', category: 'Gia dụng', zone: 'C2', location: 'C2-04', unit: 'Cái', stock: 216, minStock: 120, unitPerCase: 12, id: 'C2-008'),
];
