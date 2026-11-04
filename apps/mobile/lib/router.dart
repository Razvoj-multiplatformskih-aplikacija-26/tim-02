import 'package:blocs/blocs.dart';
import 'package:domain/domain.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'dependencies.dart';
import 'screens/comps_screen.dart';
import 'screens/home_shell.dart';
import 'screens/draft_editor_screen.dart';
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
        path: '/drafts/new',
        builder: (context, state) {
          final query = state.uri.queryParameters;
          final tactic = _tactic(context, query['from']);
          final variant = tactic?.variants.elementAtOrNull(int.tryParse(query['variant'] ?? '') ?? 0);
          return _draftEditor(context, switch ((tactic, variant)) {
            (final tactic?, final variant?) => DraftEditorState.fromTactic(tactic, variant),
            _ => const DraftEditorState(),
          });
        },
      ),
      GoRoute(
        path: '/drafts/:id',
        redirect: (context, state) => _tactic(context, state.pathParameters['id']) == null ? '/mine' : null,
        builder: (context, state) =>
            _draftEditor(context, DraftEditorState.edit(_tactic(context, state.pathParameters['id'])!)),
      ),
    ],
  );
}

Tactic? _tactic(BuildContext context, String? id) => switch ((id, context.read<TacticsBloc>().state)) {
  (final id?, final TacticsLoaded loaded) => loaded.tactic(TacticId(id)),
  _ => null,
};

Widget _draftEditor(BuildContext context, DraftEditorState initial) {
  final dependencies = context.read<AppDependencies>();
  return BlocProvider(
    create: (_) => DraftEditorBloc(
      saveDraft: dependencies.saveDraft,
      deleteDraft: dependencies.deleteDraft,
      getCatalog: dependencies.getCatalog,
      user: dependencies.user,
      initial: initial,
    )..add(const DraftEditorStarted()),
    child: const DraftEditorScreen(),
  );
}
