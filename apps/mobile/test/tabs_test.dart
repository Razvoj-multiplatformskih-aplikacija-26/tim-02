import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mobile/app.dart';
import 'package:mobile/dependencies.dart';
import 'package:ui/ui.dart';

void main() {
  setUpAll(() => initializeDateFormatting(serbianLatin));

  testWidgets('shows everyone in Kompozicije and only Marko in Moje taktike', (tester) async {
    await tester.pumpWidget(TftInsightsApp(dependencies: AppDependencies.fake(latency: Duration.zero)));
    await tester.pumpAndSettle();
    expect(find.text('Ahri Spellweaver'), findsOneWidget);
    expect(find.text('AP brzi nivo 9 sa Alune'), findsNothing);

    await tester.tap(find.descendant(of: find.byType(NavigationBar), matching: find.text('Moje taktike')));
    await tester.pumpAndSettle();
    expect(find.text('AP brzi nivo 9 sa Alune'), findsOneWidget);
    expect(find.text('Ahri Spellweaver'), findsNothing);
  });
}
