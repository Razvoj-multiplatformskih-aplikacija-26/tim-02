import 'package:backoffice/app.dart';
import 'package:backoffice/dependencies.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:ui/ui.dart';

void main() {
  setUpAll(() => initializeDateFormatting(serbianLatin));

  Future<BackofficeDependencies> pump(WidgetTester tester, {User user = BackofficeDependencies.ana}) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final dependencies = BackofficeDependencies.fake(latency: Duration.zero, user: user, signedIn: false);
    await tester.pumpWidget(BackofficeApp(dependencies: dependencies));
    await tester.pumpAndSettle();
    return dependencies;
  }

  Future<void> logIn(WidgetTester tester) async {
    await tester.enterText(find.widgetWithText(TextField, 'Korisničko ime'), 'ana');
    await tester.enterText(find.widgetWithText(TextField, 'Lozinka'), 'tft-demo');
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Prijavi se'));
    await tester.pumpAndSettle();
  }

  testWidgets('refuses a player', (tester) async {
    await pump(
      tester,
      user: const User(id: UserId('u-petar'), name: 'Petar', role: Role.user),
    );
    await logIn(tester);
    expect(find.text('Backoffice je za kreatore i administratore.'), findsOneWidget);
    expect(find.text('TAKTIKE'), findsNothing);
  });

  testWidgets('lets an admin in to the table', (tester) async {
    await pump(tester);
    await logIn(tester);
    expect(find.text('TAKTIKE'), findsOneWidget);
    expect(find.text('AP brzi nivo 9 sa Alune'), findsOneWidget);
  });

  testWidgets('F5 asks the server again', (tester) async {
    final dependencies = await pump(tester);
    await logIn(tester);

    dependencies.fakeTactics!.emptyResponses = 1;
    await tester.sendKeyEvent(LogicalKeyboardKey.f5);
    await tester.pumpAndSettle();
    expect(find.text('Još nema taktika.'), findsOneWidget);

    await tester.tap(find.byTooltip('Osveži (F5)'));
    await tester.pumpAndSettle();
    expect(find.text('AP brzi nivo 9 sa Alune'), findsOneWidget);
  });

  testWidgets('logs out from the rail and asks for a login again when the session expires', (tester) async {
    final dependencies = await pump(tester);
    await logIn(tester);

    await tester.tap(find.text('A'));
    await tester.pumpAndSettle();
    expect(find.text('Administrator'), findsOneWidget);
    await tester.tap(find.text('Odjavi se'));
    await tester.pumpAndSettle();
    expect(find.text('Korisničko ime'), findsOneWidget);

    await logIn(tester);
    dependencies.fakeSessions!.expire();
    await tester.pumpAndSettle();
    expect(find.text('Prijava je istekla. Prijavite se ponovo.'), findsOneWidget);
  });
}
