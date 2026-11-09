import 'package:flutter_test/flutter_test.dart';
import 'package:campus_parking/main.dart';

void main() {
  testWidgets('SmartParking Campus app loads', (WidgetTester tester) async {
    await tester.pumpWidget(const SmartParkingApp());

    expect(find.text('SmartParking Campus'), findsOneWidget);
  });
}