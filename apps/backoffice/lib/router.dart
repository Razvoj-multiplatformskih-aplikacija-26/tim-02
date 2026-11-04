import 'package:blocs/blocs.dart';
import 'package:domain/domain.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'dependencies.dart';
import 'screens/backoffice_shell.dart';
import 'screens/tactic_editor_screen.dart';
import 'screens/tactics_screen.dart';

GoRouter createRouter() {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', redirect: (context, state) => TacticsScreen.pathFor(null)),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => BackofficeShell(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/tactics',
                builder: (context, state) {
                  final query = state.uri.queryParameters;
                  return TacticsScreen(
                    filter: TacticStatusKind.values.asNameMap()[query['state']],
                    search: query['q'] ?? '',
                    tier: Tier.values.asNameMap()[query['tier']],
                    selectedId: switch (query['selected']) {
                      final id? => TacticId(id),
                      null => null,
                    },
                    variant: int.tryParse(query['variant'] ?? '') ?? 0,
                    early: query['early'] == '1',
                  );
                },
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/tactics/:id/edit',
        redirect: (context, state) => switch (context.read<TacticsBloc>().state) {
          final TacticsLoaded loaded when loaded.canEdit(TacticId(state.pathParameters['id']!)) => null,
          _ => TacticsScreen.pathFor(null, selected: TacticId(state.pathParameters['id']!)),
        },
        builder: (context, state) {
          final dependencies = context.read<BackofficeDependencies>();
          final loaded = context.read<TacticsBloc>().state as TacticsLoaded;
          return BlocProvider(
            create: (_) => TacticEditorBloc(
              editTactic: dependencies.editTactic,
              getCatalog: dependencies.getCatalog,
              user: dependencies.user,
              tactic: loaded.tactic(TacticId(state.pathParameters['id']!))!,
            )..add(const TacticEditorStarted()),
            child: const TacticEditorScreen(),
          );
        },
      ),
    ],
  );
}
