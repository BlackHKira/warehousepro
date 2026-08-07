import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';
import '../services/product_service.dart';
import '../data/sample_products.dart';

final _productService = ProductService();

final productsProvider = StreamProvider<List<Product>>((ref) {
  return _productService.streamProducts().map((firestoreProducts) {
    if (firestoreProducts.isNotEmpty) return firestoreProducts;
    return sampleProducts;
  });
});

final productByIdProvider = FutureProvider.family<Product?, String>((ref, id) {
  return _productService.getProduct(id);
});

final productByBarcodeProvider =
    FutureProvider.family<Product?, String>((ref, barcode) {
  return _productService.getProductByBarcode(barcode);
});
