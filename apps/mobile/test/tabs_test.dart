import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:ui/ui.dart';

import 'support.dart';

void main() {
  setUpAll(() => initializeDateFormatting(serbianLatin));

  testWidgets('shows everyone in Kompozicije and only Marko in Moje kompozicije', (tester) async {
    await pumpApp(tester);
    expect(find.text('Ahri Spellweaver'), findsOneWidget);
    expect(find.text('AP brzi nivo 9 sa Alune'), findsNothing);

    await openTab(tester, 'Moje kompozicije');
    expect(find.text('AP brzi nivo 9 sa Alune'), findsOneWidget);
    expect(find.text('Ahri Spellweaver'), findsNothing);
  });

  testWidgets('simulates a failed request from the debug menu and retries', (tester) async {
    await pumpApp(tester);

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
    await pumpApp(tester);

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

  testWidgets('archives my tactic after confirming in a dialog and keeps it when the request fails', (tester) async {
    await pumpApp(tester);
    await openTab(tester, 'Moje kompozicije');
    await tester.scrollUntilVisible(find.text('Caitlyn Hunters').hitTestable(), 300);
    await tester.tap(find.text('Caitlyn Hunters'));
    await tester.pumpAndSettle();

    Future<void> archive() async {
      await tester.tap(find.text('Arhiviraj'));
      await tester.pumpAndSettle();
      expect(find.text('Arhivirati taktiku?'), findsOneWidget);
      await tester.tap(find.widgetWithText(FilledButton, 'Arhiviraj'));
      await tester.pumpAndSettle();
    }

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Simuliraj grešku'));
    await tester.pumpAndSettle();
    await archive();
    expect(find.text('Izmena nije sačuvana.'), findsOneWidget);
    expect(find.text('Objavljena'), findsOneWidget);

    await tester.pump(const Duration(seconds: 5));
    await archive();
    expect(find.text('Taktika je arhivirana.'), findsOneWidget);
    expect(find.text('Arhivirana'), findsOneWidget);
    expect(find.text('Patch 18.5c: B'), findsNothing);
    expect(find.text('Arhiviraj'), findsNothing);
  });

  testWidgets('lists my saved lineups among the drafts', (tester) async {
    await pumpApp(tester);
    await openTab(tester, 'Moje kompozicije');
    expect(find.text('MOJE KOMPOZICIJE'), findsOneWidget);
    expect(find.text('Fae Ezreal za rangirano'), findsOneWidget);
    expect(find.text('AP brzi nivo 9 sa Alune'), findsOneWidget);
  });

  testWidgets('shows my archived tactics only behind the archive toggle', (tester) async {
    await pumpApp(tester);
    await openTab(tester, 'Moje kompozicije');
    expect(find.text('Veigar reroll'), findsOneWidget);
    expect(find.text('Warwick reroll'), findsNothing);

    await tester.tap(find.byTooltip('Arhivirane'));
    await tester.pumpAndSettle();
    expect(find.text('Warwick reroll'), findsOneWidget);
    expect(find.text('Caitlyn Hunters'), findsNothing);
    expect(find.text('Nova postava'), findsNothing);

    await tester.tap(find.byTooltip('Arhivirane'));
    await tester.pumpAndSettle();
    expect(find.text('Caitlyn Hunters'), findsOneWidget);
  });

  testWidgets('goes back from the archive to Moje kompozicije and from there to Kompozicije', (tester) async {
    await pumpApp(tester);
    await openTab(tester, 'Moje kompozicije');
    await tester.tap(find.byTooltip('Arhivirane'));
    await tester.pumpAndSettle();

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Caitlyn Hunters'), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('KOMPOZICIJE'), findsOneWidget);
    expect(find.text('Ahri Spellweaver'), findsOneWidget);
  });
}
