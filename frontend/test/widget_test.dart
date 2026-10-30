import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/main.dart';

void main() {
  testWidgets('App launches smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(SGCarRentApp());
    expect(find.byType(SGCarRentApp), findsOneWidget);
    await tester.pumpAndSettle(Duration(seconds: 3));
  });
}
