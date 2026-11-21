import 'package:blocs/blocs.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ui/ui.dart';

class BackofficeShell extends StatelessWidget {
  const BackofficeShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: shell.currentIndex,
            onDestinationSelected: (index) => shell.goBranch(index, initialLocation: index == shell.currentIndex),
            labelType: NavigationRailLabelType.all,
            trailingAtBottom: true,
            trailing: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: AccountMenu(
                user: context.read<User>(),
                onLogOut: () => context.read<SessionBloc>().add(const SessionLogOutRequested()),
              ),
            ),
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.table_rows_outlined),
                selectedIcon: Icon(Icons.table_rows),
                label: Text('Taktike'),
              ),
            ],
          ),
          const VerticalDivider(width: 1),
          Expanded(child: shell),
        ],
      ),
    );
  }
}
