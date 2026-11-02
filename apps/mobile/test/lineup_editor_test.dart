import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mobile/data/catalog.dart';
import 'package:ui/ui.dart';

import 'support.dart';

void main() {
  setUpAll(() => initializeDateFormatting(serbianLatin));

  Future<void> openEditor(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(tester.view.reset);
    await pumpApp(tester);
    await openTab(tester, 'Moje postave');
    await tester.tap(find.text('Nova postava'));
    await tester.pumpAndSettle();
  }

  Future<void> pick(WidgetTester tester, String label, String option) async {
    final field = find.widgetWithText(InputDecorator, label, skipOffstage: false);
    await tester.ensureVisible(field);
    await tester.tap(field);
    await tester.pumpAndSettle();
    await tester.tap(find.text(option).last);
    await tester.pumpAndSettle();
  }

  testWidgets('shows the item limit as soon as a champion gets one item too many', (tester) async {
    await openEditor(tester);
    await pick(tester, 'Šampion', 'Ahri');
    final message = 'Šampion može nositi najviše ${Unit.maxItems} predmeta.';
    for (final item in seedCatalog.items.take(Unit.maxItems)) {
      await pick(tester, 'Dodaj predmet', item.name);
    }
    expect(find.text(message), findsNothing);

    await pick(tester, 'Dodaj predmet', seedCatalog.items[Unit.maxItems].name);
    expect(find.text(message), findsOneWidget);
  });

  testWidgets('refuses a second champion on a taken hex and saves the lineup', (tester) async {
    await openEditor(tester);
    await tester.enterText(find.widgetWithText(TextField, 'Naziv postave'), 'Moja postava');
    await pick(tester, 'Šampion', 'Ahri');
    await pick(tester, 'Red', '1');
    await pick(tester, 'Kolona', '1');
    await tester.tap(find.text('Postavi na tablu'));
    await tester.pumpAndSettle();

    await pick(tester, 'Šampion', 'Akali');
    await pick(tester, 'Red', '1');
    await pick(tester, 'Kolona', '1');
    expect(find.text('Na ovom polju već stoji šampion.'), findsOneWidget);

    await tester.tap(find.text('Sačuvaj'));
    await tester.pumpAndSettle();
    expect(find.text('Postava je sačuvana.'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Moja postava'),
      300,
      scrollable: find.descendant(of: find.byType(ListView), matching: find.byType(Scrollable)),
    );
    expect(find.text('1 šampion'), findsOneWidget);
  });
}
