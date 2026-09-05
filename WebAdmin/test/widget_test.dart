import 'package:admin_app/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Admin App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const BulkifyAdminApp());
  });
}
