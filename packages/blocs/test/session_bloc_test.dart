import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:blocs/blocs.dart';
import 'package:domain/domain.dart';
import 'package:test/test.dart';
import 'package:use_cases/use_cases.dart';

final class RememberedSession implements SessionRepository {
  RememberedSession(this.remembered, {this.accounts = const {}});

  User? remembered;
  final Map<String, User> accounts;
  final _expirations = StreamController<void>.broadcast();

  void expire() => _expirations.add(null);

  @override
  Future<User?> logIn({required String username, required String password}) async =>
      remembered = password == 'tft-demo' ? accounts[username] : null;

  @override
  Future<User?> current() async => remembered;

  @override
  Future<void> logOut() async => remembered = null;

  @override
  Stream<void> get expirations => _expirations.stream;
}

void main() {
  const marko = User(id: UserId('u-marko'), name: 'Marko', role: Role.creator);
  const ana = User(id: UserId('u-ana'), name: 'Ana', role: Role.admin);
  late RememberedSession sessions;

  SessionBloc phoneSession() => SessionBloc(
    restoreSession: RestoreSession(sessions: sessions),
    logOut: LogOut(sessions: sessions),
    admits: AccessPolicy.canUseMobile,
    expirations: sessions.expirations,
  );

  blocTest<SessionBloc, SessionState>(
    'a remembered login survives a restart and ends with a reason when the server says it expired',
    setUp: () => sessions = RememberedSession(marko),
    build: phoneSession,
    act: (bloc) async {
      bloc.add(const SessionRestoreRequested());
      await Future<void>.delayed(Duration.zero);
      sessions.expire();
    },
    expect: () => [const SignedIn(marko), const SignedOut(reason: SignOutReason.expired)],
  );

  blocTest<SessionBloc, SessionState>(
    'the phone signs an admin out again and says why',
    setUp: () => sessions = RememberedSession(ana),
    build: phoneSession,
    act: (bloc) => bloc.add(const SessionRestoreRequested()),
    expect: () => [const SignedOut(reason: SignOutReason.roleNotAllowed)],
    verify: (_) => expect(sessions.remembered, isNull),
  );

  blocTest<LoginFormBloc, LoginFormState>(
    'a wrong password is rejected and the right one signs in',
    setUp: () => sessions = RememberedSession(null, accounts: {'marko': marko}),
    build: () => LoginFormBloc(logIn: LogIn(sessions: sessions)),
    act: (bloc) async {
      bloc.add(const LoginSubmitted(username: 'marko', password: 'pogresna'));
      await Future<void>.delayed(Duration.zero);
      bloc.add(const LoginSubmitted(username: ' marko ', password: 'tft-demo'));
    },
    expect: () => [
      const LoginSubmitting(),
      const LoginRejected(),
      const LoginSubmitting(),
      const LoginSucceeded(marko),
    ],
  );
}
