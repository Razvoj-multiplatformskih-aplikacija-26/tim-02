import 'package:domain/domain.dart';
import 'package:flutter/material.dart';

import '../text/serbian.dart';

class AccountMenu extends StatelessWidget {
  const AccountMenu({super.key, required this.user, required this.onLogOut});

  final User user;
  final VoidCallback onLogOut;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PopupMenuButton<void>(
      tooltip: user.name,
      itemBuilder: (context) => [
        PopupMenuItem(
          enabled: false,
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(user.name, style: theme.textTheme.titleSmall),
            subtitle: Text(user.role.label),
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          onTap: onLogOut,
          child: const ListTile(contentPadding: EdgeInsets.zero, leading: Icon(Icons.logout), title: Text('Odjavi se')),
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: CircleAvatar(
          radius: 16,
          backgroundColor: theme.colorScheme.primaryContainer,
          foregroundColor: theme.colorScheme.onPrimaryContainer,
          child: Text(user.name.characters.first.toUpperCase(), style: theme.textTheme.labelLarge),
        ),
      ),
    );
  }
}
