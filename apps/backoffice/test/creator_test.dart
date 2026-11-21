import 'package:backoffice/app.dart';
import 'package:backoffice/dependencies.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:ui/ui.dart';

void main() {
  setUpAll(() => initializeDateFormatting(serbianLatin));

  Future<void> pumpAsMarko(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      BackofficeApp(
        dependencies: BackofficeDependencies.fake(
          latency: Duration.zero,
          user: const User(id: UserId('u-marko'), name: 'Marko', role: Role.creator),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('a creator sees only his own tactics and publishes a draft without hiding anything', (tester) async {
    await pumpAsMarko(tester);
    expect(find.text('AP brzi nivo 9 sa Alune'), findsOneWidget);
    expect(find.text('Draven na nivou 9'), findsNothing);

    await tester.tap(find.text('AP brzi nivo 9 sa Alune'));
    await tester.pumpAndSettle();
    expect(find.text('Sakrij (H)'), findsNothing);
    expect(find.textContaining('Tier:'), findsNothing);

    await tester.tap(find.widgetWithText(FilledButton, 'Objavi'));
    await tester.pumpAndSettle();
    expect(find.text('Taktika je objavljena.'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Objavi'), findsNothing);
    expect(find.widgetWithText(OutlinedButton, 'Arhiviraj'), findsOneWidget);
  });

  testWidgets('a creator archives his own tactic after confirming', (tester) async {
    await pumpAsMarko(tester);
    await tester.tap(find.text('Caitlyn Hunters'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(OutlinedButton, 'Arhiviraj'));
    await tester.pumpAndSettle();
    expect(find.text('Arhivirana taktika više nije javno dostupna i ne može da se vrati.'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Arhiviraj'));
    await tester.pumpAndSettle();

    expect(find.text('Taktika je arhivirana.'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, 'Arhiviraj'), findsNothing);
  });
}
