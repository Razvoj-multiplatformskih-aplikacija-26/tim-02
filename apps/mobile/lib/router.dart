import 'package:blocs/blocs.dart';
import 'package:domain/domain.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'dependencies.dart';
import 'screens/comps_screen.dart';
import 'screens/home_shell.dart';
import 'screens/lineup_editor_screen.dart';
import 'screens/mine_screen.dart';
import 'screens/tactic_detail_screen.dart';

GoRouter createRouter() {
  return GoRouter(
    initialLocation: '/',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => HomeShell(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [GoRoute(path: '/', builder: (context, state) => const CompsScreen())],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/mine',
                builder: (context, state) => MineScreen(archived: state.uri.queryParameters['archived'] == '1'),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/tactics/:id',
        builder: (context, state) => TacticDetailScreen(
          id: TacticId(state.pathParameters['id']!),
          variant: int.tryParse(state.uri.queryParameters['variant'] ?? '') ?? 0,
          early: state.uri.queryParameters['early'] == '1',
        ),
      ),
      GoRoute(
        path: '/lineups/new',
        builder: (context, state) {
          final query = state.uri.queryParameters;
          final tactic = switch ((query['from'], context.read<TacticsBloc>().state)) {
            (final from?, final TacticsLoaded loaded) => loaded.tactic(TacticId(from)),
            _ => null,
          };
          final variant = tactic?.variants.elementAtOrNull(int.tryParse(query['variant'] ?? '') ?? 0);
          return _lineupEditor(context, switch ((tactic, variant)) {
            (final tactic?, final variant?) => LineupEditorState.fromTactic(
              tactic,
              variant,
              early: query['early'] == '1',
            ),
            _ => const LineupEditorState(),
          });
        },
      ),
      GoRoute(
        path: '/lineups/:id',
        redirect: (context, state) => state.extra is PersonalLineup ? null : '/mine',
        builder: (context, state) => _lineupEditor(context, LineupEditorState.edit(state.extra! as PersonalLineup)),
      ),
    ],
  );
}

Widget _lineupEditor(BuildContext context, LineupEditorState initial) {
  final dependencies = context.read<AppDependencies>();
  return BlocProvider(
    create: (_) => LineupEditorBloc(
      saveLineup: dependencies.saveLineup,
      deleteLineup: dependencies.deleteLineup,
      initial: initial,
    ),
    child: const LineupEditorScreen(),
  );
}
