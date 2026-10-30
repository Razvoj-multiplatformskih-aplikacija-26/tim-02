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

  testWidgets('simulates a failed request from the debug menu and retries', (tester) async {
    await tester.pumpWidget(TftInsightsApp(dependencies: AppDependencies.fake(latency: Duration.zero)));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Simuliraj grešku'));
    await tester.pumpAndSettle();
    expect(find.text('Podaci trenutno nisu dostupni.'), findsOneWidget);

    await tester.tap(find.text('Pokušaj ponovo'));
    await tester.pumpAndSettle();
    expect(find.text('Ahri Spellweaver'), findsOneWidget);
  });

  testWidgets('opens a tactic from Kompozicije and switches its variant and board', (tester) async {
    await tester.pumpWidget(TftInsightsApp(dependencies: AppDependencies.fake(latency: Duration.zero)));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Elderwood Ezreal'));
    await tester.pumpAndSettle();
    expect(find.text('Elderwood Executioners · Brzi nivo 8 · Srednje'), findsOneWidget);

    await tester.tap(find.widgetWithText(ChoiceChip, 'Fae Ezreal'));
    await tester.pumpAndSettle();
    expect(find.text('Fae Ezreal · Brzi nivo 8 · Srednje'), findsOneWidget);
    final units = find.descendant(of: find.byType(LineupBoard), matching: find.byType(UnitHex));
    expect(units, findsNWidgets(11));

    await tester.tap(find.text('Rana igra'));
    await tester.pumpAndSettle();
    expect(find.text('Fae Ezreal · Brzi nivo 8 · Srednje'), findsOneWidget);
    expect(units, findsNWidgets(4));

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text('KOMPOZICIJE'), findsOneWidget);
  });
}
