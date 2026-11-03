import 'package:backoffice/app.dart';
import 'package:backoffice/dependencies.dart';
import 'package:flutter/material.dart';
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

    await tester.tap(find.byTooltip('Zatvori'));
    await tester.pumpAndSettle();
    expect(find.text('Draven na nivou 9'), findsOneWidget);
  });

  testWidgets('hides a tactic only with a long enough reason and restores it', (tester) async {
    await pumpBackoffice(tester);
    await tester.tap(find.text('Draven na nivou 9'));
    await tester.pumpAndSettle();
    expect(find.text('Vrati u javni prikaz'), findsNothing);

    await tester.tap(find.text('Sakrij'));
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

    await tester.tap(find.text('Vrati u javni prikaz'));
    await tester.pumpAndSettle();
    expect(find.text('Vrati u javni prikaz'), findsNothing);
    expect(find.text('Sakrij'), findsOneWidget);
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
}
