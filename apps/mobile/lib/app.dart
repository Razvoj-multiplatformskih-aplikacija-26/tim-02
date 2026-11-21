import 'package:blocs/blocs.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:ui/ui.dart';

import 'dependencies.dart';
import 'router.dart';

class TftInsightsApp extends StatefulWidget {
  const TftInsightsApp({super.key, required this.dependencies});

  static const locale = Locale.fromSubtags(languageCode: 'sr', scriptCode: 'Latn');

  final AppDependencies dependencies;

  @override
  State<TftInsightsApp> createState() => _TftInsightsAppState();
}

class _TftInsightsAppState extends State<TftInsightsApp> {
  late final SessionBloc _session = SessionBloc(
    restoreSession: widget.dependencies.restoreSession,
    logOut: widget.dependencies.logOut,
    admits: AccessPolicy.canUseMobile,
    expirations: widget.dependencies.sessionExpirations,
  )..add(const SessionRestoreRequested());
  late final TacticsBloc _tactics = TacticsBloc(
    getTactics: widget.dependencies.getTactics,
    getTierList: widget.dependencies.getTierList,
    changeStatus: widget.dependencies.changeTacticStatus,
    placeTactic: widget.dependencies.placeTactic,
    clock: widget.dependencies.clock,
  );
  late final GoRouter _router = createRouter();

  @override
  void dispose() {
    _router.dispose();
    _tactics.close();
    _session.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider.value(
      value: widget.dependencies,
      child: MultiBlocProvider(
        providers: [
          BlocProvider.value(value: _session),
          BlocProvider.value(value: _tactics),
        ],
        child: MultiBlocListener(
          listeners: [
            BlocListener<SessionBloc, SessionState>(
              listenWhen: (previous, current) => current is! SessionUnknown,
              listener: (context, session) => _tactics.add(
                TacticsUserChanged(switch (session) {
                  SignedIn(:final user) => user,
                  _ => null,
                }),
              ),
            ),
            BlocListener<SessionBloc, SessionState>(
              listenWhen: (previous, current) =>
                  previous is SignedIn && current is SignedOut && current.reason == SignOutReason.expired,
              listener: (context, session) => _router.push('/login'),
            ),
          ],
          child: MaterialApp.router(
            title: 'TFT Insights',
            theme: TftTheme.light(),
            darkTheme: TftTheme.dark(),
            themeMode: ThemeMode.system,
            locale: TftInsightsApp.locale,
            supportedLocales: const [TftInsightsApp.locale],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            routerConfig: _router,
          ),
        ),
      ),
    );
  }
}
