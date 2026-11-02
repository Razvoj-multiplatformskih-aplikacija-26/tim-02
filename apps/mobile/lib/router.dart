import 'package:domain/domain.dart';
import 'package:go_router/go_router.dart';

import 'screens/comps_screen.dart';
import 'screens/home_shell.dart';
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
    ],
  );
}
