import 'package:blocs/blocs.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui/ui.dart';
import 'package:use_cases/use_cases.dart';

const marko = User(id: UserId('u-marko'), name: 'Marko', role: Role.creator);

final class _Sessions implements SessionRepository {
  _Sessions({this.failure});

  final RepositoryFailure? failure;

  @override
  Future<User?> logIn({required String username, required String password}) async {
    if (failure case final failure?) throw RepositoryException('test', failure: failure);
    return username == 'marko' && password == 'tft-demo' ? marko : null;
  }

  @override
  Future<User?> current() async => null;

  @override
  Future<void> logOut() async {}

  @override
  Stream<void> get expirations => const Stream.empty();
}

void main() {
  Future<List<User>> pump(WidgetTester tester, {RepositoryFailure? failure, SignOutReason? reason}) async {
    final signedIn = <User>[];
    await tester.pumpWidget(
      MaterialApp(
        home: LoginScreen(
          key: UniqueKey(),
          logIn: LogIn(sessions: _Sessions(failure: failure)),
          onSignedIn: signedIn.add,
          roleNotAllowedMessage: 'Mobilna aplikacija je za korisnike i kreatore.',
          reason: reason,
        ),
      ),
    );
    return signedIn;
  }

  Future<void> submit(WidgetTester tester, String username, String password) async {
    await tester.enterText(find.widgetWithText(TextField, 'Korisničko ime'), username);
    await tester.enterText(find.widgetWithText(TextField, 'Lozinka'), password);
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Prijavi se'));
    await tester.pumpAndSettle();
  }

  bool enabled(WidgetTester tester) =>
      tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Prijavi se')).onPressed != null;

  testWidgets('the button waits for both fields', (tester) async {
    await pump(tester);
    expect(enabled(tester), isFalse);

    await tester.enterText(find.widgetWithText(TextField, 'Korisničko ime'), 'marko');
    await tester.pump();
    expect(enabled(tester), isFalse);

    await tester.enterText(find.widgetWithText(TextField, 'Lozinka'), 'tft-demo');
    await tester.pump();
    expect(enabled(tester), isTrue);
  });

  testWidgets('a wrong password is told apart from an unreachable server, and the right one signs in', (tester) async {
    final signedIn = await pump(tester);
    await submit(tester, 'marko', 'pogresna');
    expect(find.text('Pogrešno korisničko ime ili lozinka.'), findsOneWidget);

    await submit(tester, ' marko ', 'tft-demo');
    expect(signedIn, [marko]);

    await pump(tester, failure: RepositoryFailure.unreachable);
    await submit(tester, 'marko', 'tft-demo');
    expect(find.text('Nema veze sa serverom.'), findsOneWidget);
  });

  testWidgets('shows why the session ended', (tester) async {
    await pump(tester, reason: SignOutReason.roleNotAllowed);
    expect(find.text('Mobilna aplikacija je za korisnike i kreatore.'), findsOneWidget);

    await pump(tester, reason: SignOutReason.expired);
    expect(find.text('Prijava je istekla. Prijavite se ponovo.'), findsOneWidget);
  });

  testWidgets('the account menu names the role and logs out', (tester) async {
    var loggedOut = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            actions: [AccountMenu(user: marko, onLogOut: () => loggedOut = true)],
          ),
        ),
      ),
    );

    await tester.tap(find.text('M'));
    await tester.pumpAndSettle();
    expect(find.text('Kreator'), findsOneWidget);

    await tester.tap(find.text('Odjavi se'));
    await tester.pumpAndSettle();
    expect(loggedOut, isTrue);
  });
}
