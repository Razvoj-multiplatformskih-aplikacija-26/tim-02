import 'package:blocs/blocs.dart';
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
  late final GoRouter _router = createRouter();

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dependencies = widget.dependencies;
    return RepositoryProvider.value(
      value: dependencies,
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => TacticsBloc(
              getTactics: dependencies.getTactics,
              getTierList: dependencies.getTierList,
              user: dependencies.user,
            )..add(const TacticsRequested()),
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
    );
  }
}
