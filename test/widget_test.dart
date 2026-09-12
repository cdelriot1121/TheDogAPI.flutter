import 'package:flutter_test/flutter_test.dart';
import 'package:thedogapi/main.dart';

void main() {
  testWidgets('Renders TheDogApiApp and search screen title', (WidgetTester tester) async {
    await tester.pumpWidget(const TheDogApiApp());
    expect(find.text('TheDogAPI'), findsOneWidget);
  });
}
