import 'package:domain/domain.dart';
import 'package:go_router/go_router.dart';

import 'screens/backoffice_shell.dart';
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
                  );
                },
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
