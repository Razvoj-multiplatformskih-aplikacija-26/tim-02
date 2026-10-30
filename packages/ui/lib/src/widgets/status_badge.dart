import 'package:domain/domain.dart';
import 'package:flutter/material.dart';

extension TacticStatusLabel on TacticStatus {
  String get label => switch (this) {
    Draft() => 'Nacrt',
    Published() => 'Objavljena',
    Hidden() => 'Sakrivena',
    Archived() => 'Arhivirana',
  };
}

class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status});

  final TacticStatus status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final (background, foreground) = switch (status) {
      Draft() => (scheme.surfaceContainerHighest, scheme.onSurfaceVariant),
      Published() => (scheme.primaryContainer, scheme.onPrimaryContainer),
      Hidden() => (scheme.errorContainer, scheme.onErrorContainer),
      Archived() => (scheme.secondaryContainer, scheme.onSecondaryContainer),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(999)),
      child: Text(status.label, style: theme.textTheme.labelMedium?.copyWith(color: foreground)),
    );
  }
}
