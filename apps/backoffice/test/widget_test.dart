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

  testWidgets('searches the tactics by title or author', (tester) async {
    await pumpBackoffice(tester);
    await tester.enterText(find.byType(TextField), 'luka');
    await tester.pumpAndSettle();
    expect(find.text('Solar Blossom'), findsOneWidget);
    expect(find.text('AP brzi nivo 9 sa Alune'), findsNothing);

    await tester.enterText(find.byType(TextField), 'draven');
    await tester.pumpAndSettle();
    expect(find.text('Draven na nivou 9'), findsOneWidget);
    expect(find.text('Solar Blossom'), findsNothing);
  });
}
