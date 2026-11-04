import 'package:backoffice/app.dart';
import 'package:backoffice/dependencies.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:ui/ui.dart';

Future<void> pumpBackoffice(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1280, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(BackofficeApp(dependencies: BackofficeDependencies.fake(latency: Duration.zero)));
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() => initializeDateFormatting(serbianLatin));

  testWidgets('lists every tactic for the admin and filters the hidden ones', (tester) async {
    await pumpBackoffice(tester);
    expect(find.text('AP brzi nivo 9 sa Alune'), findsOneWidget);

    await tester.tap(find.text('Sakrivene'));
    await tester.pumpAndSettle();
    expect(find.text('Veigar reroll'), findsOneWidget);
    expect(find.text('AP brzi nivo 9 sa Alune'), findsNothing);
  });

  testWidgets('opens a tactic in the side panel and closes it', (tester) async {
    await pumpBackoffice(tester);

    await tester.tap(find.text('Draven na nivou 9'));
    await tester.pumpAndSettle();
    expect(find.text('Draven na nivou 9'), findsNWidgets(2));

    await tester.tap(find.byTooltip('Zatvori (Esc)'));
    await tester.pumpAndSettle();
    expect(find.text('Draven na nivou 9'), findsOneWidget);
  });

  testWidgets('hides a tactic only with a long enough reason and restores it', (tester) async {
    await pumpBackoffice(tester);
    await tester.tap(find.text('Draven na nivou 9'));
    await tester.pumpAndSettle();
    expect(find.text('Vrati u javni prikaz (R)'), findsNothing);

    await tester.tap(find.text('Sakrij (H)'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, 'Obrazloženje'), 'Kopija');
    await tester.pump();
    expect(find.text('Obrazloženje mora imati bar 10 znakova.'), findsOneWidget);

    await tester.enterText(find.widgetWithText(TextField, 'Obrazloženje'), 'Kopija tuđe taktike');
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Sakrij'));
    await tester.pumpAndSettle();
    expect(find.text('Taktika je sakrivena.'), findsOneWidget);
    expect(find.text('Kopija tuđe taktike'), findsOneWidget);

    await tester.tap(find.text('Vrati u javni prikaz (R)'));
    await tester.pumpAndSettle();
    expect(find.text('Vrati u javni prikaz (R)'), findsNothing);
    expect(find.text('Sakrij (H)'), findsOneWidget);
  });

  testWidgets('edits the title and a board of a tactic and saves it', (tester) async {
    final semantics = tester.ensureSemantics();
    await pumpBackoffice(tester);
    await tester.tap(find.text('Draven na nivou 9'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Uredi (E)'));
    await tester.pumpAndSettle();
    expect(find.text('UREDI TAKTIKU'), findsOneWidget);

    await tester.enterText(find.widgetWithText(TextFormField, 'Naslov'), 'Draven i Ezreal');
    await tester.tap(find.bySemanticsLabel(RegExp('^Red 1, kolona 1')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Šampion'));
    await tester.pumpAndSettle();
    final sheet = find.byType(BottomSheet);
    await tester.enterText(find.descendant(of: sheet, matching: find.byType(TextField)), 'Ahri');
    await tester.pumpAndSettle();
    await tester.tap(find.descendant(of: sheet, matching: find.widgetWithText(ListTile, 'Ahri')).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Postavi na tablu'));
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel(RegExp(r'^Red 1, kolona 1\nAhri')), findsOneWidget);
    await tester.tap(find.text('Sačuvaj'));
    await tester.pumpAndSettle();

    expect(find.text('Taktika je sačuvana.'), findsOneWidget);
    expect(find.text('Draven i Ezreal'), findsNWidgets(2));
    semantics.dispose();
  });

  testWidgets('asks before throwing away an edited tactic', (tester) async {
    await pumpBackoffice(tester);
    await tester.tap(find.text('Draven na nivou 9'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Uredi (E)'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextFormField, 'Naslov'), 'Draven i Ezreal');
    await tester.pump();

    await tester.tap(find.text('Odustani'));
    await tester.pumpAndSettle();
    expect(find.text('Odbaciti izmene?'), findsOneWidget);
    await tester.tap(find.text('Odbaci'));
    await tester.pumpAndSettle();
    expect(find.text('UREDI TAKTIKU'), findsNothing);
    expect(find.text('Draven na nivou 9'), findsNWidgets(2));
  });

  testWidgets('lets the admin move a published tactic to another tier', (tester) async {
    await pumpBackoffice(tester);
    await tester.tap(find.text('Draven na nivou 9'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tier: S'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(MenuItemButton, 'A'));
    await tester.pumpAndSettle();

    expect(find.text('Taktika je sada u tieru A.'), findsOneWidget);
    expect(find.text('Tier: A'), findsOneWidget);
  });

  testWidgets('moves the selection with the arrows, hides with H, edits with E and clears it with Esc', (tester) async {
    await pumpBackoffice(tester);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pumpAndSettle();
    expect(find.text('AP brzi nivo 9 sa Alune'), findsNWidgets(2));

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pumpAndSettle();
    expect(find.text('Primal Flex'), findsNWidgets(2));

    await tester.sendKeyEvent(LogicalKeyboardKey.keyH);
    await tester.pumpAndSettle();
    expect(find.text('Sakriti taktiku?'), findsOneWidget);
    await tester.tap(find.text('Odustani'));
    await tester.pumpAndSettle();

    await tester.sendKeyEvent(LogicalKeyboardKey.keyE);
    await tester.pumpAndSettle();
    expect(find.text('UREDI TAKTIKU'), findsOneWidget);
    await tester.tap(find.text('Odustani'));
    await tester.pumpAndSettle();

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.text('Primal Flex'), findsOneWidget);
  });

  testWidgets('outlines the table only after an arrow key and drops the outline on a click', (tester) async {
    final outline = find.byWidgetPredicate(
      (widget) => switch (widget) {
        DecoratedBox(position: DecorationPosition.foreground, decoration: BoxDecoration(border: _?)) => true,
        _ => false,
      },
    );
    await pumpBackoffice(tester);
    await tester.sendKeyEvent(LogicalKeyboardKey.shiftLeft);
    await tester.pump();
    expect(outline, findsNothing);

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pumpAndSettle();
    expect(outline, findsOneWidget);

    await tester.tap(find.text('Primal Flex'));
    await tester.pumpAndSettle();
    expect(outline, findsNothing);
  });

  testWidgets('shows a list with a bottom panel in a narrow window and keeps the selection when widened', (
    tester,
  ) async {
    await pumpBackoffice(tester);
    tester.view.physicalSize = const Size(700, 900);
    await tester.pumpAndSettle();
    expect(find.byType(ListTile), findsWidgets);

    await tester.tap(find.text('Draven na nivou 9'));
    await tester.pumpAndSettle();
    expect(find.text('Draven na nivou 9'), findsNWidgets(2));

    tester.view.physicalSize = const Size(1280, 800);
    await tester.pumpAndSettle();
    expect(find.byType(ListTile), findsNothing);
    expect(find.text('Draven na nivou 9'), findsNWidgets(2));
  });

  testWidgets('searches the tactics by title or author', (tester) async {
    await pumpBackoffice(tester);
    final search = find.widgetWithText(TextField, 'Naslov ili autor');
    await tester.enterText(search, 'luka');
    await tester.pumpAndSettle();
    expect(find.text('Solar Blossom'), findsOneWidget);
    expect(find.text('AP brzi nivo 9 sa Alune'), findsNothing);

    await tester.enterText(search, 'draven');
    await tester.pumpAndSettle();
    expect(find.text('Draven na nivou 9'), findsOneWidget);
    expect(find.text('Solar Blossom'), findsNothing);
  });

  testWidgets('types H into the search without hiding the selected tactic', (tester) async {
    await pumpBackoffice(tester);
    await tester.tap(find.text('Draven na nivou 9'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextField, 'Naslov ili autor'));
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.keyH);
    await tester.pumpAndSettle();
    expect(find.text('Sakriti taktiku?'), findsNothing);
  });

  testWidgets('shows only the tactics of the chosen tier', (tester) async {
    await pumpBackoffice(tester);
    await tester.tap(find.text('Svi tierovi'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(MenuItemButton, 'A'));
    await tester.pumpAndSettle();
    expect(find.text('Tier: A'), findsOneWidget);
    expect(find.text('Ahri Spellweaver'), findsOneWidget);
    expect(find.text('Draven na nivou 9'), findsNothing);
  });
}
