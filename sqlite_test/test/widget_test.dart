import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite_test/main.dart';

void main() {
  testWidgets('App renders title test', (WidgetTester tester) async {
    await tester.pumpWidget(const FruitListApp());
    expect(find.text('SQLite Fruit Manager'), findsOneWidget);
  });
}
