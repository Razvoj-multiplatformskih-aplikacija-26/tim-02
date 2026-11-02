import 'package:blocs/blocs.dart';
import 'package:domain/domain.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'dependencies.dart';
import 'screens/comps_screen.dart';
import 'screens/home_shell.dart';
import 'screens/lineup_editor_screen.dart';
import 'screens/lineups_screen.dart';
import 'screens/my_tactics_screen.dart';
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
            routes: [GoRoute(path: '/mine', builder: (context, state) => const MyTacticsScreen())],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: '/lineups', builder: (context, state) => const LineupsScreen())],
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
        builder: (context, state) => _lineupEditor(context, switch ((state.uri.queryParameters['from'], state.extra)) {
          (final from?, final TacticVariant variant) => LineupEditorState.fromVariant(TacticId(from), variant),
          _ => const LineupEditorState(),
        }),
      ),
      GoRoute(
        path: '/lineups/:id',
        redirect: (context, state) => state.extra is PersonalLineup ? null : '/lineups',
        builder: (context, state) => _lineupEditor(context, LineupEditorState.edit(state.extra! as PersonalLineup)),
      ),
    ],
  );
}

Widget _lineupEditor(BuildContext context, LineupEditorState initial) => BlocProvider(
  create: (_) => LineupEditorBloc(saveLineup: context.read<AppDependencies>().saveLineup, initial: initial),
  child: const LineupEditorScreen(),
);
