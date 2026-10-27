import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/main.dart';

void main() {
  testWidgets('starts', (tester) async {
    await tester.pumpWidget(const TftInsightsApp());
    expect(find.text('TFT Insights'), findsOneWidget);
  });
}
