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
    await tester.tap(find.text('Nova postava'));
    await tester.pumpAndSettle();
  }

  Future<void> openLineup(WidgetTester tester, String name) async {
    await pumpOnPhone(tester);
    await openTab(tester, 'Moje kompozicije');
    await tester.scrollUntilVisible(find.text(name), 300);
    await tester.tap(find.text(name));
    await tester.pumpAndSettle();
  }

  Future<void> pick<T extends Object>(WidgetTester tester, String label, String option) async {
    final field = find.descendant(of: find.widgetWithText(DropdownMenu<T>, label), matching: find.byType(TextField));
    await tester.ensureVisible(field);
    await tester.enterText(field, option);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(MenuItemButton, option).last);
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
    await pick<Champion>(tester, 'Šampion', 'Ahri');
    final message = 'Šampion može nositi najviše ${Unit.maxItems} predmeta.';
    for (final item in seedCatalog.items.take(Unit.maxItems)) {
      await pick<Item>(tester, 'Dodaj predmet', item.name);
    }
    expect(find.text(message), findsNothing);

    await pick<Item>(tester, 'Dodaj predmet', seedCatalog.items[Unit.maxItems].name);
    expect(find.text(message), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('places a champion on the tapped hex and saves the lineup under Postave', (tester) async {
    final semantics = tester.ensureSemantics();
    await openEditor(tester);
    await tester.enterText(find.widgetWithText(TextField, 'Naziv postave'), 'Moja postava');
    await chooseHex(tester, 'Red 1, kolona 1');
    await pick<Champion>(tester, 'Šampion', 'Ahri');
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
    expect(find.text('Postava je sačuvana.'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Moja postava'), 300);
    expect(find.text('POSTAVE'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('asks before throwing away unsaved changes', (tester) async {
    await openEditor(tester);
    await tester.enterText(find.widgetWithText(TextField, 'Naziv postave'), 'Moja postava');
    await tester.pump();
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text('Odbaciti izmene?'), findsOneWidget);

    await tester.tap(find.text('Odbaci'));
    await tester.pumpAndSettle();
    expect(find.text('MOJE KOMPOZICIJE'), findsOneWidget);
    expect(find.text('NOVA POSTAVA'), findsNothing);
  });

  testWidgets('renames a saved lineup without adding another', (tester) async {
    await openLineup(tester, 'Fae Ezreal za rangirano');
    expect(find.text('UREDI POSTAVU'), findsOneWidget);

    await tester.enterText(find.widgetWithText(TextField, 'Naziv postave'), 'Fae Ezreal');
    await tester.tap(find.text('Sačuvaj'));
    await tester.pumpAndSettle();
    expect(find.text('Fae Ezreal'), findsOneWidget);
    expect(find.text('Fae Ezreal za rangirano'), findsNothing);
    expect(find.text('Draven sa zmajevima'), findsOneWidget);
  });

  testWidgets('brings a removed champion back with Poništi and deletes the lineup after confirming', (tester) async {
    await openLineup(tester, 'Fae Ezreal za rangirano');
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

    await tester.tap(find.text('Fae Ezreal za rangirano'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Obriši postavu'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Obriši'));
    await tester.pumpAndSettle();
    expect(find.text('Postava je obrisana.'), findsOneWidget);
    expect(find.text('Fae Ezreal za rangirano'), findsNothing);
  });

  testWidgets("saves another creator's tactic as a lineup once and then opens it", (tester) async {
    await pumpOnPhone(tester);
    await tester.tap(find.text('Draven na nivou 9'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sačuvaj kao postavu'));
    await tester.pumpAndSettle();
    expect(find.text('NOVA POSTAVA'), findsOneWidget);
    expect(find.text('Draven na nivou 9'), findsOneWidget);

    await tester.tap(find.text('Sačuvaj'));
    await tester.pumpAndSettle();
    expect(find.text('Postava je sačuvana.'), findsOneWidget);
    expect(find.text('MOJE KOMPOZICIJE'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Draven na nivou 9'), 300);

    await openTab(tester, 'Kompozicije');
    await tester.tap(find.text('Draven na nivou 9'));
    await tester.pumpAndSettle();
    expect(find.text('Otvori postavu'), findsOneWidget);
    expect(find.text('Sačuvaj kao postavu'), findsNothing);
  });
}
