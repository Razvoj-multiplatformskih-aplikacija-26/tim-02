import 'package:blocs/blocs.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:use_cases/use_cases.dart' show LogIn;

import '../text/failures.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({
    super.key,
    required this.logIn,
    required this.onSignedIn,
    required this.roleNotAllowedMessage,
    this.reason,
    this.appBar,
  });

  final LogIn logIn;
  final void Function(User user) onSignedIn;
  final String roleNotAllowedMessage;
  final SignOutReason? reason;
  final PreferredSizeWidget? appBar;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LoginFormBloc(logIn: logIn),
      child: BlocListener<LoginFormBloc, LoginFormState>(
        listener: (context, state) {
          if (state case LoginSucceeded(:final user)) onSignedIn(user);
        },
        child: Scaffold(
          appBar: appBar,
          body: _LoginForm(reason: reason, roleNotAllowedMessage: roleNotAllowedMessage),
        ),
      ),
    );
  }
}

class _LoginForm extends StatefulWidget {
  const _LoginForm({required this.roleNotAllowedMessage, this.reason});

  final String roleNotAllowedMessage;
  final SignOutReason? reason;

  @override
  State<_LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<_LoginForm> {
  final _username = TextEditingController();
  final _password = TextEditingController();
  var _passwordShown = false;

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  bool get _filled => _username.text.trim().isNotEmpty && _password.text.isNotEmpty;

  void _submit() {
    if (!_filled) return;
    context.read<LoginFormBloc>().add(LoginSubmitted(username: _username.text, password: _password.text));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = context.watch<LoginFormBloc>().state;
    final busy = state is LoginSubmitting;
    final message = switch (state) {
      LoginRejected() => 'Pogrešno korisničko ime ili lozinka.',
      LoginFailed(:final cause) => failureMessage(cause),
      _ => switch (widget.reason) {
        SignOutReason.roleNotAllowed => widget.roleNotAllowedMessage,
        SignOutReason.expired => sessionExpiredMessage,
        SignOutReason.unreachable => serverUnreachableMessage,
        SignOutReason.loggedOut || null => null,
      },
    };
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: AutofillGroup(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Semantics(
                  header: true,
                  child: Text('TFT INSIGHTS', style: theme.textTheme.headlineMedium, textAlign: TextAlign.center),
                ),
                const SizedBox(height: 24),
                if (message != null) ...[
                  Semantics(
                    liveRegion: true,
                    child: Text(
                      message,
                      style: TextStyle(color: theme.colorScheme.error),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                TextField(
                  controller: _username,
                  enabled: !busy,
                  autofillHints: const [AutofillHints.username],
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(labelText: 'Korisničko ime'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _password,
                  enabled: !busy,
                  obscureText: !_passwordShown,
                  autofillHints: const [AutofillHints.password],
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _submit(),
                  decoration: InputDecoration(
                    labelText: 'Lozinka',
                    suffixIcon: IconButton(
                      onPressed: () => setState(() => _passwordShown = !_passwordShown),
                      tooltip: _passwordShown ? 'Sakrij lozinku' : 'Prikaži lozinku',
                      icon: Icon(_passwordShown ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ListenableBuilder(
                  listenable: Listenable.merge([_username, _password]),
                  builder: (context, _) => FilledButton(
                    onPressed: busy || !_filled ? null : _submit,
                    child: busy
                        ? const SizedBox.square(
                            dimension: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, semanticsLabel: 'Prijava u toku'),
                          )
                        : const Text('Prijavi se'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
