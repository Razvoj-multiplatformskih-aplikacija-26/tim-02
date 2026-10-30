import 'package:go_router/go_router.dart';

import 'screens/comps_screen.dart';
import 'screens/home_shell.dart';
import 'screens/my_tactics_screen.dart';

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
        ],
      ),
    ],
  );
}
