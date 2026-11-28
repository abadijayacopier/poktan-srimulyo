import 'package:flutter_test/flutter_test.dart';
import 'package:poktan_srimulyo/main.dart';

void main() {
  testWidgets('Poktan Sri Mulyo App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const PoktanSriMulyoApp());
    expect(find.text('Poktan Sri Mulyo'), findsWidgets);
  });
}
