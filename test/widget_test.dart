import 'package:flutter_test/flutter_test.dart';
import 'package:warehousepro_demo/main.dart';

void main() {
  testWidgets('App renders login screen', (WidgetTester tester) async {
    await tester.pumpWidget(const WarehouseProDemo());
    expect(find.text('WarehousePro'), findsOneWidget);
  });
}
