import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mobile/app.dart';
import 'package:mobile/dependencies.dart';
import 'package:ui/ui.dart';

import 'support.dart';

void main() {
  setUpAll(() => initializeDateFormatting(serbianLatin));

  Future<void> logIn(WidgetTester tester) async {
    await tester.enterText(find.widgetWithText(TextField, 'Korisničko ime'), 'marko');
    await tester.enterText(find.widgetWithText(TextField, 'Lozinka'), 'tft-demo');
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Prijavi se'));
    await tester.pumpAndSettle();
  }

  testWidgets('a visitor sees the comps, signs in from Moje kompozicije and finds the drafts there', (tester) async {
    await pumpApp(tester, signedIn: false);
    expect(find.text('Ahri Spellweaver'), findsOneWidget);

    await openTab(tester, 'Moje kompozicije');
    expect(find.text('Prijavite se da biste videli i čuvali svoje nacrte.'), findsOneWidget);
    expect(find.text('Novi nacrt'), findsNothing);

    await tester.tap(find.widgetWithText(FilledButton, 'Prijavi se'));
    await tester.pumpAndSettle();
    await logIn(tester);

    expect(find.text('MOJE KOMPOZICIJE'), findsOneWidget);
    expect(find.text('AP brzi nivo 9 sa Alune'), findsOneWidget);
    expect(find.text('Novi nacrt'), findsOneWidget);
  });

  testWidgets('a visitor signs in to save another creator\'s tactic as a draft and lands in the editor', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(tester.view.reset);
    await pumpApp(tester, signedIn: false);
    await tester.tap(find.text('Draven na nivou 9'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Sačuvaj kao nacrt'));
    await tester.pumpAndSettle();
    await logIn(tester);

    expect(find.text('NOVI NACRT'), findsOneWidget);
    expect(find.text('Draven na nivou 9'), findsOneWidget);
  });

  testWidgets('a retry after the server was down at start also brings my login back', (tester) async {
    final dependencies = AppDependencies.fake(latency: Duration.zero);
    dependencies.fakeSessions!.failingRequests = 1;
    dependencies.fakeTactics!.failingRequests = 1;
    await tester.pumpWidget(TftInsightsApp(dependencies: dependencies));
    await tester.pumpAndSettle();
    expect(find.text('Podaci trenutno nisu dostupni.'), findsOneWidget);

    await tester.tap(find.text('Pokušaj ponovo'));
    await tester.pumpAndSettle();
    await openTab(tester, 'Moje kompozicije');
    expect(find.text('AP brzi nivo 9 sa Alune'), findsOneWidget);
  });

  testWidgets('logging out hides my drafts again', (tester) async {
    await pumpApp(tester);
    await openTab(tester, 'Moje kompozicije');

    await tester.tap(find.text('M'));
    await tester.pumpAndSettle();
    expect(find.text('Kreator'), findsOneWidget);
    await tester.tap(find.text('Odjavi se'));
    await tester.pumpAndSettle();

    expect(find.text('Prijavite se da biste videli i čuvali svoje nacrte.'), findsOneWidget);
    expect(find.text('AP brzi nivo 9 sa Alune'), findsNothing);
  });

  testWidgets('an expired session opens the login with the reason and comes back after it', (tester) async {
    final dependencies = await pumpApp(tester);
    await openTab(tester, 'Moje kompozicije');

    dependencies.fakeSessions!.expire();
    await tester.pumpAndSettle();
    expect(find.text('Prijava je istekla. Prijavite se ponovo.'), findsOneWidget);

    await logIn(tester);
    expect(find.text('AP brzi nivo 9 sa Alune'), findsOneWidget);
  });
}
