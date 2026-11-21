import 'package:blocs/blocs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ui/ui.dart';

import '../dependencies.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.read<SessionBloc>();
    return BlocConsumer<SessionBloc, SessionState>(
      listenWhen: (previous, current) => current is SignedIn,
      listener: (context, state) => context.pop(),
      builder: (context, state) => LoginScreen(
        appBar: AppBar(),
        logIn: context.read<AppDependencies>().logIn,
        reason: switch (state) {
          SignedOut(:final reason) => reason,
          _ => null,
        },
        roleNotAllowedMessage: 'Mobilna aplikacija je za korisnike i kreatore.',
        onSignedIn: (user) => session.add(SessionStarted(user)),
      ),
    );
  }
}

class AccountButton extends StatelessWidget {
  const AccountButton({super.key});

  @override
  Widget build(BuildContext context) {
    return switch (context.watch<SessionBloc>().state) {
      SignedIn(:final user) => AccountMenu(
        user: user,
        onLogOut: () => context.read<SessionBloc>().add(const SessionLogOutRequested()),
      ),
      SignedOut() => TextButton(onPressed: () => signIn(context), child: const Text('Prijavi se')),
      SessionUnknown() => const SizedBox.shrink(),
    };
  }
}

void retryTactics(BuildContext context) {
  final session = context.read<SessionBloc>();
  if (session.state case SignedOut(reason: SignOutReason.unreachable)) {
    session.add(const SessionRestoreRequested());
  } else {
    context.read<TacticsBloc>().add(const TacticsRequested());
  }
}

Future<void> signIn(BuildContext context) async {
  final router = GoRouter.of(context);
  final session = context.read<SessionBloc>();
  await router.push('/login');
  if (session.state is SignedIn) router.go('/');
}
