import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
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
