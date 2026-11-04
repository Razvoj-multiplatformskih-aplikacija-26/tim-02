import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mobile/data/catalog.dart';
import 'package:ui/ui.dart';

import 'support.dart';

void main() {
  setUpAll(() => initializeDateFormatting(serbianLatin));

  Future<void> pumpOnPhone(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(tester.view.reset);
    await pumpApp(tester);
  }

  Future<void> openEditor(WidgetTester tester) async {
    await pumpOnPhone(tester);
    await openTab(tester, 'Moje kompozicije');
    await tester.tap(find.text('Novi nacrt'));
    await tester.pumpAndSettle();
  }

  Future<void> openDraft(WidgetTester tester, String title) async {
    await pumpOnPhone(tester);
    await openTab(tester, 'Moje kompozicije');
    await tester.scrollUntilVisible(find.text(title), 300);
    await tester.tap(find.text(title));
    await tester.pumpAndSettle();
  }

  Future<void> pick(WidgetTester tester, String label, String option) async {
    await tester.ensureVisible(find.text(label));
    await tester.pumpAndSettle();
    await tester.tap(find.text(label));
    await tester.pumpAndSettle();
    final sheet = find.byType(BottomSheet);
    await tester.enterText(find.descendant(of: sheet, matching: find.byType(TextField)), option);
    await tester.pumpAndSettle();
    await tester.tap(find.descendant(of: sheet, matching: find.widgetWithText(ListTile, option)).first);
    await tester.pumpAndSettle();
  }

  Future<void> chooseHex(WidgetTester tester, String label) async {
    await tester.tap(find.bySemanticsLabel(RegExp('^$label')));
    await tester.pumpAndSettle();
  }

  testWidgets('shows the item limit as soon as a champion gets one item too many', (tester) async {
    final semantics = tester.ensureSemantics();
    await openEditor(tester);
    await chooseHex(tester, 'Red 1, kolona 1');
    await pick(tester, 'Šampion', 'Ahri');
    final message = 'Šampion može nositi najviše ${Unit.maxItems} predmeta.';
    for (final item in seedCatalog.items.take(Unit.maxItems)) {
      await pick(tester, 'Dodaj predmet', item.name);
    }
    expect(find.text(message), findsNothing);

    await pick(tester, 'Dodaj predmet', seedCatalog.items[Unit.maxItems].name);
    expect(find.text(message), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('keeps a draft without champions on the board from being saved', (tester) async {
    await openEditor(tester);
    await tester.enterText(find.widgetWithText(TextField, 'Naslov'), 'Prazan nacrt');
    await tester.tap(find.text('Sačuvaj'));
    await tester.pumpAndSettle();
    expect(find.text('Svaka varijanta mora imati šampione na tabli za kasnu igru.'), findsOneWidget);
    expect(find.text('NOVI NACRT'), findsOneWidget);
  });

  testWidgets('places and drags a champion and saves the draft under Nacrti', (tester) async {
    final semantics = tester.ensureSemantics();
    await openEditor(tester);
    await tester.enterText(find.widgetWithText(TextField, 'Naslov'), 'Moj nacrt');
    await chooseHex(tester, 'Red 1, kolona 1');
    await pick(tester, 'Šampion', 'Ahri');
    await tester.tap(find.text('Postavi na tablu'));
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel(RegExp(r'^Red 1, kolona 1\nAhri')), findsOneWidget);

    final drag = await tester.startGesture(tester.getCenter(find.bySemanticsLabel(RegExp(r'^Red 1, kolona 1\nAhri'))));
    await tester.pump(const Duration(seconds: 1));
    await drag.moveTo(tester.getCenter(find.bySemanticsLabel(RegExp('^Red 2, kolona 3'))));
    await tester.pump();
    await drag.up();
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel(RegExp(r'^Red 2, kolona 3\nAhri')), findsOneWidget);

    await tester.tap(find.text('Sačuvaj'));
    await tester.pumpAndSettle();
    expect(find.text('Nacrt je sačuvan.'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Moj nacrt'), 300);
    expect(find.text('NACRTI'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('asks before throwing away unsaved changes', (tester) async {
    await openEditor(tester);
    await tester.enterText(find.widgetWithText(TextField, 'Naslov'), 'Moj nacrt');
    await tester.pump();
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text('Odbaciti izmene?'), findsOneWidget);

    await tester.tap(find.text('Odbaci'));
    await tester.pumpAndSettle();
    expect(find.text('MOJE KOMPOZICIJE'), findsOneWidget);
    expect(find.text('NOVI NACRT'), findsNothing);
  });

  testWidgets('renames a draft without adding another', (tester) async {
    await openDraft(tester, 'Defender Cassiopeia');
    expect(find.text('UREDI NACRT'), findsOneWidget);

    await tester.enterText(find.widgetWithText(TextField, 'Naslov'), 'Cassiopeia tank');
    await tester.tap(find.text('Sačuvaj'));
    await tester.pumpAndSettle();
    expect(find.text('Cassiopeia tank'), findsOneWidget);
    expect(find.text('Defender Cassiopeia'), findsNothing);
    expect(find.text('Riftbeast nivo 9'), findsOneWidget);
  });

  testWidgets('brings a removed champion back with Poništi and deletes the draft after confirming', (tester) async {
    await openDraft(tester, 'Defender Cassiopeia');
    final remove = find.byTooltip('Ukloni').first;
    await tester.ensureVisible(remove);
    await tester.pumpAndSettle();
    await tester.tap(remove);
    await tester.pumpAndSettle();
    expect(find.text('Šampion je uklonjen sa table.'), findsOneWidget);
    await tester.tap(find.text('Poništi'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text('Odbaciti izmene?'), findsNothing);

    await tester.tap(find.text('Defender Cassiopeia'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Obriši nacrt'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Obriši'));
    await tester.pumpAndSettle();
    expect(find.text('Nacrt je obrisan.'), findsOneWidget);
    expect(find.text('Defender Cassiopeia'), findsNothing);
  });

  testWidgets("saves another creator's tactic as my draft", (tester) async {
    await pumpOnPhone(tester);
    await tester.tap(find.text('Draven na nivou 9'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sačuvaj kao nacrt'));
    await tester.pumpAndSettle();
    expect(find.text('NOVI NACRT'), findsOneWidget);
    expect(find.text('Draven na nivou 9'), findsOneWidget);

    await tester.tap(find.text('Sačuvaj'));
    await tester.pumpAndSettle();
    expect(find.text('Nacrt je sačuvan.'), findsOneWidget);
    expect(find.text('MOJE KOMPOZICIJE'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Draven na nivou 9'), 300);
    expect(find.text('NACRTI'), findsOneWidget);
  });
}
