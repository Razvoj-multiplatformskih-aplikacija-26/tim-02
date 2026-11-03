import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
